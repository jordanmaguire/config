# Functions shared by install.sh (host) and install_dev_container.sh. Sourced, not run.

# Links src at dst. Something real already at dst (not a symlink) is moved aside first, so an
# install never destroys a file it didn't create.
link_path() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="$dst.before-config-$(date +%Y%m%d%H%M%S)"
        mv "$dst" "$backup"
        echo "Moved existing $dst to $backup"
    fi
    ln -sfn "$src" "$dst"
}

# Links each entry of the src folder into dst, leaving anything else in dst alone.
link_entries() {
    local src="$1" dst="$2" entry
    [ -d "$src" ] || return 0
    mkdir -p "$dst"
    for entry in "$src"/* "$src"/.[!.]*; do
        [ -e "$entry" ] || continue
        [ "$(basename "$entry")" = ".gitkeep" ] && continue
        link_path "$entry" "$dst/$(basename "$entry")"
    done
}

link_claude() {
    local claude_dir="${HOME}/.claude" name
    for name in skills agents commands mods; do
        link_entries "$CONFIG_DIR/claude/$name" "$claude_dir/$name"
    done
    link_path "$CONFIG_DIR/claude/settings.json" "$claude_dir/settings.json"
    link_path "$CONFIG_DIR/claude/CLAUDE.md" "$claude_dir/CLAUDE.md"
    echo "Linked Claude config from $CONFIG_DIR/claude into $claude_dir"
}

# Links git_hooks/* into one repo's hooks folder. Linked per repo rather than set through a global
# core.hooksPath, because a repo-level core.hooksPath would override the global one. A hook
# somebody else put there is left alone.
link_git_hooks() {
    local repo="$1" hooks_dir hook dst
    [ -e "$repo/.git" ] || return 0
    hooks_dir="$(git -C "$repo" rev-parse --path-format=absolute --git-path hooks 2>/dev/null)" || return 0
    # A repo shared with a dev container can point core.hooksPath at a path that only exists there.
    if ! mkdir -p "$hooks_dir" 2>/dev/null; then
        echo "Skipped $repo: its hooks folder $hooks_dir can't be made on this machine" >&2
        return 0
    fi
    for hook in "$CONFIG_DIR"/git_hooks/*; do
        [ -f "$hook" ] || continue
        [ "$(basename "$hook")" = "host_repos" ] && continue
        dst="$hooks_dir/$(basename "$hook")"
        if [ -e "$dst" ] && [ ! -L "$dst" ]; then
            echo "Skipped $dst: a hook that isn't a symlink is already there" >&2
            continue
        fi
        if [ -L "$dst" ] && [ ! -e "$dst" ] && [ "$(readlink "$dst")" != "$hook" ]; then
            echo "Skipped $dst: it links to $(readlink "$dst"), which belongs to another machine" >&2
            continue
        fi
        ln -sfn "$hook" "$dst"
        echo "Linked $hook into $hooks_dir"
    done
}
