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
const isFishInstalled = Boolean(
  (await $silent`grep '/usr/local/bin/fish' /etc/shells`).stdout
);
if (!isFishInstalled) {
  console.log('Setting up fish...');
  await $`echo /usr/local/bin/fish | sudo tee -a /etc/shells`;
  await $`chsh -s /usr/local/bin/fish`;
  OK`fish setup done.`;
} else {
  OK`fish already installed.`;
}

await $`./macos.sh`;
