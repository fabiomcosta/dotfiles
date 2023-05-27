import { $ } from 'zx';
import { commandExists, $swallow, $silent } from './src/shell.mjs';
import { dir } from './src/path.mjs';
import { OK } from './src/log.mjs';

console.log('Executing the OSX specific setup...');

await $swallow`xcode-select --install`;
// This install even macos updates...
// I think I'll just avoid it...
// await $`softwareupdate --all --install --force`;

if (!(await commandExists('brew'))) {
  console.log('Installing brew...');
  await $`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`;
}

console.log('brew update... (can take a while)');
await $`brew bundle --verbose`;
await $`brew cleanup`;

// fish
const brewPrefix = (await $silent`brew --prefix`).stdout.trim();
const fishPath = `${brewPrefix}/bin/fish`;

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

// Install fzf key bindings like ctrl+r
const fzfInstallPath = `${brewPrefix}/opt/fzf/install`;
await $`${fzfInstallPath} --no-zsh --no-bash --key-bindings --completion --update-rc`;

await $`./macos.sh`;
