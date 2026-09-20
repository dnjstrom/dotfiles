# For docs on the nix-darwin config options
# https://nix-darwin.github.io/nix-darwin/manual/

{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    reattach-to-user-namespace
    _1password-cli

    # Language servers, etc.
    nixd
    nixfmt
    eslint_d
    prettierd
    typescript-go
    luaPackages.luacheck
    luaPackages.lua-lsp
    ruff
  ];

  homebrew = {
    enable = true;
    enableZshIntegration = true;

    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Uninstall packages/casks not in Brewfile
      upgrade = true;
    };

    global = {
      brewfile = true;
    };

    taps = [
      {
        name = "SoftwareRat/homebrew-unsigned-tap";
        trusted = true;
      }
      {
        name = "dnjstrom/git-select-branch";
        trusted = true;
      }
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
      "claude"
      "element"
    ];
  };

  services = {
    tailscale.enable = true;
  };

  # Machine-level Zsh support. Personal Zsh settings live below.
  programs.zsh.enable = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.defaults = {
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    dock = {
      magnification = true;
      orientation = "left";
      tilesize = 42;
      largesize = 64;
      autohide = false;
      autohide-delay = 0.06;
      autohide-time-modifier = 0.7;

      persistent-apps = [
        { app = "/Applications/Firefox.app"; }
        { app = "/Applications/Alacritty.app"; }
        { app = "/Applications/Slack.app"; }
        { app = "/System/Applications/Mail.app"; }
        { app = "/System/Applications/Calendar.app"; }
        { app = "/Applications/ChatGPT.app"; }
        { app = "/Applications/Element.app"; }
        { app = "/Applications/Spotify.app"; }
        { app = "/System/Applications/Utilities/Activity Monitor.app"; }
      ];
    };
  };

  security.pam.services.sudo_local = {
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };

  # For docs on the various home-manager options
  # https://nix-community.github.io/home-manager/options/home-manager/programs/index.html
  home-manager.users.daniel = {
    # Pick the Home Manager release you begin with; do not casually change it.
    home.stateVersion = "26.05";

    programs.git = {
      enable = true;
      lfs.enable = true;
      ignores = [
        ".DS_Store"
        "*.secret.*"
      ];
      includes = [
        { path = ./gitconfig; }
      ];
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.gh.enable = true;
    programs.ripgrep.enable = true;
    programs.fd.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.claude-code.enable = true;

    programs.eza = {
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

    programs.bat = {
      enable = true;
      config = {
        theme = "ansi";
      };
    };

    # programs.delta = {
    #   enable = true;
    #   enableGitIntegration = true;
    #   options = {
    #     syntax-theme = "ansi";
    #   };
    # };

    programs.lazygit = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd z"
      ];
    };

    programs.zsh = {
      enable = true;
      package = pkgs.zsh;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;
      zsh-abbr.enable = true;
      plugins = [
        {
          name = "autosuggestions-abbreviations-strategy";
          src = pkgs.zsh-autosuggestions-abbreviations-strategy;
          file = "share/zsh/site-functions/zsh-autosuggestions-abbreviations-strategy.zsh";
          completions = [ "share/zsh/site-functions" ];
        }
      ];

      # Nix-managed plugin loading followed by your normal Zsh config.
      # source ${pkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.zsh
      initContent = ''
        ${builtins.readFile ./zshrc}
      '';
    };

    # Treat the zsh-abbr config as ephemeral
    # This means this file won't be managed by nix
    # Otherwise the file will be recreated and the old be backed up on every config
    # application, zsh-history-substring-search errors when a backup already exists.
    xdg.configFile."zsh-abbr/user-abbreviations".enable = false;

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
      ];

      # CPU and battery must load after the status-line placeholders in
      # tmux.conf so they can interpolate those values.
      extraConfig = ''
        ${builtins.readFile ./tmux.conf}

        run-shell ${pkgs.tmuxPlugins.battery.rtp}
        run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      '';
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # Keep the native configuration writable: Neovim's vim.pack writes its
    # package lock file beside init.lua.
    xdg.configFile."nvim/init.lua".source = ./nvim.lua;

    # Window manager config
    home.file.".phoenix.js".source = ./phoenix.js;

    # Alacritty config
    xdg.configFile."alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
