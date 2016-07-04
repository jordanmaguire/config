# Include the bash profile colours
. ~/.bash_open_in_sapphire
. ~/.bash_profile_colours

function open_pow {
  open http://`basename $PWD`.dev/
}

function parse_git_branch_for_PS1 {
  # Get branch name:
  #  git symbolic-ref --short HEAD
  #
  # Ignores errors (EG: Not in a git repo):
  #   2> /dev/null
  #
  # Wrap the output in brackets for display in PS1
  #   sed -e 's/\(.*\)/(\1)/'
  git symbolic-ref --short HEAD 2> /dev/null | sed -e 's/\(.*\)/(\1)/'
}

# Create a POW entry for the current site
function powify() {
  ln -s $PWD ~/.pow/${1:-$(basename $PWD | tr A-Z a-z)}
}

function smart_git_push() {
  git push --set-upstream origin `git symbolic-ref --short HEAD`
}

PS1="\n$bldcyn\W $bldpur\$(parse_git_branch_for_PS1): $txtrst"

alias .bash_profile="subl ~/.bash_profile"
alias .gitconfig="subl ~/.gitconfig"

alias sapphire="open_in_sapphire"
alias prs="open https://github.com/pulls?user=thefrontiergroup"

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
alias gbr="git branch"
alias gp="git push"
alias gpu="smart_git_push" # git push upstream
alias gco="git_smart_checkout"
alias gsp="git_smart_prune"

export EDITOR=vi

# For node.js, see: https://github.com/replit/jsrepl/issues/56
export NODE_PATH=/usr/local/lib/node:/usr/local/lib/node_modules

# Required for homebrew
PATH="/usr/local/bin:$PATH:/usr/local/sbin"
# Requires for subl
PATH="~/bin:$PATH"

# Required for RVM
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Required for 'bash-completion'
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
