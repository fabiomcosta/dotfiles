#!/usr/bin/env node

import https from 'https';

// NOTES
//
// There are values on the function name that the web UI compress
// into these base64 blogs, my guess is that they end up making the
// log smaller this way because these can contain big blobs of json data that
// would be double quoted on a json object, creating a big mess.
// replaceAll(/base64json::<(.*?)>/g, (_, base64Str) => atob(base64Str))
//
// Some of the objects have some special keys, ex:
// {"_special_text_key_DONT_USE":"object authorization_Identity"}
// This shows as a string, but we could also allow going to that object
// using LSP maybe?
//
// TODO
// * Collapse logs when multiple equal logs are seen
// * Show special base64json elementsas previously described
// * Allow opening individual files from the trace
// * Allow jumping to definition on some of the special base64json elements
// * FUTURE: filters????

/*
{
  title: string,
  attributes: {[string]: string},
  properties: {[string]: string} ,
  trace: [{
    functionName: string,
    fileName: string,
    fileLine: number,
    metadata?: {[string]: string}
  }]
}

Template closed:
{right-arrow} {count} {icon} {title}

Template open:
{down-arrow} {count} {icon} {title}
{functionName} ({fileName}:{fileLine}) with Metadata <{metadata[n].k}:{metadata[n].v}>
*/

// meh
process.emitWarning = () => {}
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = 0;

const LOG_FILE = '/var/facebook/logs/users/svcscm/error_log_svcscm';
const LENGTH = 2097152;
const TIMEOUT = 30;

class ErrorWithMetadata extends Error {
  set(metadata) {
    this.metadata = metadata;
    return this;
  }

  toJSON() {
    return { error: { name: this.name, message: this.message, stack: this.stack, metadata: this.metadata } };
  }
}

function stringifyError(error) {
  const serializableError = (typeof error.toJSON === 'function') ? error : { error: { name: error.name, message: error.message, stack: error.stack } };
  return JSON.stringify(serializableError);
}

function guardAndLog(fn) {
  return function (...args) {
    try {
      return fn.apply(this, args);
    } catch (error) {
      console.log(stringifyError(error));
    }
  };
}

function match(str, regex) {
  const parts = str.match(regex);
  if (parts == null) {
    throw new ErrorWithMetadata(`Regex didn't match.`).set({ regex, str });
  }
  return parts;
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

function getTitle(rawTitle) {
  return rawTitle
    .replace(POSITIONAL_ATTRIBUTES_REGEX, '')
    .replace(new RegExp(NAMED_ATTRIBUTES_REGEX, 'g'), '').trim() || null;
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

const TRACE_REGEXP = /^\s+#\d+ (.*?) called at \[(.*?):(\d+)\](?: with metadata (.*))?$/;
function parseTrace(trace) {
  if (!trace[0].startsWith('trace starts at ')) {
    throw new ErrorWithMetadata(`Invalid trace format.`).set({ trace });
  }
  return trace.slice(1)
    .map(traceLine => {
      const [, functionName, fileName, fileLine, metadata] =
        match(traceLine, TRACE_REGEXP);
      return {
        functionName,
        fileName,
        fileLine: Number(fileLine),
        metadata: metadata ? getNamedAttributes(metadata) : undefined
      };
    })
    .filter(Boolean);
}

function parseJSON(rawLog) {
  return JSON.parse(rawLog.replace(/^for\s\(;;\);/, ''));
}

// let c = 0;
function parseLogEntry(logEntry) {
  // c++
  // return {
  //   title: 'First log title' + c,
  //   trace: [
  //     { functionName: 'Hello::world', fileName: 'hello_world.php', fileLine: 12 },
  //     { functionName: 'Hello::worldz', fileName: 'hello_worldz.php', fileLine: 34 }
  //   ]
  // };

  // { title: 'Second log title', trace: {
  //   { functionName: 'Hello::world', fileName: 'hello_world.php', fileLine: 12 },
  //   { functionName: 'Hello::worldz', fileName: 'hello_worldz.php', fileLine: 34, metadata: { a: 'b' } }
  //   } },

  const entryLines = logEntry.split('\\n');

  const {properties, firstIndex, lastIndex} = getProperties(entryLines);

  if (firstIndex == null || lastIndex == null) {
    return null;
  }

  const rawTitle = getRawTitle(entryLines, firstIndex);
  const title = getTitle(rawTitle);
  if (title == null) {
    return null;
  }

  const positionalAttrs = getPositionalAttributes(rawTitle) ?? {};
  const namedAttrs = getNamedAttributes(rawTitle) ?? {};

  if (Object.keys(positionalAttrs).length === 0 || Object.keys(namedAttrs).length === 0) {
    throw new ErrorWithMetadata(`No positional nor named attributes.`).set({ entryLines });
  }

  const attributes = {...positionalAttrs, ...namedAttrs};

  const trace = parseTrace(entryLines.slice(lastIndex + 1));

  return {
    title,
    attributes,
    properties,
    trace
  };
}

function parseLogs(logObject) {
  return logObject.data
    .split(/\n/)
    .map(guardAndLog(parseLogEntry))
    .filter(Boolean);
}

// async function timeout(timeoutMs) {
//   return new Promise((res) => {
//     setTimeout(res, timeoutMs);
//   });
// }

function httpGet(tailerUrl, options = {}) {
  return new Promise((resolve, reject) => {
    let data = '';
    https.get(tailerUrl, options, (res) => {
      res
        .on('data', dataBuffer => data += String(dataBuffer))
        .on('close', () => resolve(data));
    }).on('error', reject);
  });
}

async function fetchSlogs(tailerUrl) {
  // const ORIGIN_HEADER = 'origin: https://www.internalfb.com';
  // let {stdout} = await $`curl -H ${ORIGIN_HEADER} ${tailerUrl}`;
  const slogsResponse = await httpGet(tailerUrl, {headers: {origin: 'https://www.internalfb.com'}})
  return parseJSON(slogsResponse);
  // await timeout(5000);
  // return {data: 'a'};
}

async function main([tier]) {
  if (!tier) {
    throw new Error('No tier argument provided. ex: 12345.od');
  }

  const origin = `https://not-www.${tier}.internalfb.com/`;
  const path = `intern/itools/slog_tailer.php`;
  const tailerUrl = new URL(path, origin);
  tailerUrl.searchParams.set('op', 'tail');
  tailerUrl.searchParams.set('file', LOG_FILE);
  tailerUrl.searchParams.set('len', LENGTH);
  tailerUrl.searchParams.set('timeout', TIMEOUT);

  let pos = -LENGTH;
  while (true) {
    await guardAndLog(async () => {
      tailerUrl.searchParams.set('pos', pos);
      const logObject = await fetchSlogs(tailerUrl);
      pos = logObject.pos;
      parseLogs(logObject)
        .map(log => JSON.stringify(log))
        .forEach(log => console.log(log));
    })();
  }
}

main(process.argv.slice(2))
  .then(process.exit)
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
