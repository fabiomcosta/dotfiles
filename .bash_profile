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
export_to_path_if_exists $HOME/Sites/android-sdk/tools
export_to_path_if_exists $HOME/Sites/android-sdk/platform-tools

export TERM="xterm-color"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export PATH=$HOME/bin:$PATH
export PATH=`brew --prefix`/share/npm/bin:$PATH
export NODE_PATH=`brew --prefix`/lib/node_modules:$NODE_PATH
export GLB_PROJECTS_ROOT_PATH="/$HOME/Sites/glb"

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
execute_if_exists source `brew --prefix`/bin/virtualenvwrapper.sh

alias solr_start='make start -C ~/Sites/glb/busca-nova-plataforma'
alias solr_stop='make stop -C ~/Sites/glb/busca-nova-plataforma'

alias activemq_start='make start -C ~/Sites/glb/barramento'
alias activemq_stop='make stop -C ~/Sites/glb/barramento'

alias mysql_start='mysqld &'
alias mysql_stop='killall mysqld'

alias stop_all='solr_stop; activemq_stop; selenium stop; mysql_stop'
alias start_all='stop_all; solr_start; activemq_start; selenium start; mysql_start'

alias staging_activate='sudo ${HOME}/Sites/glb/staging-deploy/scripts/staging.sh ativar'
alias staging_deactivate='sudo ${HOME}/Sites/glb/staging-deploy/scripts/staging.sh desativar'

export PYTHONPATH=`brew --prefix`/lib/python:$PYTHONPATH
. `brew --prefix`/etc/profile.d/z.sh

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
