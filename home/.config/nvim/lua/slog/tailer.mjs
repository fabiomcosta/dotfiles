#!/usr/bin/env node

import https from 'https';

// Ignoring and swallowing SSL errors
process.emitWarning = () => {}
process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0;

const {USER} = process.env;

const OD_LOG_FILE = '/var/facebook/logs/users/svcscm/error_log_svcscm';
const DV_LOG_FILE = `/home/${USER}/logs/error_log_${USER}`;
const LENGTH = 2097152;
const TIMEOUT = 10;

class ErrorWithMetadata extends Error {
  set(metadata) {
    this.metadata = metadata;
    return this;
  }

  toJSON() {
    return {
      error: {
        name: this.name,
        message: this.message,
        stack: this.stack,
        metadata: this.metadata ?? {}
      }
    };
  }
}

class ErrorTimeout extends ErrorWithMetadata {
  constructor(...args) {
    super(...args);
    this.set({ timeout: true });
  }
}

class ErrorKnownNetworkError extends ErrorWithMetadata {}

class ErrorUnrecoverable extends ErrorWithMetadata {}

function stringifyError(error) {
  const serializableError = (typeof error.toJSON === 'function') ? error : {
    error: { name: error.name, message: error.message, stack: error.stack, metadata: error.metadata ?? {} }
  };
  return JSON.stringify(serializableError);
}

function isThenable(obj) {
  return obj != null && typeof obj.then === 'function';
}

function reportError(error) {
  console.log(stringifyError(error));
  if (error instanceof ErrorUnrecoverable) {
    return process.exit(1);
  }
}

function guardAndLog(fn) {
  return function (...args) {
    try {
      const result = fn.apply(this, args);
      return isThenable(result) ? result.catch(reportError) : result;
    } catch (error) {
      reportError(error);
    }
  };
}

function timeout(timeoutMs = 0) {
  return new Promise((resolve)=>{
    setTimeout(resolve, timeoutMs);
  });
}

function match(str, regex) {
  const parts = str.match(regex);
  if (parts == null) {
    throw new ErrorWithMetadata(`Regex didn't match.`)
      .set({ regex: regex.source, str });
  }
  return parts;
}

function httpGet(tailerUrl, options = {}) {
  return new Promise((resolve, reject) => {
    const req = https.get(tailerUrl, options, (res) => {
      if (res.statusCode === 200) {
        let data = '';
        res
          .on('data', dataBuffer => data += String(dataBuffer))
          .on('end', () => resolve(data));
      } else if (res.statusCode === 302) {
        // The user is likely not on the VPN and we can't access the log
        // endpoint, so we get a redirect.
        reject(new ErrorKnownNetworkError(`Request redirected.`));
      } else {
        reject(new Error(`Unknown Network error statusCode:${res.statusCode}`));
      }
    })
      .on('timeout', () => {
        req.destroy(new ErrorTimeout(`Request timed out.`));
      })
      .on('error', (error) => {
        // dns error, user is likely disconnected from the internet or the
        // connection is flaky
        if (error.code === 'ENOTFOUND') {
          reject(new ErrorKnownNetworkError(error.message));
        } else {
          reject(error)
        }
      });
  });
}

function parseJSON(rawLog) {
  return JSON.parse(rawLog.replace(/^for\s*\(;;\);/, ''));
}

const NAMED_ATTRIBUTES_REGEX = /<(.*?):(.*?)>/;
function getNamedAttributes(rawTitle) {
  const attributes = rawTitle.matchAll(new RegExp(NAMED_ATTRIBUTES_REGEX, 'g'));
  return Object.fromEntries(Array.from(attributes, attr => [attr[1], attr[2]]));
}

const POSITIONAL_ATTRIBUTES_REGEX = /^\[(.*?)\] \[(.*?)\] \[(.*?)\] /;
function getPositionalAttributes(rawTitle) {
  const attributes = rawTitle.match(POSITIONAL_ATTRIBUTES_REGEX);
  if (attributes == null) {
    return null;
  }
  return {
    date: new Date(attributes[1]).getTime() / 1000,
    service: attributes[2],
    id: attributes[3],
  };
}

function getRawTitle(entryLines, firstPropertyIndex) {
  return entryLines.slice(0, firstPropertyIndex).join('\n');
}

const SLOG_COLOR_REGEX = /^"__SLOG_COLOR_\w+__", /i;
function getTitle(rawTitle) {
  return rawTitle
    .replace(POSITIONAL_ATTRIBUTES_REGEX, '')
    .replace(new RegExp(NAMED_ATTRIBUTES_REGEX, 'g'), '')
    .trim()
    // We are simply ignoring the forced slog colors for now
    // But could definitely support it in the future.
    .replace(SLOG_COLOR_REGEX, '')
    .trim() || null;
}

