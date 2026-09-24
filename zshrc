# Autosuggest abbreviations
ZSH_AUTOSUGGEST_STRATEGY=( abbreviations $ZSH_AUTOSUGGEST_STRATEGY )

# Ensure abbreviations are highlighted correctly
# DOESN'T WORK ATM
# https://zsh-abbr.olets.dev/integrations.html#zsh-syntax-highlighting
(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} )) && {
  ZSH_HIGHLIGHT_HIGHLIGHTERS+=(regexp)
  ZSH_HIGHLIGHT_REGEXP=('^[[:blank:][:space:]]*('${(j:|:)${(Qk)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' fg=green)
  ZSH_HIGHLIGHT_REGEXP+=('[[:<:]]('${(j:|:)${(Qk)ABBR_GLOBAL_USER_ABBREVIATIONS}}')$' fg=green)
}

# History substring search (Should be after zsh-syntax-highlighting)
# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Environment variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim

# Secrets
# source $HOME/.zshrc.secrets

# Disable Homebrew environment hints
export HOMEBREW_NO_ENV_HINTS=1

# fnm (nvm-equivalent node version manager): auto-switches node version
# on `cd` based on .nvmrc/.node-version, and keeps corepack enabled.
eval "$(fnm env --use-on-cd --corepack-enabled --shell zsh)"


# Ollama model configs
export OLLAMA_CONTEXT_LENGTH=32768
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_MAX_LOADED_MODELS=1

# Make option+arrow-key work on iOS 
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# General aliases
alias vim='nvim'
alias tree='eza -T'
alias cat='bat'

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

# Kubernetes abbreviations
abbr -f -q k='kubectl'

# Other abbreviations
abbr -f -q pn='pnpm'
abbr -f -q scripts='cat package.json | jq .scripts'

# Tmux function
function tmux_func() {
  if tmux ls 2>/dev/null | grep -vq attached; then
    tmux attach
  else
    tmux
  fi
}

# Refresh tmux's pane-border directory title on `cd`. tmux's own hooks
# (tmux.conf) only fire on pane/window switches, not when a pane's cwd
# changes while it stays focused, so mirror that here via chpwd.
function tmux_refresh_pane_border() {
  [[ -n "$TMUX" ]] || return
  local win
  win=$(tmux display-message -p '#{window_id}') || return
  ~/.config/tmux/tmux-pane-border.sh "$win"
}
chpwd_functions+=(tmux_refresh_pane_border)
