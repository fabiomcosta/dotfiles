export TERM="xterm-color"
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export EDITOR="mvim"
export PATH=/Users/fabio/bin:$PATH
export PATH=/usr/local/share/npm/bin:$PATH
export PATH=/usr/local/Cellar/node/0.4.3/bin:$PATH
export GLB_PROJECTS_ROOT_PATH="/Users/fabio/Sites/glb"
export PYTHONPATH=/usr/local/lib/python2.6/site-packages:$PYTHONPATH

alias la='ls -a'
alias ll='ls -l'
alias yui='java -jar ${HOME}/bin/yui.jar --charset=utf8'
alias closurec='java -jar ${HOME}/bin/compiler.jar'
alias uuid='python -c "import sys;import uuid;sys.stdout.write(str(uuid.uuid4()))" | pbcopy'

# remove .svn folders
alias svnrm='find . -type d -name .svn | xargs rm -rf'
# remove *.pyc files
alias pycrm='find . -name "*.pyc" -delete'

#export PATH=/usr/local/Cellar/python/2.7/bin:$PATH
#export PATH=/usr/local/bin:/usr/local/sbin:$PATH
#export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

source ~/.git-completion.bash
source ~/.django_bash_completion

alias solr_start='make start -C ~/Sites/glb/busca-nova-plataforma'
alias solr_stop='make stop -C ~/Sites/glb/busca-nova-plataforma'

alias ion_start='cd ~/Sites/glb/dynamo-core; ion run'

alias activemq_start='make start -C ~/Sites/glb/barramento'
alias activemq_stop='make stop -C ~/Sites/glb/barramento'

alias mysql_start='mysqld &'
alias mysql_stop='killall mysqld'

alias stop_all='solr_stop; activemq_stop; selenium stop; mysql_stop'
alias start_all='stop_all; solr_start; activemq_start; selenium start; mysql_start'

start_slow() {
    sudo ipfw pipe 1 config bw 100KByte/s
    sudo ipfw add 1 pipe 1 src-port $1
}

stop_slow() {
    sudo ipfw delete 1
}


# Git support functions for Evil Tomato
# Mohit Cheppudira <mohit@muthanna.com>

# Returns "*" if the current git branch is dirty.
function evil_git_dirty {
    [[ $(git diff --shortstat 2>/dev/null | tail -n1) != "" ]] && echo "*"
}

# Get the current git branch name (if available)
evil_git_prompt() {
    local ref=$(git branch 2>/dev/null | grep '^\*' | cut -b 3- | sed 's/[\(\)]//g')
    if [ "$ref" != "" ]; then
        echo " ($ref$(evil_git_dirty))"
    fi
}

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
export PS1="$RED[\$(date +%H:%M)]$NOCOLOR $LIGHTBLUE\u$NOCOLOR@$LIGHTYELLOW\h $NOCOLOR[/\$(PWD)]$LIGHTCYAN\$(evil_git_prompt)$NOCOLOR \$ "
export PS2="> "
