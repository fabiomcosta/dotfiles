import * as fs from 'fs/promises';
import os from 'os';
import path from 'path';
import template from 'lodash.template';
import { pathExists } from './fs.mjs';
import { WARN, hl } from './log.mjs';

export async function applyTemplate(origPath, destPath) {
  // Only do anything if the destPath is not a file already.
  if (await pathExists(destPath)) {
    return WARN`${hl(destPath)} already exists so we won't apply the ${hl(
      origPath
    )} template.`;
  }
  const fileTemplate = await fs.readFile(origPath);
  const renderedTemplate = template(fileTemplate)({
    isMacos: os.platform() === 'darwin',
    user: process.env.USER,
  });
  await fs.writeFile(destPath, renderedTemplate);
}
