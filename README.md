# Dotfiles

This repo fully configures a MacOS system from scratch using [nix-darwin](https://github.com/nix-darwin/nix-darwin), [home-manager](https://github.com/nix-community/home-manager) and [Nix](https://github.com/nixos/nix).

## Setup

1. Install [Determinate Nix](https://docs.determinate.systems/) for a better nix experience on MacOS.
2. Install [Homebrew](https://brew.sh/)
2. `nix shell nixpkgs#git --command git clone https://github.com/dnjstrom/dotfiles.git`
3. `cd ~/dotfiles; ./apply-system-config.sh`
