eval "$(/opt/homebrew/bin/brew shellenv)"

# Prompt theme
eval "$(starship init zsh)";

# Packages
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh;
source $(brew --prefix)/etc/profile.d/z.sh;

# Abbreviations
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh
source /opt/homebrew/share/zsh-autosuggestions-abbreviations-strategy/zsh-autosuggestions-abbreviations-strategy.zsh
ZSH_AUTOSUGGEST_STRATEGY=( abbreviations $ZSH_AUTOSUGGEST_STRATEGY )

# Syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh;

# History substring search (Should be after zsh-syntax-highlighting)
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh;
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Environment variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim
export N_PREFIX=$HOME/.local

# Secrets
source $HOME/.zshrc.secrets

# PATH additions
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$(brew --prefix)/opt/libpq/bin:$PATH

# Disable Homebrew environment hints
export HOMEBREW_NO_ENV_HINTS=1

# pnpm
export PNPM_HOME="/Users/daniel/Library/pnpm"
if [[ ":$PATH:" != *":$PNPM_HOME:"* ]]; then
  export PATH="$PNPM_HOME:$PATH"
fi

# Make option+arrow-key work on iOS 
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Alias for managing config files
alias cfg='git --git-dir=$HOME/Code/dotfiles/ --work-tree=$HOME'

# General aliases
alias vim='nvim'
alias code='code-insiders'
alias ls='ls -G'
alias l='la'

# Docker abbreviations
abbr -f -q d='docker'
abbr -f -q dc='docker compose' > /dev/null 2>&1

# Git abbreviations
abbr -f -q ga='git add'
abbr -f -q gA='git add -A :/'
abbr -f -q gc='git checkout'
abbr -f -q gC='git commit'
abbr -f -q gAC='git add -A :/; git commit'
abbr -f -q gf='git fetch'
abbr -f -q gp='git pull --rebase'
abbr -f -q gP='git push -u origin HEAD'
abbr -f -q gr='git rebase'
abbr -f -q gs='git status'
abbr -f -q gd='git -c color.ui=always status -v -v | less -RX'
abbr -f -q gl='git log --oneline --graph'
abbr -f -q gb='git branch'
abbr -f -q geach='git submodule foreach'
abbr -f -q grekt='git reset --hard HEAD'
abbr -f -q gitclean='git checkout main && git fetch -p && git pull && git branch --merged | egrep -v "(^\*|main)" | xargs git branch -d && git fetch --prune'
abbr -f -q gu='git branch -u origin/$(git rev-parse --abbrev-ref HEAD)'

# Yarn abbreviations
abbr -f -q y='yarn'
abbr -f -q ys='yarn start'
abbr -f -q yd='yarn dev'
abbr -f -q yb='yarn build'

# Other abbreviations
abbr -f -q cd-='cd -'
abbr -f -q pn='pnpm'
abbr -f -q scripts='cat package.json | jq .scripts'
abbr -f -q c='code .'

# Tmux function
function tmux_func() {
  if tmux ls 2>/dev/null | grep -vq attached; then
    tmux attach
  else
    tmux
  fi
}

# Mise-en-place - tool version manager
# See: https://mise.jdx.dev/
eval "$(mise activate zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/daniel/.lmstudio/bin"
# End of LM Studio CLI section

