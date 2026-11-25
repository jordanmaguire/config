#!/usr/bin/env ruby

require "open3"

require_relative "lib/branch_list"
require_relative "lib/branch_parser"

class BranchDeletionPrompt
  def initialize(branches, main_worktree_path:)
    # The current branch is always "merged into the current branch" but can't be deleted
    @branches = branches.reject { _1.protected? || _1.current? }
    @main_worktree_path = main_worktree_path
  end

  def prompt_to_delete_merged_branches
    worktree_branches, plain_branches = @branches.partition(&:in_other_worktree?)
    kept_worktree_branches = worktree_branches.to_h { [_1, reason_to_keep_worktree(_1)] }.compact
    removable_worktree_branches = worktree_branches - kept_worktree_branches.keys
    display_kept_worktree_branches(kept_worktree_branches)

    if plain_branches.any? || removable_worktree_branches.any?
      if prompt_to_delete_branches(plain_branches, removable_worktree_branches)
        removable_worktree_branches.each { remove_worktree_and_branch(_1) }
        plain_branches.each { delete_branch(_1) }
      end
    else
      puts "There are no merged branches to delete."
    end
  end

  # nil when the worktree is safe to remove
  private def reason_to_keep_worktree(branch)
    if File.expand_path(branch.worktree_path) == File.expand_path(@main_worktree_path)
      "main worktree"
    # A worktree whose branch hasn't had any commits yet counts as merged, so removing it would
    # throw away work in progress. A deleted remote branch means it went somewhere, though.
    elsif !branch.has_own_history? && !branch.upstream_gone?
      "no commits yet"
    elsif !Open3.capture2("git", "-C", branch.worktree_path, "status", "--porcelain", err: File::NULL).first.empty?
      "uncommitted changes"
    end
  end

  private def prompt_to_delete_branches(plain_branches, removable_worktree_branches)
    if plain_branches.any?
      puts "The following branches have been merged into your current branch and can be deleted:"
      BranchList.new(branches: plain_branches).display
    end

    if removable_worktree_branches.any?
      puts "The following branches have been merged and their worktrees can be removed along with them:"
      BranchList.new(branches: removable_worktree_branches).display
    end

    # Use print rather than puts so that what the user types shows on the same line
    print "Type 'y' to delete these, or anything else to cancel: "
    $stdin.gets.to_s.strip == "y"
  end

  private def display_kept_worktree_branches(kept_worktree_branches)
    return if kept_worktree_branches.empty?

    puts "The following branches have been merged but are checked out in a worktree that's being kept:"
    BranchList.new(branches: kept_worktree_branches.keys, notes: kept_worktree_branches).display
  end

  # No --force: git refuses to remove a worktree with modified or untracked files, or a locked
  # one. If the worktree stays, the branch has to stay too.
  private def remove_worktree_and_branch(branch)
    puts "git worktree remove #{ branch.worktree_path }"
    output, status = Open3.capture2e("git", "worktree", "remove", branch.worktree_path)
    if status.success?
      delete_branch(branch)
    else
      warn output
      puts "Kept #{ branch.name }"
    end
  end

  private def delete_branch(branch)
    puts "git branch -d #{ branch.name }"
    system("git", "branch", "-d", branch.name, out: File::NULL)
  end
end

# Run `git remote prune origin` first to delete any remote references to the
# branches we have checked out locally that have already been deleted
`git remote prune origin`
# Forget worktrees whose directories have been deleted by hand, otherwise git
# still considers their branches checked out and refuses to delete them
`git worktree prune`
puts

# Prompt the user to delete any of the branches that are merged into the
# current branch, and the worktrees they're checked out in
branches = BranchParser.new(`git branch --format="#{BranchParser::FORMAT}" --merged`).branches
# The main worktree is always listed first
main_worktree_path = `git worktree list --porcelain`.lines.first.delete_prefix("worktree ").strip
BranchDeletionPrompt.new(branches, main_worktree_path: main_worktree_path).prompt_to_delete_merged_branches
