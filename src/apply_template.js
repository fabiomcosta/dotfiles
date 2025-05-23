import * as fs from 'fs/promises';
import os from 'os';
import path from 'path';
import { pathExists } from './fs.js';
import { WARN, hl } from './log.js';

function template(text) {
  return function (replacementObject) {
    return text.replaceAll(/<%=\s*([^%]+?)\s*%>/g, (all, key) => {
      if (!Object.prototype.hasOwnProperty.call(replacementObject, key)) {
        throw new Error(`Key "${key}" doesn't have a replacement.`);
      }
      return replacementObject[key];
    });
  };
}

export async function applyTemplate(origPath, destPath) {
  // Only do anything if the destPath is not a file already.
  if (await pathExists(destPath)) {
    return WARN`${hl(destPath)} already exists so we won't apply the ${hl(
      origPath
    )} template.`;
  }
  const fileTemplate = await fs.readFile(origPath, 'utf-8');
  const renderedTemplate = template(fileTemplate)({
    isMacos: os.platform() === 'darwin',
    user: process.env.USER,
  });
  await fs.writeFile(destPath, renderedTemplate);
}
