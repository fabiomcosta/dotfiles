import { $ } from 'zx';
import { commandExists, $swallow, $silent } from './src/shell.js';
import { dir } from './src/path.js';
import { OK } from './src/log.js';

async function brew() {
  if (!(await commandExists('brew'))) {
    return false;
  }
  console.log('brew update... (can take a while)');
  await $`brew bundle --verbose`;
  await $`brew cleanup`;
  return true;
}

async function aptGet() {
  if (!(await commandExists('apt-get'))) {
    return false;
  }
  console.log('apt-get update... (can take a while)');
  await $`sudo apt-get update`;
  await $`sudo apt-get install -y neovim tmux git fish rsync ripgrep bat`;
  return true;
}

async function starship() {}

async function main() {
  console.log('Executing the Linux specific setup...');

  if (await aptGet()) {
    // Installing staship "manually" as there is no option with apt-get
    if (!(await commandExists('starship'))) {
      await $`curl -sS https://starship.rs/install.sh | sh`;
    } else {
      OK`starship already installed.`;
    }
  } else {
    console.log('apt-get not available, trying brew...');
    if (!(await brew())) {
      console.log('brew not available, silently ignoring Linux setup...');
      return;
    }
  }

  // fish
  const fishPath = (await $silent`which fish`).stdout.trim();

  const isFishInstalled = Boolean(
    (await $swallow`grep ${fishPath} /etc/shells`).stdout
  );
  if (!isFishInstalled) {
    console.log('Setting up fish...');
    await $`echo ${fishPath} | sudo tee -a /etc/shells`;
    OK`fish installed.`;
  } else {
    OK`fish already installed.`;
  }

  if (process.env.SHELL !== fishPath) {
    console.log('Defining fish as the default shell...');
    await $`chsh -s ${fishPath}`;
    OK`fish is now the default shell.`;
  } else {
    OK`fish is already the default shell.`;
  }
}

await main();
