#!/usr/bin/env node

import { $, cd } from 'zx';
import os from 'os';
import path from 'path';
import fs from 'fs/promises';
import { applyTemplate } from './src/apply_template.js';
import {
  isDirectory,
  isSymlink,
  createSymlinkFor,
  createHomeSymlink,
} from './src/fs.js';
import { OK, WARN, ERROR, hl } from './src/log.js';
import { commandExists, $silent } from './src/shell.js';
import { dir, home, secrets, DIR } from './src/path.js';
import { setupCron } from './src/cron.js';

async function main() {
  const IS_MACOS = os.platform() === 'darwin';
  const IS_LINUX = os.platform() === 'linux';
  const IS_REMOTE_SSH = Boolean(process.env.SSH_CLIENT || process.env.SSH_TTY);

  const hostname = (await $silent`hostname`).stdout.trim();
  const IS_WORK_MACHINE =
    hostname.endsWith('facebook.com') || hostname.endsWith('fbinfra.net');

  await $`git submodule update --init`;

  if (IS_WORK_MACHINE) {
    await applyTemplate(
      secrets('facebook-devserver/.gitconfig'),
      home('.gitconfig')
    );
  } else {
    await createHomeSymlink('.gitconfig');
  }

  if (IS_MACOS) {
    await import('./macos.js');
  }

  if (IS_WORK_MACHINE) {
    await import('./secrets/facebook-devserver/install.js');
  } else if (IS_LINUX) {
    await import('./linux.js');
  }

  if (IS_WORK_MACHINE) {
    // We actually want to do this before `npm i` on install.sh... tricky...
    await createSymlinkFor(
      home('.npmrc'),
      secrets('facebook-devserver/.npmrc')
    );
    await createSymlinkFor(
      home('.bashrc'),
      secrets('facebook-devserver/.bashrc')
    );
    await createSymlinkFor(
      home('.fb-vimrc'),
      secrets('facebook-devserver/.fb-vimrc')
    );
    await createSymlinkFor(
      home('bin/open'),
      secrets('facebook-devserver/bin/open')
    );
    await createSymlinkFor(
      home('bin/xdg-open'),
      secrets('facebook-devserver/bin/xdg-open')
    );
    await createSymlinkFor(
      home('bin/hg-rebase-my-commits'),
      secrets('facebook-devserver/bin/hg-rebase-my-commits')
    );
    await createSymlinkFor(
      home('bin/pbcopy'),
      secrets('facebook-devserver/bin/pbcopy')
    );
  }

  if (IS_MACOS && !IS_REMOTE_SSH) {
    const keyboardHomePath = home('.keyboard');
    if (await isSymlink(keyboardHomePath)) {
      OK`${hl('keyboard')} was already installed.`;
    } else {
      await createHomeSymlink('.keyboard');
      cd(keyboardHomePath);
      await $`./script/setup`;
      cd(DIR);
    }

    await setupCron();
    await createHomeSymlink('.config/karabiner');
    await createHomeSymlink('.config/karabiner.edn');
    await createHomeSymlink('.config/alacritty/alacritty.toml');
    await createHomeSymlink('.config/rio');
    await createHomeSymlink('.config/ghostty');
    await createHomeSymlink('Applications/VimProtocolHandler.app');
  }

  await createSymlinkFor(
    home('bin/local-file-proxy-for-od'),
    secrets('facebook-devserver/bin/local-file-proxy-for-od')
  );
  await createSymlinkFor(
    home('bin/dev-with-fileproxy'),
    secrets('facebook-devserver/bin/dev-with-fileproxy')
  );

  await createHomeSymlink('.vim');
  await createHomeSymlink('.vimrc');
  await createHomeSymlink('.bash_profile');
  await createHomeSymlink('.ripgreprc');
  await createHomeSymlink('.tmux.conf');
  await createHomeSymlink('.tmux/tmux.remote.conf');
  await createHomeSymlink('.tmux/tmux.remote.after.conf');
  await createHomeSymlink('.config/fish/config.fish');
  await createHomeSymlink('.config/nvim/lua');
  await createHomeSymlink('.config/nvim/autoload');
  await createHomeSymlink('.config/nvim/ftdetect');
  await createHomeSymlink('.config/stylua.toml');
  await createSymlinkFor(home('.config/nvim/init.vim'), dir('.vimrc'));

  console.log(
    'Setting rebase to be the default for the master branch on this repo...'
  );
  await $`git config branch.master.rebase true`;
}

main()
  .then(process.exit)
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
