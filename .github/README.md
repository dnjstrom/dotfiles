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

##### Install tmux plugins

    tmux
    # Type <Ctrl-a I>

##### Install fish plugins

    fisher update

##### Install vim plugins

    vim
    :PlugInstall    