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

await $`
# Based on https://github.com/mathiasbynens/dotfiles/blob/master/.osx
# Decreases the delay repetition on keyboard
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=' '
`;
