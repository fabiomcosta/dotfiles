#!/usr/bin/env node

import { $, cd } from 'zx';
import os from 'os';
import path from 'path';
import fs from 'fs/promises';
import { applyTemplate } from './src/apply_template.mjs';
import {
  isDirectory,
  isSymlink,
  createSymlinkFor,
  createHomeSymlink,
} from './src/fs.mjs';
import { OK, WARN, ERROR, hl } from './src/log.mjs';
import { commandExists } from './src/shell.mjs';
import { dir, home, secrets, DIR } from './src/path.mjs';

const IS_MACOS = os.platform() === 'darwin';
const IS_REMOTE_SSH = Boolean(process.env.SSH_CLIENT || process.env.SSH_TTY);
const IS_WORK_MACHINE = await $`hostname`.trim().endsWith('facebook.com');

console.log({ IS_WORK_MACHINE });

if (IS_WORK_MACHINE) {
  await applyTemplate(
    secrets('facebook-devserver/.gitconfig'),
    home('.gitconfig')
  );
} else {
  await applyTemplate(dir('.gitconfig'), home('.gitconfig'));
}

if (IS_WORK_MACHINE) {
  await createSymlinkFor(home('.npmrc'), secrets('facebook-devserver/.npmrc'));
}

if (IS_MACOS) {
  await import('./macos.mjs');
}

if (IS_MACOS && !IS_REMOTE_SSH) {
  const keyboardHomePath = home('.keyboard');
  if (await isSymlink(keyboardHomePath)) {
    OK`${hl('keyboard')} already installed.`;
  } else {
    await createHomeSymlink('.keyboard');
    cd(keyboardHomePath);
    await $`./script/setup`;
    cd(DIR);
  }

  await createHomeSymlink('.config/karabiner');
  await createHomeSymlink('.config/alacritty/alacritty.yml');
}

await createHomeSymlink('.vim');
await createHomeSymlink('.vimrc');
await createHomeSymlink('.bash_profile');
await createHomeSymlink('.ripgreprc');
await createHomeSymlink('.tmux.conf');
await createHomeSymlink('.config/fish/config.fish');
await createHomeSymlink('.config/nvim/coc-settings.json');
await createSymlinkFor(home('.config/nvim/init.vim'), dir('.vimrc'));

console.log(
  'Setting rebase to be the default for the master branch on this repo...'
);
await $`git config branch.master.rebase true`;
