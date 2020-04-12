#!/usr/bin/env fish

function command_exists
  set cmd $argv[1]
  type -q $cmd
end

set -x EDITOR (which vim)
if command_exists mvim
  alias vim='mvim -v'
  alias vi='mvim -v'
end

if command_exists rg && not command_exists ack
  alias ack='rg'
end

set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'

alias la='ls -a'
alias ll='ls -l'
alias simpleserver='python -m SimpleHTTPServer'
alias d8="$DEV/tp/v8/out/Debug/d8"
alias cat='bat'
alias ping='prettyping --nolegend'
alias help='tldr'
alias oni2="$HOME/Applications/Onivim2.app/Contents/MacOS/Oni2"


## colors
set -x TERM xterm-256color
set -x CLICOLOR 1
set -x LSCOLORS ExFxCxDxBxegedabagacad

if command_exists brew
  ## brew
  set -x BREW_PREFIX (brew --prefix)

  ## ruby
  set -x PATH (brew --prefix ruby)"/bin" $PATH

  ## node
  set -x NODE_PATH $BREW_PREFIX/lib/node_modules $NODE_PATH
  set -x PATH $BREW_PREFIX/share/npm/bin  $PATH

  set -x PATH $BREW_PREFIX/bin $PATH
  set -x PATH $BREW_PREFIX/sbin $PATH

  set -x PKG_CONFIG_PATH $PKG_CONFIG_PATH (brew --prefix libffi)"/lib/pkgconfig"

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

# prepends depot_tools from the chromium project
set -x PATH $DEV/other/depot_tools $PATH

# prepends my bin folder to the path
set -x PATH $HOME/bin $PATH

# prepends my gdrive/code/gd/bin folder to the path
set -x PATH $HOME/gdrive/code/gd/bin $PATH

# set -x ANDROID_SDK_ROOT "/usr/local/share/android-sdk"
# set -x ANDROID_HOME "$ANDROID_SDK_ROOT"
eval (starship init fish)

# fnm
fnm env --multi --use-on-cd | source
