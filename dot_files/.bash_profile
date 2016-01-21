# Include the bash profile colours
. ~/.bash_profile_colours

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Create a POW entry for the current site
function powify() {
  ln -s $PWD ~/.pow/${1:-$(basename $PWD | tr A-Z a-z)}
}

PS1="\n$bldcyn\W $bldpur\$(parse_git_branch): $txtrst"

alias .bash_profile="subl ~/.bash_profile"
alias .gitconfig="subl ~/.gitconfig"

# See . files using ls
alias ls="ls -ah"

## RAILS SPECIFIC
alias devlog="tail -f -n 200 log/development.log"
alias testlog="tail -f -n 200 log/test.log"
alias be="bundle exec"
alias bo="EDITOR=subl bundle open"
alias bu="bundle update"
alias fuckshitup="be rake db:drop db:create db:migrate && be rake db:seed db:test:prepare"
alias fsu="fuckshitup"
alias unfuck_pow="rvm env . > .powenv"

## PROJECT SPECIFIC
alias work="cd ~/Work/"

## GIT
alias gp="git push"

export EDITOR=vi

# For node.js, see: https://github.com/replit/jsrepl/issues/56
export NODE_PATH=/usr/local/lib/node:/usr/local/lib/node_modules

# Required for homebrew
PATH="/usr/local/bin:$PATH:/usr/local/sbin"
# Requires for subl
PATH="~/bin:$PATH"

# Required for RVM
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

work