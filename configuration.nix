{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    ripgrep
    fd
    fzf
    bat
    htop
    gh
    jq
    reattach-to-user-namespace
    _1password-cli
    zoxide
    eza
  ];

  homebrew = {
    enable = true;
    enableZshIntegration = true;

    taps = [
      "dnjstrom/git-select-branch"
      "SoftwareRat/homebrew-unsigned-tap"
    ];

    brews = [
      "git-select-branch"
    ];

    casks = [
      "SoftwareRat/homebrew-unsigned-tap/alacritty"
      "firefox"
      "spotify"
      "1password"
      "figma"
      "google-chrome"
      "google-drive"
      "phoenix"
      "slack"
      "chatgpt"
      "font-monaspace-nf"
    ];
  };

  # Machine-level Zsh support. Personal Zsh settings live below.
  programs.zsh.enable = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    finder.AppleShowAllExtensions = true;
    trackpad.TrackpadThreeFingerDrag = true;
  };

  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };

  home-manager.users.daniel = {
    # Pick the Home Manager release you begin with; do not casually change it.
    home.stateVersion = "26.05";

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        command_timeout = 1000;
      };
    };

    programs.zsh = {
      enable = true;
      package = pkgs.zsh;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # Nix-managed plugin loading followed by your normal Zsh config.
      initContent = ''
        source ${pkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.zsh
        source ${pkgs.zsh-autosuggestions-abbreviations-strategy}/share/zsh/site-functions/zsh-autosuggestions-abbreviations-strategy.zsh
        source ${pkgs.zsh-history-substring-search}/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

        ${builtins.readFile ./zshrc}
      '';
    };

    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      prefix = "C-a";
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      sensibleOnTop = true;

      # Declarative replacement for TPM.
      plugins = with pkgs.tmuxPlugins; [
        yank
        open
        vim-tmux-navigator
        battery
        cpu
      ];

      # Conventional tmux syntax, maintained as a normal dotfile.
      extraConfig = builtins.readFile ./tmux.conf;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # Keep the native configuration writable: Neovim's vim.pack writes its
    # package lock file beside init.lua.
    xdg.configFile."nvim/init.lua".source = ./nvim.lua;
  };
}
