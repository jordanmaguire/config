# Shared by the host's zsh and the dev container's bash, so it must stay valid in both.
# JM_CONFIG_DIR is this repository's folder; whoever sources this file sets it first.

# One prompt everywhere. Starship reads this on every prompt, so it works even where
# `starship init` ran earlier, and ~/.config is root-owned in the dev container.
export STARSHIP_CONFIG="$JM_CONFIG_DIR/starship.toml"

# -A show folders starting with ., but not the entries for "." and "..", which will be in every
#    folder. This is different from -a, which will show "." and "..".
# -F show a trailing / for directories helping to visually indicate folders. The -G option
#    will also show them as blue. Show * for executables. There are other symbols but they
#    aren't too relevant to my workflow.
alias ls="ls -AF --color"

# Command line tool shortcuts. I'll be cold in the ground before I type a full command. I need to
# save my finger bones for deadlifts and video games I can't waste them on keystrokes here.
alias bs="./bin/start"
alias cucu="cucumber"

# Git
# Short for "commits since master".
alias csm="git log master..HEAD --oneline"
alias ga="git add"
alias gcop="git checkout -"
alias gd="git diff"
alias gl="git log"
alias gp="git push"
alias gpl="git pull"
alias gra="git rebase --abort"
alias grc="git rebase --continue"
alias grs="git rebase --skip"
alias grb="git rebase --committer-date-is-author-date"
alias gri="git rebase -i"
alias grim="git rebase -i master"
alias gst="git status -su"
alias diffupstream="git diff @{upstream}"

# Git Tools - I named these a decade ago. I don't think the names are accurate enough, but
# I'm not going to waste time renaming them. They need Ruby 3.1 or newer.
alias gbr="$JM_CONFIG_DIR/git_tools/git_smart_branch.rb"
alias gsl="$JM_CONFIG_DIR/git_tools/git_smart_log.rb"
alias gsd="$JM_CONFIG_DIR/git_tools/git_smart_branch_destroy.rb"
# gco is a function rather than an alias so that picking a branch checked out in another worktree
# can cd you into that worktree, which the script can't do to its parent shell. Give it a branch
# name to skip the prompt.
unalias gco 2>/dev/null
gco() {
  local cd_file destination
  cd_file=$(mktemp)
  GCO_CD_FILE="$cd_file" "$JM_CONFIG_DIR/git_tools/git_smart_checkout.rb" "$@"
  destination=$(cat "$cd_file")
  rm -f "$cd_file"
  if [ -n "$destination" ]; then
    cd "$destination" || return
  fi
}
# Same as picking master in gco, so from a linked worktree it takes you back to the main one.
unalias gcom 2>/dev/null
gcom() {
  gco master
}
# TODO: I have no idea where this tool went. I evidently deleted the code for it.
#       I can see use for this - maybe it shows the branches in your current tree first and then
#       other branches after.
# alias grib="git_smart_rebase"
