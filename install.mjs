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

// TODO make 'secrets' a git submodule?
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

await createSymlinkFor(`${HOME}/.vim`, `${DIR}/.vim`);
await createSymlinkFor(`${HOME}/.vimrc`, `${DIR}/.vimrc`);
await createSymlinkFor(`${HOME}/.bash_profile`, `${DIR}/.bash_profile`);
await createSymlinkFor(`${HOME}/.ackrc`, `${DIR}/.ackrc`);
await createSymlinkFor(`${HOME}/.ripgreprc`, `${DIR}/.ripgreprc`);
await createSymlinkFor(`${HOME}/.tmux.conf`, `${DIR}/.tmux.conf`);
await createSymlinkFor(
`${HOME}/.config/alacritty/alacritty.yml`,
`${DIR}/.config/alacritty/alacritty.yml`
);
await createSymlinkFor(
`${HOME}/.config/fish/config.fish`,
`${DIR}/.config/fish/config.fish`
);
await createSymlinkFor(`${HOME}/.config/karabiner`, `${DIR}/.config/karabiner`);
await createSymlinkFor(
`${HOME}/.config/nvim/coc-settings.json`,
`${DIR}/.config/nvim/coc-settings.json`
);
await createSymlinkFor(`${HOME}/.config/nvim/init.vim`, `${DIR}/.vimrc`);

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
