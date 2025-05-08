function templateTagArgsToString(strings, keys) {
  let result = [];
  while (strings.length) {
    result.push(strings.shift());
    if (keys.length) {
      result.push(keys.shift());
    }
  }
  return result.join('');
}

function createTemplateTagLogger(prefix) {
  return function (strings, ...keys) {
    console.log(prefix, templateTagArgsToString(Array.from(strings), keys));
  };
}

function createTemplateTagWrapper(prefix) {
  return function (strings, ...keys) {
    return `${prefix}${templateTagArgsToString(
      Array.from(strings),
      keys
    )}\x1b[0m`;
  };
}

export const OK = createTemplateTagLogger(`\x1b[32m✓\x1b[0m`);
export const WARN = createTemplateTagLogger(`\x1b[33m⚠\x1b[0m`);
export const ERROR = createTemplateTagLogger(`\x1b[31m✖\x1b[0m`);
export const hl = createTemplateTagWrapper(`\x1b[37m`);
