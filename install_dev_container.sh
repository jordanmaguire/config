#!/bin/bash
# Sets up a dev container. VS Code clones this repository and runs this file: see the README.
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/install_common.sh
source "$CONFIG_DIR/lib/install_common.sh"

BASHRC_MARKER="# jordanmaguire/config"
if ! grep -qF "$BASHRC_MARKER" "${HOME}/.bashrc" 2>/dev/null; then
    {
        echo ""
        echo "$BASHRC_MARKER"
        echo "export JM_CONFIG_DIR=\"$CONFIG_DIR\""
        echo "source \"\$JM_CONFIG_DIR/shell/aliases.sh\""
        echo "source \"\$JM_CONFIG_DIR/shell/devcontainer.sh\""
    } >> "${HOME}/.bashrc"
fi

link_claude

for repo in /workspaces/*/; do
    link_git_hooks "${repo%/}"
done

# Last on purpose: set -e stops here if GitHub credentials or sudo aren't available during bootstrap.
# Linked into /usr/local/bin because ~/.local/bin isn't on PATH for the SessionStart hook.
[ -d "$HOME/.dusc/skills" ] || git clone git@github.com:dusc-dev/dusc-skills.git "$HOME/.dusc/skills"
"$HOME/.dusc/skills/bin/dusc-skills" install
sudo ln -sfn "$HOME/.dusc/skills/bin/dusc-skills" /usr/local/bin/dusc-skills
