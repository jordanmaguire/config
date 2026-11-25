#!/bin/bash
# Sets up this Mac from the repository. Safe to run again: it only makes symlinks, and moves a real
# file out of the way (to <name>.before-config-<time>) rather than overwriting it.
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/install_common.sh
source "$CONFIG_DIR/lib/install_common.sh"

# Home folder dotfiles. ~/.zshrc sources shell/aliases.sh itself.
for file in "$CONFIG_DIR"/dot_files/.[!.]*; do
    link_path "$file" "$HOME/$(basename "$file")"
done
echo "Linked dot_files into $HOME"

link_claude

# Herdr rewrites its own files in this folder on every start, so only ours are linked in.
HERDR_DIR="$HOME/.config/herdr-app"
if [ -d "$HERDR_DIR" ]; then
    for name in keys.json settings.json AGENTS.local.md; do
        link_path "$CONFIG_DIR/herdr/$name" "$HERDR_DIR/$name"
    done
    link_entries "$CONFIG_DIR/herdr/mods" "$HERDR_DIR/mods"
    echo "Linked Herdr config from $CONFIG_DIR/herdr into $HERDR_DIR"
else
    echo "Skipped Herdr: $HERDR_DIR doesn't exist yet. Start Herdr once, then run this again."
fi

# The pre-push hook refuses pushes to master, so it only goes into the repos listed.
while IFS= read -r line; do
    line="${line%%#*}"
    line="${line//[[:space:]]/}"
    [ -n "$line" ] || continue
    link_git_hooks "${line/#\~/$HOME}"
done < "$CONFIG_DIR/git_hooks/host_repos"
