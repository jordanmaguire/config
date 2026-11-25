# Dev container only (bash, VS Code). Sourced after aliases.sh.

# Repair stale VS Code IPC socket so `code --wait` (git's editor) works in
# long-lived shells whose original VS Code window has since closed. Without
# this, git commands fail with "Unable to connect to VS Code server" / ENOENT
# on a dead /tmp/vscode-ipc-*.sock. On each prompt, if the current socket is
# still valid we return immediately; otherwise we scan newest-first and adopt
# the first socket that has a live listener.
__refresh_vscode_ipc() {
  [ -S "$VSCODE_IPC_HOOK_CLI" ] && return
  local s
  for s in $(ls -t /tmp/vscode-ipc-*.sock 2>/dev/null); do
    if python3 -c "import socket,sys; socket.socket(socket.AF_UNIX,socket.SOCK_STREAM).connect(sys.argv[1])" "$s" 2>/dev/null; then
      export VSCODE_IPC_HOOK_CLI="$s"
      return
    fi
  done
}
PROMPT_COMMAND="__refresh_vscode_ipc${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Commit messages and interactive rebases open in VS Code here. The Mac has no editor set in
# .gitconfig, so git there falls back to $EDITOR and then vi.
export GIT_EDITOR="code --wait"
