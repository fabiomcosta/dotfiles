#!/usr/bin/env node

import { $, cd } from 'zx';
import os from 'os';
import path from 'path';
import fs from 'fs/promises';
import { applyTemplate } from './src/apply_template.mjs';
import { isDirectory, createSymlinkFor, createHomeSymlink } from './src/fs.mjs';
import { OK, WARN, ERROR, hl } from './src/log.mjs';
import { commandExists } from './src/shell.mjs';
import { dir, home, DIR, HOME } from './src/path.mjs';

const IS_MACOS = os.platform() === 'darwin';
const IS_REMOTE_SSH = Boolean(process.env.SSH_CLIENT || process.env.SSH_TTY);

// THIS SHOULD BE FOR MY OWN MACHINE ONLY
// OR MAYBE APPLY DIFFERENT TEMPLATES FOR EACH MACHINE
await applyTemplate(dir('.gitconfig'), home('.gitconfig'));

if (IS_MACOS) {
  await import('./macos.mjs');
}

await createHomeSymlink('.vim');
await createHomeSymlink('.vimrc');
await createHomeSymlink('.bash_profile');
await createHomeSymlink('.ackrc');
await createHomeSymlink('.ripgreprc');
await createHomeSymlink('.tmux.conf');
await createHomeSymlink('.config/alacritty/alacritty.yml');
await createHomeSymlink('.config/fish/config.fish');
await createHomeSymlink('.config/karabiner');
await createHomeSymlink('.config/nvim/coc-settings.json');
await createSymlinkFor(`${HOME}/.config/nvim/init.vim`, `${DIR}/.vimrc`);

// These configure some keyboard related things, and it does't make sense to
// install it on any remote machines.
if (!IS_REMOTE_SSH) {
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
}

console.log(
  'Setting rebase to be the default for the master branch on this repo...'
);
await $`git config branch.master.rebase true`;
