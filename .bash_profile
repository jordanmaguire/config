export HISTTIMEFORMAT='%Y-%b-%d %a %H:%M:%S - '

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Create a POW entry for the current site
function powify() {
  ln -s $PWD ~/.pow/${1:-$(basename $PWD | tr A-Z a-z)}
}

# Color details - http://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
badgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
txtrst='\[\e[0m\]'    # Text Reset

PS1="\n$bldcyn\W $bldpur\$(parse_git_branch): $txtrst"

alias .bash_profile="subl ~/.bash_profile"
alias .gitconfig="subl ~/.gitconfig"

## RAILS SPECIFIC
alias devlog="tail -f -n 100 log/development.log"
alias testlog="tail -f -n 100 log/test.log"
alias be="bundle exec"
alias fuckshitup="rake db:drop db:create db:migrate && rake db:seed db:test:prepare"

## PROJECT SPECIFIC
alias work="cd ~/Work/"

export EDITOR=vi

# For node.js
# see: https://github.com/replit/jsrepl/issues/56
export NODE_PATH=/usr/local/lib/node:/usr/local/lib/node_modules

PATH="~/bin:/usr/local/bin:$PATH"

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Default the directory that is loaded
# Run this alias
work
clear