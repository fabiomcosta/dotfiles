#!/usr/bin/env bash

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

# Hides Menubar
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Hides Dock
defaults write com.apple.dock autohide -bool true && killall Dock

# Disables "Correct spelling automatically"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable the sound effects on boot
# Very sounds like zx is buggy while asking for password, disabling this for now.
# sudo nvram SystemAudioVolume=' '

# Disables unnecessary/unused daemons
sudo launchctl disable system/com.apple.tipsd
sudo launchctl disable system/com.apple.newsd
