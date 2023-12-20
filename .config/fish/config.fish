# Clear greeting message on startup
set -g fish_greeting

# Environment variables
# Set english locale
set -x LC_ALL en_US.UTF-8
set -x LANG en_US.UTF-8
set -x EDITOR nvim
set -x PATH $PATH /opt/homebrew/bin

# Set up secret environment variables
# source ~/.dotfiles/fish/config.secret.fish

# Alias for managing config files
alias cfg='git --git-dir=$HOME/Code/dotfiles/ --work-tree=$HOME'

if not set -q abbrs_initialized
    set -U abbrs_initialized

    abbr vim 'nvim'
    abbr d 'docker'
    abbr dc 'docker compose'
    abbr ga 'git add'
    abbr gA 'git add -A :/'
    abbr gc 'git checkout'
    abbr gC 'git commit'
    abbr gAC 'git add -A :/; git commit'
    abbr gf 'git fetch'
    abbr gp 'git pull --rebase'
    abbr gP 'git push -u origin HEAD'
    abbr gr 'git rebase'
    abbr gs 'git status'
    abbr gd 'git -c color.ui=always status -v -v | less -RX'
    abbr gl 'git log --oneline --graph'
    abbr gb 'git branch'
    abbr geach 'git submodule foreach'
    abbr grekt 'git reset --hard HEAD'
    abbr cd- 'cd -'
    abbr y 'yarn'
    abbr ys 'yarn start'
    abbr yd 'yarn dev'
    abbr yb 'yarn build'
    abbr l 'la'
    abbr c 'code .'
    abbr gitclean 'git checkout master; and git fetch -p; and git pull; and git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d; and git fetch --prune'
    abbr gu 'git branch -u origin/(git rev-parse --abbrev-ref HEAD)'
end

function tmux_func
    if tmux ls | grep -vq attached
        tmux attach
    else
        tmux
    end
end

# Use term colors for syntax highlighting
set -u fish_color_normal default
set -u fish_color_param default default
set -u fish_color_comment default
set -u fish_color_autosuggestion default
set -u fish_pager_color_description default
set -u fish_pager_color_progress default
set -u fish_pager_color_secondary default

set -u fish_color_command blue --bold
set -u fish_pager_color_prefix blue --bold --underline
set -u fish_color_user blue
set -u fish_pager_color_completion blue

set -u fish_color_end cyan
set -u fish_color_search_match cyan
set -u fish_color_cwd cyan
set -u fish_color_host cyan

set -u fish_color_operator yellow
set -u fish_color_match yellow
set -u fish_color_escape yellow

set -u fish_color_error red

set -u fish_color_quote green


starship init fish | source
brew shellenv | source
