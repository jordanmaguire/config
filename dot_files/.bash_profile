# Include the bash profile colours
. ~/.bash_profile_colours

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


function smart_git_push() {
  git push --set-upstream origin `git symbolic-ref --short HEAD`
}

PS1="\n$bldcyn\W $bldpur\$(parse_git_branch_for_PS1): $txtrst"

alias .bash_profile="subl ~/.bash_profile"
alias .gitconfig="subl ~/.gitconfig"

alias findp="ps aux | grep "
# See . files using ls
alias ls="ls -ah"

## RAILS SPECIFIC
alias devlog="tail -f -n 200 log/development.log"
alias testlog="tail -f -n 200 log/test.log"
alias be="bundle exec"
alias bo="EDITOR=subl bundle open"
alias bu="bundle update"
alias findroutes="rails routes | grep"
alias fuckshitup="be rake db:drop db:create db:migrate && be rake db:seed db:test:prepare"
# alias fsu="fuckshitup"
alias hl="heroku local"
alias schema="rails db:schema:dump"

## PROJECT SPECIFIC
alias app="cd ~/src/interexchange/app"
alias work="cd ~/Work/"

## GIT
alias ga="git add"
alias gbr="git branch"
alias gco="git_smart_checkout"
alias gp="git push"
alias gpl="git pull"
alias gpu="smart_git_push" # git push upstream
alias grc="git rebase --continue"
alias gsd="git_smart_branch_destroy"
alias gsm="git_smart_merge"
alias gsp="git_smart_prune"
alias gst="git status"
alias diffupstream="git diff @{upstream}"

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

# Required for direnv
eval "$(direnv hook bash)"

export NVM_DIR="$HOME/.nvm"
  . "/usr/local/opt/nvm/nvm.sh"

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export NODE_VERSION_PREFIX=v
export NODE_VERSIONS=~/.nvm/versions/node
export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
