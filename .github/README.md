# Dotfiles

Configuration files for setting up a development environment on mac using Nix and Homebrew.

## Setup

Ensure `git` is available.

```
git --version
```

Set up the config files.

```
git clone --bare git@github.com:dnjstrom/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles
alias cfg='git --git-dir=$HOME/Code/dotfiles/ --work-tree=$HOME
cfg config --local status.showUntrackedFiles no
cfg checkout
```

Install Nix.

```
# https://nixos.org/download.html#nix-install-macos
sh <(curl -L https://nixos.org/nix/install)
```

Install Home manager.

```
# https://rycee.gitlab.io/home-manager/index.html#sec-install-standalone
nix-channel --update
nix-shell '<home-manager>' -A install
home-manager switch
```