const PROPERTIES_REGEX = /^\(([\w\s]+): (.*?)\)$/;
function getProperties(entryLines) {
  let lastIndex;
  let firstIndex;
  const propEntryLines = entryLines
    .map((entryLine, i) => {
      if (!PROPERTIES_REGEX.test(entryLine)) {
        return null;
      }
      if (firstIndex == null) {
        firstIndex = i;
      }
      lastIndex = i;
      const [, name, value] = match(entryLine, PROPERTIES_REGEX);
      return [name, value];
    })
    .filter(Boolean);
  return { properties: Object.fromEntries(propEntryLines), firstIndex, lastIndex };
}

const TRACE_REGEXP = /^(?:\s*#\d+ )?(.*?) called at \[(.*?):(\d+)\](?: with metadata (.*))?$/;
function parseTrace(trace) {
  if (!trace[0].startsWith('trace starts at ')) {
    throw new ErrorWithMetadata(`Invalid trace format.`).set({ trace });
  }
  return trace.slice(1)
    .map(traceLine => {
      const parts = traceLine.match(TRACE_REGEXP);
      // There are some buggy traces where the function name may contain the
      // parameters and the parameters might have newline characters
      // In those cses the regex won't match, and we should just show them as-is.
      if (parts == null) {
        return {
          functionName: traceLine,
        };
      }
      const [, functionName, fileName, fileLine, metadata] = parts;
      return {
        functionName,
        fileName,
        fileLine: Number(fileLine),
        metadata: metadata ? getNamedAttributes(metadata) : undefined
      };
    })
    .filter(Boolean);
}

function parseLogEntry(logEntry) {
  const entryLines = logEntry.split('\\n');

  let {properties, firstIndex, lastIndex} = getProperties(entryLines);

  let hasTrace = true;
  if (firstIndex == null || lastIndex == null) {
    hasTrace = false;
    firstIndex = entryLines.length;
  }

  const rawTitle = getRawTitle(entryLines, firstIndex);
  const title = getTitle(rawTitle);

  if (title == null) {
    return null;
  }

  const positionalAttrs = getPositionalAttributes(rawTitle) ?? {};
  const namedAttrs = getNamedAttributes(rawTitle) ?? {};

  if (Object.keys(positionalAttrs).length === 0) {
    // If there are no positional attributes, changes are it's a junk log
    // that we can't parse and should ignore.
    // throw new ErrorWithMetadata(`No positional attributes.`).set({ rawTitle });
    return null;
  }

  const attributes = {...positionalAttrs, ...namedAttrs};

  if (attributes.level == null) {
    // SLOG adds some special values that can change the behavior of the
    // slog client (change color, for example).
    const isSlog0 = title.startsWith('"__SLOG0__"');
    // slog and none levels are not explicitly set on the log entry.
    // We set them based on if the log has properties or not.
    attributes.level = isSlog0 || Object.keys(properties).length ? 'slog' : 'none';
  }

  const trace = hasTrace ? parseTrace(entryLines.slice(lastIndex + 1)) : [];

  return {
    title,
    attributes,
    properties,
    trace
  };
}

function parseLogs(logObject) {
  if (logObject.data === '') {
    return [{ heartbeat: true }];
  }
  if (logObject.data === 'TIMEOUT') {
    return [{ timeout: true }];
  }
  return logObject.data
    .split(/\n/)
    .map(guardAndLog(parseLogEntry))
    .filter(Boolean);
}

async function fetchSlogs(tailerUrl) {
  let slogsResponse;
  try {
    slogsResponse = await httpGet(tailerUrl, {
      headers: {origin: 'https://www.internalfb.com'},
      timeout: (TIMEOUT + 2) * 1000
    });
  } catch (error) {
    if (error instanceof ErrorTimeout) {
      return { data: 'TIMEOUT' };
    }
    if (error instanceof ErrorKnownNetworkError) {
      return { data: 'TIMEOUT', delay: true };
    }
    throw error;
  }
  return parseJSON(slogsResponse);
}

async function main([tier]) {
  if (!tier) {
    throw new Error('No tier argument provided. ex: 12345.od, devvm8579.prn0');
  }

  // od: 12445.od
  // dv: devvm8579.prn0
  const isOd = tier.endsWith('.od');
  const file = isOd ? OD_LOG_FILE : DV_LOG_FILE;
  const origin = `https://not-www.${tier}.internalfb.com/`;
  const path = `intern/itools/slog_tailer.php`;
  const tailerUrl = new URL(path, origin);
  tailerUrl.searchParams.set('op', 'tail');
  tailerUrl.searchParams.set('file', file);
  tailerUrl.searchParams.set('len', LENGTH);
  tailerUrl.searchParams.set('timeout', TIMEOUT);

  let pos = -LENGTH;
  while (true) {
    await guardAndLog(async () => {
      tailerUrl.searchParams.set('pos', pos);
      const logObject = await fetchSlogs(tailerUrl);
      parseLogs(logObject)
        .map(log => JSON.stringify(log))
        .forEach(log => console.log(log));
      if (Number.isFinite(logObject.pos)) {
        pos = logObject.pos;
      }
      // Let's create an artificial timeout in this case so we don't
      // create an infinite loop of hundreds of requests.
      if (logObject.delay) {
        await timeout(TIMEOUT * 1000);
      }
    })();
  }
}

main(process.argv.slice(2))
  .then(process.exit)
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
