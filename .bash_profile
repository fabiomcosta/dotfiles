export_if_exists(){
    if [ -e "$2" ]; then
        export $1="$2:$(eval echo $`echo $1`)"
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

findd() {
    find . -name "*$1*"
}

# aliases
alias grep='grep --color'
alias egrep='egrep --color'
alias la='ls -a'
alias ll='ls -l'
alias uuid='python -c "import sys;import uuid;sys.stdout.write(str(uuid.uuid4()))" | pbcopy'
# git
alias gs='git status'
alias gd='git diff'
# remove .svn folders
alias svnrm='find . -type d -name .svn | xargs rm -rf'
# remove *.pyc files
alias pycrm='find . -name "*.pyc" -delete'
alias myip="ifconfig | grep 192 | awk '{print \$2}' | pbcopy"
# endaliases

export TERM="xterm-color"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export EDITOR=`which vim`
BREW_PREFIX=`brew --prefix`

export_if_exists PATH $BREW_PREFIX/bin
export_if_exists PATH $BREW_PREFIX/sbin
export_if_exists PATH $HOME/bin

# node
export_if_exists NODE_PATH $BREW_PREFIX/lib/node_modules
export_if_exists PATH      $BREW_PREFIX/share/npm/bin
execute_if_exists source $HOME/.nvm/nvm.sh

# python3 with less priority than python2
export_if_exists PATH       $BREW_PREFIX/share/python3

# python
export_if_exists PYTHONPATH $BREW_PREFIX/lib/python2.7/site-packages
export_if_exists PATH       $BREW_PREFIX/share/python
    # virtualenv
    export WORKON_HOME=$HOME/.virtualenvs
    execute_if_exists source $BREW_PREFIX/share/python/virtualenvwrapper.sh

# ruby
export_if_exists PATH    `brew --prefix ruby`/bin

# git
execute_if_exists source $BREW_PREFIX/etc/bash_completion.d/git-completion.bash

# z
execute_if_exists source $BREW_PREFIX/etc/profile.d/z.sh

# yipit
export YIPIT_PATH=$HOME/Sites/yipit/yipit-env/yipit
execute_if_exists source $YIPIT_PATH/conf/yipit_bash_profile

#buster
#BUSTER_PATH=$HOME/Sites/other/buster
#export_if_exists NODE_PATH   $BUSTER_PATH
#export_if_exists PATH        $BUSTER_PATH/buster/bin

#bash completion
execute_if_exists . `brew --prefix`/etc/bash_completion


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

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end
