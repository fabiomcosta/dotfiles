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
import { commandExists, $silent } from './src/shell.mjs';
import { dir, home, secrets, DIR } from './src/path.mjs';

const IS_MACOS = os.platform() === 'darwin';
const IS_REMOTE_SSH = Boolean(process.env.SSH_CLIENT || process.env.SSH_TTY);
const IS_WORK_MACHINE = (await $silent`hostname`).stdout
  .trim()
  .endsWith('facebook.com');

if (IS_WORK_MACHINE) {
  await applyTemplate(
    secrets('facebook-devserver/.gitconfig'),
    home('.gitconfig')
  );
} else {
  await createHomeSymlink('.gitconfig');
}

if (IS_MACOS) {
  await import('./macos.mjs');
}

if (IS_WORK_MACHINE) {
  await import('./secrets/facebook-devserver/install.mjs');
}

if (IS_WORK_MACHINE) {
  // We actually want to do this before `npm i` on install.sh... tricky...
  await createSymlinkFor(home('.npmrc'), secrets('facebook-devserver/.npmrc'));
  await createSymlinkFor(
    home('.bashrc'),
    secrets('facebook-devserver/.bashrc')
  );
  await createSymlinkFor(
    home('.fb-vimrc'),
    secrets('facebook-devserver/.fb-vimrc')
  );
  await createHomeSymlink('bin/remote-yank');
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
await createHomeSymlink('.tmux/tmux.remote.conf');
await createHomeSymlink('.config/fish/config.fish');
await createHomeSymlink('.config/nvim/coc-settings.json');
await createSymlinkFor(home('.config/nvim/init.vim'), dir('.vimrc'));

console.log(
  'Setting rebase to be the default for the master branch on this repo...'
);
await $`git config branch.master.rebase true`;
