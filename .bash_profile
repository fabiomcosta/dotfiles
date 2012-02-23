export_to_path_if_exists(){
    if [ -e "$1" ]; then
        export PATH="$1:$PATH"
    fi
}

execute_if_exists(){
    if [ -e "$2" ]; then
        $1 "$2"
    fi
}

start_slow() {
    sudo ipfw pipe 1 config bw 100KByte/s
    sudo ipfw add 1 pipe 1 src-port $1
}

stop_slow() {
    sudo ipfw delete 1
}

#adds android-sdk to our path
#export_to_path_if_exists $HOME/Sites/android-sdk/tools
#export_to_path_if_exists $HOME/Sites/android-sdk/platform-tools

export TERM="xterm-color"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export_to_path_if_exists `brew --prefix`/bin
export_to_path_if_exists $HOME/bin

export NODE_PATH=`brew --prefix`/lib/node_modules:$NODE_PATH
export_to_path_if_exists `brew --prefix`/share/npm/bin
execute_if_exists source $HOME/.nvm/nvm.sh

alias grep='grep --color'
alias egrep='egrep --color'
alias la='ls -a'
alias ll='ls -l'
alias yui='java -jar $HOME/bin/yui.jar --charset=utf8'
alias closurec='java -jar $HOME/bin/compiler.jar'
alias uuid='python -c "import sys;import uuid;sys.stdout.write(str(uuid.uuid4()))" | pbcopy'

# remove .svn folders
alias svnrm='find . -type d -name .svn | xargs rm -rf'
# remove *.pyc files
alias pycrm='find . -name "*.pyc" -delete'

export WORKON_HOME=$HOME/.virtualenvs
export PYTHONPATH=`brew --prefix`/lib/python:$PYTHONPATH
export_to_path_if_exists `brew --prefix`/share/python

execute_if_exists source `brew --prefix`/etc/bash_completion.d/git-completion.bash
execute_if_exists source `brew --prefix`/etc/profile.d/z.sh
execute_if_exists source `brew --prefix`/share/python/virtualenvwrapper.sh

function PWD {
    pwd | awk -F\/ '{if (NF>4) print "...", $(NF-2), $(NF-1), $(NF); else if (NF>3) print $(NF-2),$(NF-1),$(NF); else if (NF>2) print $(NF-1),$(NF); else if (NF>1) print $(NF);}' | sed -e 's# #\/#g'
}

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
LIGHTBLUE="\[\033[1;34m\]"
LIGHTYELLOW="\[\033[1;33m\]"
LIGHTCYAN="\[\033[1;36m\]"
NOCOLOR="\[\e[0m\]"
export PS1="$RED[\$(date +%H:%M)]$NOCOLOR $LIGHTBLUE\u$NOCOLOR@$LIGHTYELLOW\h $NOCOLOR[/\$(PWD)]$LIGHTCYAN\$(__git_ps1)$NOCOLOR\n\$ "
export PS2="> "

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end
