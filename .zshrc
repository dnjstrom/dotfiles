eval "$(/opt/homebrew/bin/brew shellenv)"

# Prompt theme
eval "$(starship init zsh)";

# Packages
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh;
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh;
source $(brew --prefix)/etc/profile.d/z.sh;

# Syntax highlighting (Shold be loaded last)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh;

# Environment variables
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim
export N_PREFIX=$HOME/.local

# PATH additions
export PATH=$PATH:/opt/homebrew/bin
export PATH=$PATH:$HOME/.local/bin

# pnpm
export PNPM_HOME="/Users/daniel/Library/pnpm"
if [[ ":$PATH:" != *":$PNPM_HOME:"* ]]; then
  export PATH="$PNPM_HOME:$PATH"
fi

# Alias for managing config files
alias cfg='git --git-dir=$HOME/Code/dotfiles/ --work-tree=$HOME'

# General aliases
alias vim='nvim'
alias d='docker'
alias dc='docker compose'
alias l='la'
alias c='code .'
alias code='code-insiders'
alias ls='ls --color'

# Make option+arrow-key work on iOS 
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Git aliases
alias ga='git add'
alias gA='git add -A :/'
alias gc='git checkout'
alias gC='git commit'
alias gAC='git add -A :/; git commit'
alias gf='git fetch'
alias gp='git pull --rebase'
alias gP='git push -u origin HEAD'
alias gr='git rebase'
alias gs='git status'
alias gd='git -c color.ui=always status -v -v | less -RX'
alias gl='git log --oneline --graph'
alias gb='git branch'
alias geach='git submodule foreach'
alias grekt='git reset --hard HEAD'
alias gitclean='git checkout main && git fetch -p && git pull && git branch --merged | egrep -v "(^\*|main)" | xargs git branch -d && git fetch --prune'
alias gu='git branch -u origin/$(git rev-parse --abbrev-ref HEAD)'

# Yarn aliases
alias y='yarn'
alias ys='yarn start'
alias yd='yarn dev'
alias yb='yarn build'

# Other aliases
alias cd-='cd -'
alias pn='pnpm'
alias scripts='cat package.json | jq .scripts'

# Tmux function
function tmux_func() {
  if tmux ls 2>/dev/null | grep -vq attached; then
    tmux attach
  else
    tmux
  fi
}
