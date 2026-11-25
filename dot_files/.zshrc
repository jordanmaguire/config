# This file is symlinked into ~ from the config repository: resolve the link to find the repo.
export JM_CONFIG_DIR="${${(%):-%x}:A:h:h}"
source "$JM_CONFIG_DIR/shell/aliases.sh"

export PATH="$HOME/.local/bin:$PATH"
# Homebrew Ruby ahead of the system one: the git tools need 3.1 or newer.
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# After the PATH changes above so starship itself is found. Its config is set in shell/aliases.sh.
eval "$(starship init zsh)"
