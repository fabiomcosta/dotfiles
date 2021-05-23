#!/usr/bin/env node

import { $, cd } from 'zx';
import os from 'os';
import path from 'path';
import fs from 'fs/promises';
import { applyTemplate } from './src/apply_template.mjs';
import { isDirectory, createSymlinkFor } from './src/fs.mjs';
import { OK, WARN, ERROR, hl } from './src/log.mjs';
import { commandExists } from './src/shell.mjs';
import { dir, home, DIR, HOME } from './src/path.mjs';

const IS_MACOS = os.platform() === 'darwin';

// THIS SHOULD BE FOR MY OWN MACHINE ONLY
// OR MAYBE APPLY DIFFERENT TEMPLATES FOR EACH MACHINE
await applyTemplate(dir('.gitconfig'), home('.gitconfig'));

const SECRETS_DIR = dir('..', 'secrets');
if (!(await isDirectory(SECRETS_DIR))) {
  console.log('Cloning secrets repo...');
  await $`git clone https://github.com/fabiomcosta/secrets.git ${SECRETS_DIR}`;
} else {
  OK`${hl('secrets')} already available.`;
}

if (IS_MACOS) {
  await import('./macos.mjs');
}

createSymlinkFor(`${HOME}/.vim`, `${DIR}/vim/.vim`);
createSymlinkFor(`${HOME}/.vimrc`, `${DIR}/vim/.vimrc`);
createSymlinkFor(`${HOME}/.bash_profile`, `${DIR}/.bash_profile`);
createSymlinkFor(`${HOME}/.ackrc`, `${DIR}/.ackrc`);
createSymlinkFor(`${HOME}/.ripgreprc`, `${DIR}/.ripgreprc`);
createSymlinkFor(`${HOME}/.tmux.conf`, `${DIR}/.tmux.conf`);
createSymlinkFor(
  `${HOME}/.config/alacritty/alacritty.yml`,
  `${DIR}/alacritty.yml`
);
createSymlinkFor(`${HOME}/.config/fish/config.fish`, `${DIR}/fish/config.fish`);
createSymlinkFor(`${HOME}/.config/karabiner`, `${DIR}/karabiner`);
createSymlinkFor(`${HOME}/.config/nvim/init.vim`, `${DIR}/vim/.vimrc`);
createSymlinkFor(
  `${HOME}/.config/nvim/coc-settings.json`,
  `${DIR}/vim/.vim/coc-settings.json`
);

const keyboardPath = home('.keyboard');
if (await isDirectory(keyboardPath)) {
  OK`${hl('keyboard')} already available.`;
} else {
  console.log('Cloning keyboard repo...');
  await $`git clone https://github.com/fabiomcosta/keyboard.git ${keyboardPath}`;
  cd(keyboardPath);
  await $`./script/setup`;
  cd(DIR);
}

console.log(
  'Setting rebase to be the default for the master branch on this repo...'
);
await $`git config branch.master.rebase true`;
