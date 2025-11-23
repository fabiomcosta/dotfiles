import { question } from 'zx';
import path from 'path';
import * as fs from 'fs/promises';
import { OK, WARN, ERROR, hl } from './log.js';
import { dir, home, metahome, DIR, HOME } from './path.js';

async function prompt(_question) {
  const answer = await question(`${_question} [yN] `);
  return (answer || 'n').toLowerCase() !== 'n';
}

// If the path is a file, check if it exists.
// If the path is a link, check if the linked path exists.
export async function pathExists(_path) {
  try {
    await fs.access(_path);
    return true;
  } catch (error) {
    return false;
  }
}

// If the path is a file, directory or link.
export async function lpathExists(_path) {
  try {
    await fs.lstat(_path);
    return true;
  } catch (error) {
    if (error.code === 'ENOENT') {
      return false;
    }
    throw error;
  }
}

export async function statOrNull(_path) {
  if (!(await pathExists(_path))) {
    return null;
  }
  return await fs.stat(_path);
}

export async function lstatOrNull(_path) {
  if (!(await lpathExists(_path))) {
    return null;
  }
  return await fs.lstat(_path);
}

export async function isDirectory(_path) {
  const stat = await statOrNull(_path);
  if (stat == null) {
    return false;
  }
  return Boolean(stat.isDirectory());
}

export async function isSymlink(_path) {
  const stat = await lstatOrNull(_path);
  if (stat == null) {
    return false;
  }
  return Boolean(stat.isSymbolicLink());
}

export async function createSymlinkFor(origPath, destPath) {
  let stat = await lstatOrNull(origPath);
  if (stat != null && stat.isSymbolicLink()) {
    const origLinkPath = await fs.readlink(origPath);
    if (origLinkPath === destPath) {
      return OK`Symlink for ${hl(origPath)} was already created.`;
    }
    WARN`${hl(origPath)} is a symlink that links to ${hl(
      origLinkPath
    )} but should link to ${hl(
      destPath
    )}.\n${origPath} will be deleted and replaced by the correct symlink.`;
    await fs.unlink(origPath);
    stat = null;
  }
  if (stat != null && stat.isFile()) {
    return WARN`There is already a ${hl(
      origPath
    )} file inside your home directory.`;
  }
  if (stat != null && stat.isDirectory()) {
    return WARN`There is already a ${hl(
      origPath
    )} directory inside your home directory.`;
  }
  if (stat != null) {
    return ERROR`${hl(
      origPath
    )} isn't a symlink, folder or file. Do something!`;
  }
  await fs.mkdir(path.dirname(origPath), { recursive: true });
  await fs.symlink(destPath, origPath);
  OK`Symlink for ${hl(origPath)} created.`;
}

export async function createHomeSymlink(_path) {
  await createSymlinkFor(home(_path), dir(_path));
}

export async function createMetaHomeSymlink(_path) {
  await createSymlinkFor(home(_path), metahome(_path));
}
