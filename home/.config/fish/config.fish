#!/usr/bin/env fish
#
function command_exists
  set cmd $argv[1]
  type -q $cmd
end

set CURRENT_FILENAME_PATH (realpath (status --current-filename))
# this file's path looks like this and, and we want the path for the "dotfiles"
# folder:
# dotfiles/home/.config/fish/config.fish
set DOTFILES_PATH (dirname (dirname (dirname (dirname $CURRENT_FILENAME_PATH))))
set SECRETS_PATH "$DOTFILES_PATH/secrets"

source "$SECRETS_PATH/config.fish"

set -x OPENAI_API_KEY (cat $SECRETS_PATH/chatgpt_neovim.key)

# On Meta machines, a warning message is shown when running the brew command
# and the PATH doesn't have one of the alternative paths inside it already.
# So we have to set it before calling `brew --prefix`.
if test -d $HOME/homebrew
  set -x PATH $HOME/homebrew/bin $PATH
  set -x PATH $HOME/homebrew/sbin $PATH
end

if command_exists nvim
  alias vim='nvim'
  alias vi='nvim'
  set -x EDITOR (which nvim)
else
  set -x EDITOR (which vim)
end

alias la='ls -a'
alias ll='ls -l'
alias simpleserver='python -m SimpleHTTPServer'
alias oni2="$HOME/Applications/Onivim2.app/Contents/MacOS/Oni2"
if command_exists bat
  alias cat='bat'
end
if command_exists prettyping
  alias ping='prettyping --nolegend'
end
if command_exists tldr
  alias help='tldr'
end
if command_exists fwdproxy-config
  alias with-proxy='env (fwdproxy-config --format=sh curl)'
end

# hide fish welcome message
set fish_greeting ''

## colors
set -x TERM xterm-256color
set -x CLICOLOR 1
set -x LSCOLORS ExFxCxDxBxegedabagacad

if command_exists brew

  ## brew
  set -x BREW_PREFIX (brew --prefix)

  ## ruby
  set -x PATH $BREW_PREFIX/opt/ruby/bin $PATH

  ## node
  set -x NODE_PATH $BREW_PREFIX/lib/node_modules $NODE_PATH
  set -x PATH $BREW_PREFIX/share/npm/bin $PATH

  if ! test -d $HOME/homebrew
    set -x PATH $BREW_PREFIX/bin $PATH
    set -x PATH $BREW_PREFIX/sbin $PATH
  end

  set -x PKG_CONFIG_PATH $PKG_CONFIG_PATH $BREW_PREFIX/opt/libffi/lib/pkgconfig

  # rust (rustup)
  set -x PATH $PATH $BREW_PREFIX/opt/rustup/bin
end


# do not create .pyc files
set -x PYTHONDONTWRITEBYTECODE x

if command_exists pyenv
  set -x PYTHON_CONFIGURE_OPTS "--enable-framework"
  status --is-interactive; and . (pyenv init -|psub)
  if command_exists pyenv-virtualenv-init
    status --is-interactive; and . (pyenv virtualenv-init -|psub)
  end
end

# ripgrep
set -x RIPGREP_CONFIG_PATH "$HOME/.ripgreprc"

# fzf
set -x FZF_DEFAULT_COMMAND "rg --files --hidden --follow --glob='!.git/*'"

# prepends .cargo folder from rust
set -x PATH $HOME/.cargo/bin $PATH

# prepends my bin folder to the path
set -x PATH $HOME/.local/bin $PATH
set -x PATH $HOME/bin $PATH

# prepends my gdrive/code/gd/bin folder to the path
set -x PATH $HOME/gdrive/code/gd/bin $PATH

# Java
# set -x JAVA_HOME "(/usr/libexec/java_home -v 11)"

# Android DEV
#
# set -x ANDROID_NDK "/opt/android_ndk"
# set -x ANDROID_NDK_REPOSITORY $ANDROID_NDK
# set -x ANDROID_NDK_ROOT "$ANDROID_NDK/r17c"
# set -x ANDROID_SDK "/opt/android_sdk"
# set -x ANDROID_SDK_ROOT $ANDROID_SDK
# set -x ANDROID_HOME $ANDROID_SDK

# You'll need `fisher install edc/bass` before this.
if command_exists bass
  bass 'source $HOME/.waandroid/env.sh'
  set -x PATH $JAVA_HOME/bin $PATH
  set -x PATH $ANDROID_HOME/emulator $PATH
  set -x PATH $ANDROID_HOME/tools $PATH
  set -x PATH $ANDROID_HOME/tools/bin $PATH

  set -x NDK_CCACHE "/usr/local/bin/ccache"
  set -x CCACHE_DIR "$HOME/.ccache"
  set -x USE_CCACHE 1
end

if command_exists starship
  eval (starship init fish)
end

if command_exists fnm
  fnm env --use-on-cd | source
end

if command_exists direnv
  eval (direnv hook fish)
end
