# Include the bash profile colours
. ~/.bash_profile_colours

function parse_git_branch_for_PS1 {
  # Get branch name:
  #  git symbolic-ref --short HEAD
  #
  # Ignores errors (EG: Not in a git repo):
  #   2> /dev/null
  #
  # Wrap the output in brackets for display in PS1:
  #   sed -e 's/\(.*\)/(\1)/'
  git symbolic-ref --short HEAD 2> /dev/null | sed -e 's/\(.*\)/(\1)/'
}

function cucudiff() {
  cucumber $(git diff --name-only | grep .feature | tr '\r\n' ' ')
}

function get_backup_of_production() {
  mv tmp/iex-app.dump tmp/iex-app.dump.old
  heroku pg:backups:capture -a iex-app
  curl -o tmp/iex-app.dump `heroku pg:backups:public-url -a iex-app`
}

function rubocop_commit() {
  rubocop -a `git diff-tree --no-commit-id --name-only -r $1 | grep "\.rb" | tr '\r\n' ' '`
}

PS1="\n$bldcyn\W $bldpur\$(parse_git_branch_for_PS1): $txtrst"

alias .bash_profile="subl ~/.bash_profile"
alias .gitconfig="subl ~/.gitconfig"

alias findh="history | grep "
alias findp="ps aux | grep "
# See . files using ls
alias ls="ls -ah"

## RAILS SPECIFIC
alias be="bundle exec"
alias bo="EDITOR=subl bundle open"
alias cucu="bundle exec cucumber"
alias findroutes="rails routes | grep "
alias fr="findroutes"

## PROJECT SPECIFIC
alias app="cd ~/src/interexchange/app"
alias passport="cd ~/src/interexchange/passport"
alias fetch="git fetch staging; git fetch production"

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
alias gra="git rebase --abort"
alias grc="git rebase --continue"
alias grs="git rebase --skip"
alias grb="git rebase --committer-date-is-author-date"
alias gri="git rebase -i"
alias grib="git_smart_rebase"
alias grim="git rebase -i master"
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

export NVM_DIR="$HOME/.nvm"
  . "/usr/local/opt/nvm/nvm.sh"

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export NODE_VERSION_PREFIX=v
export NODE_VERSIONS=~/.nvm/versions/node

# Required for RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Ruby turned off deprecations by default. This turns them on so we can resolve them.
#   * https://github.com/ruby/ruby/pull/3273/
export RUBYOPT='-W:deprecated'
