{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "daniel";
  home.homeDirectory = "/Users/daniel";


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  home.packages = [
    pkgs.ctop
    pkgs.direnv
    pkgs.fish
    pkgs.git
    pkgs.grc
    pkgs.htop
    pkgs.jq
    pkgs.neovim
    pkgs.reattach-to-user-namespace
    pkgs.starship
    pkgs.tmux
    pkgs.tree
  ];

  programs.fish = {
    enable = true;

    plugins = [
      { name = "foreign-env"; src = pkgs.fishPlugins.foreign-env.src; }
      { name = "autopair-fish"; src = pkgs.fishPlugins.autopair-fish.src; }
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
    ];

    shellInit = "source $HOME/.fishrc.fish";
  };
} 
