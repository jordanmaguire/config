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

function dbreset() {
  DB="iex_app_$(git symbolic-ref --short HEAD)" rake db:drop db:create && rake db:migrate
}

function get_backup_of_production() {
  mv tmp/iex-app.dump tmp/iex-app.dump.old
  heroku pg:backups:capture -a iex-app
  curl -o tmp/iex-app.dump `heroku pg:backups:public-url -a iex-app`
}

function smart_git_push() {
  git push --set-upstream origin `git symbolic-ref --short HEAD`
}

function newpr() {
  open https://github.com/interexchange/app/pull/new/`git symbolic-ref --short HEAD`
}

function openpr() {
  open https://github.com/interexchange/app/pull/`git symbolic-ref --short HEAD`
}

PS1="\n$bldcyn\W $bldpur\$(parse_git_branch_for_PS1): $txtrst"

alias .bash_profile="subl ~/.bash_profile"
alias .gitconfig="subl ~/.gitconfig"

alias findp="ps aux | grep "
# See . files using ls
alias ls="ls -ah"

## RAILS SPECIFIC
alias be="bundle exec"
alias bo="EDITOR=subl bundle open"
alias copme="git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs rubocop"
alias cucu="cucumber"
alias findroutes="rails routes | grep "
alias fr="findroutes"
alias fs="foreman start -m web=1,resque=1,watch-styles=1,webpack=1"
alias migrate="rake db:migrate"
alias schema="rails db:schema:dump"

## PROJECT SPECIFIC
alias app="cd ~/src/interexchange/app"
alias reseed="USE_BRANCH_DB=true rake db:drop db:create && rake db:migrate && rake db:disable_logging db:environment_with_class_caching db:start_time db:seed db:end_time"

## GIT
alias commits_since_master="git log master..HEAD --oneline"
alias csm="commits_since_master"
alias ga="git add"
alias gbr="git branch"
alias gco="git_smart_checkout"
alias gcom="git co master"
alias gcop="git co -"
alias gp="git push"
alias gpl="git pull"
alias gpu="smart_git_push" # git push upstream
alias gra="git rebase --abort"
alias grc="git rebase --continue"
alias grs="git rebase --skip"
alias gsd="git_smart_branch_destroy"
alias gsm="git_smart_merge"
alias gsp="git_smart_prune"
alias gst="git status"
alias diffupstream="git diff @{upstream}"

export EDITOR=vi

# Required for Homebrew
PATH="/usr/local/bin:$PATH:/usr/local/sbin"
# Requires for subl
PATH="~/bin:$PATH"

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

# Required for RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
