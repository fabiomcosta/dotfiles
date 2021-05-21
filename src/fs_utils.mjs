import * as fs from 'fs/promises';
import { constants } from 'fs';
import { OK, WARN, ERROR, hl } from './log.mjs';

export async function exists(_path) {
  try {
    await fs.access(_path);
    return true;
  } catch (e) {
    return false;
  }
}

export async function statOrNull(_path) {
  if (!(await exists(_path))) {
    return null;
  }
  return await fs.stat(_path);
}

export async function lstatOrNull(_path) {
  if (!(await exists(_path))) {
    return null;
  }
  return await fs.lstat(_path);
}

export async function isDirectory(_path) {
  const stat = await statOrNull(_path);
  return Boolean(stat?.isDirectory());
}

export async function createSymlinkFor(origPath, destPath) {
  const stat = await lstatOrNull(origPath);
  if (stat?.isSymbolicLink()) {
    return OK`Symlink for ${hl(origPath)} was already created.`;
  }
  if (stat?.isFile()) {
    return WARN`There is already a ${hl(
      origPath
    )} file inside your home directory.`;
  }
  if (stat?.isDirectory()) {
    return WARN`There is already a ${hl(
      origPath
    )} directory inside your home directory.`;
  }
  if (stat != null) {
    return ERROR` ${hl(
      origPath
    )} isn't a symlink, folder or file. Do something!`;
  }
  await fs.mkdir(path.dirname(origPath), { recursive: true });
  await fs.symlink(destPath, origPath);
  OK`Symlink for ${hl(origPath)} created.`;
}
