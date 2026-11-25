# My Herdr setup

Notes for agents working on this Herdr setup. Herdr never writes this file.

## Where this lives

- This file, `keys.json`, `settings.json` and everything under `mods/` that isn't Herdr's own are
  symlinks into my config repository (`~/src/config/herdr/`, github.com/jordanmaguire/config).
- Edit them in place; the change lands in the repository. Commit and push it there.
- A new mod of mine goes in `~/src/config/herdr/mods/<name>/`, then `~/src/config/install.sh`
  links it in. Never put my mods only in `~/.config/herdr-app/mods/`: they won't be tracked.
- Herdr writes `settings.json` through the symlink when I change zoom or settings, so that file
  shows up as modified in the repository. That is expected: commit it when the change is one I
  want on every machine.

## How I work

- All my work is on one application: `~/src/interexchange/app`.
- I usually have a few GitHub issues in flight, each with its own Claude terminal, plus side
  fixes I find along the way that have no issue.
- Each piece of work is a git worktree in its own space, so it is isolated and I can fold away
  what I'm not looking at. Spaces stay unnamed so the sidebar labels them by branch and nests
  them under the main checkout.
- I want my recurring decisions and commands consolidated into one action each.

## What exists

- `mods/start-work` (`cmd-shift-n`, or "Start work" in the palette): two fields, Issue or pull
  request and Description, at least one filled. The first takes a number, `#number` or a GitHub
  URL; GitHub is asked whether the number is an issue or a pull request.
  - An issue: the branch is `<number>-<issue title in kebab case>`. Claude is told to read
    the issue; with a description it is also told what I want, without one it reports its
    understanding and waits.
  - A pull request: the branch is the pull request's own, fetched from origin and tracking it.
    Claude is told to read the pull request and its diff, then the same as for an issue. Pull
    requests from forks are refused.
  - Blank: the branch is the description in kebab case and the description is Claude's task.
  - A new branch's worktree is made from a fresh `origin/<default branch>` without upstream
    tracking, at `<worktrees.directory>/<repo>/<branch>` (default `~/.herdr/worktrees`; slashes
    in a branch become dashes). An existing branch or worktree is reused, and a local branch
    that already exists is not moved to the remote's. If the main checkout is already on the
    branch, the space opens there.
  - The space opens with Claude on the left and a shell on the right.
  - The repo is the focused terminal's, falling back to `~/src/interexchange/app`.

## Not done yet

- A new worktree is only a checkout: no `.env` files and no Docker instance of its own.
- Nothing tears a piece of work down beyond Herdr's own Remove worktree.
