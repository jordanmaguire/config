# Config

My configuration for my Macs and for the dev containers I work in: shell, git, Claude Code and
Herdr. One repository, two installers.

## On a Mac

```
git clone https://github.com/jordanmaguire/config ~/src/config
~/src/config/install.sh
```

`install.sh` only makes symlinks. A real file already in the way is moved to
`<name>.before-config-<time>`, never overwritten. Run it again after adding a file here.

It links:

- `dot_files/.*` into `~`: zsh and git config. `.zshrc` sources `shell/aliases.sh`.
- `claude/` into `~/.claude`: `settings.json`, `CLAUDE.md`, and each skill, agent, command and mod.
  Anything else already in `~/.claude` is left alone.
- `herdr/` into `~/.config/herdr-app`: `keys.json`, `settings.json`, `AGENTS.local.md` and my mods.
  Start Herdr once first so the folder exists.
- `git_hooks/*` into the repos listed in `git_hooks/host_repos`.

## In a dev container

In VS Code, under Settings > Remote [Dev Container]:

1. Set "Dotfiles > Repository" to `https://github.com/jordanmaguire/config`
2. Set "Dotfiles > Install Command" to `install_dev_container.sh`

VS Code clones the repository into "Dotfiles > Target Path" (`~/dotfiles` by default) and runs the
installer, which adds `shell/aliases.sh` and `shell/devcontainer.sh` to `~/.bashrc`, links `claude/`
into `~/.claude`, links the git hooks into every repo under `/workspaces`, and installs dusc-skills.

VS Code throws the clone away fairly often, so push any change made inside a container.

## What's here

| Folder | Contents |
|---|---|
| `dot_files/` | Home folder dotfiles for the Mac: `.zshrc`, `.zprofile`, `.gitconfig`, `.global_gitignore` |
| `shell/` | `aliases.sh` is shared by zsh on the Mac and bash in containers; `devcontainer.sh` is container only |
| `git_tools/` | Branch scripts behind `gbr`, `gco`, `gsl` and `gsd`. `git_smart_prune.rb` has no alias until it is reworked. They need Ruby 3.1 or newer |
| `git_hooks/` | `pre-push` refuses any push to `master`, and refuses force pushes and remote branch deletions made from a Claude Code shell |
| `claude/` | Claude Code settings, instructions, skills and the review picker mod |
| `herdr/` | Herdr keys, settings, my mods, and `AGENTS.local.md`, the notes agents read about my setup |
| `starship.toml` | Prompt config, used on the Mac and in containers |
