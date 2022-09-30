export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}

. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

path+=("$HOME/.nix-profile/bin")
