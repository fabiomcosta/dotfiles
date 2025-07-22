import { $ } from 'zx';
import { commandExists, $swallow, $silent } from './src/shell.js';
import { dir } from './src/path.js';
import { OK } from './src/log.js';

if (!(await commandExists('apt-get'))) {
  console.log(
    'apt-get not available, and other installers are not support. Silently ignoring Linux setup...'
  );
  process.exit(0);
}

console.log('Executing the Linux specific setup...');

if (!(await commandExists('starship'))) {
  await $`curl -sS https://starship.rs/install.sh | sh`;
} else {
  OK`starship already installed.`;
}

await $`sudo apt-get update`;
await $`sudo apt-get install -y neovim tmux git fish rsync ripgrep bat`;

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
