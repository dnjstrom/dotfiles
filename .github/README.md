# Dotfiles

A collection of configuration files for setting up my preferred environment on Mac using Nix, Homebrew and a bare git repository.

Based off of an article by [Mathias Polligkeit](https://www.mathiaspolligkeit.com/dev/exploring-nix-on-macos/).


## Setup

#### Ensure git is available

https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

```
git --version
```

#### Set up the config files

https://www.atlassian.com/git/tutorials/dotfiles

```
mkdir -p ~/Code
git clone --bare https://github.com/dnjstrom/dotfiles.git ~/Code/dotfiles
git --git-dir=$HOME/Code/dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$HOME/Code/dotfiles/ --work-tree=$HOME checkout
```

#### Install Homebrew

https://brew.sh/

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
cd ~/.brew
brew bundle install
```

#### Install Nix

https://nixos.org/download.html#nix-install-macos

```
sh <(curl -L https://nixos.org/nix/install)
```

#### Install Home manager

https://rycee.gitlab.io/home-manager/index.html#sec-install-standalone

```
nix-channel --update
nix-shell '<home-manager>' -A install
home-manager switch
```
