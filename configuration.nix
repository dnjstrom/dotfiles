# For docs on the nix-darwin config options
# https://nix-darwin.github.io/nix-darwin/manual/

{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    reattach-to-user-namespace
    _1password-cli

    kubectl

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
      upgrade = false;
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
      "linear"
      "aws-vpn-client"
      "cursor"
      "freelens"
      "dbeaver-community"
      "mongodb-compass"
      "conductor"
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
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      AppleEnableSwipeNavigateWithScrolls = true;
      AppleEnableMouseSwipeNavigateWithScrolls = true;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "clmv";
    };

    magicmouse.MouseButtonMode = "TwoButton";

    loginwindow.GuestEnabled = false;

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
      show-recents = false;
      mru-spaces = false;

      wvous-tr-corner = 2; # Mission Control

      persistent-apps = [
        { app = "/Applications/Firefox.app"; }
        { app = "/Applications/Alacritty.app"; }
        { app = "/Applications/Slack.app"; }
        { app = "/System/Applications/Mail.app"; }
        { app = "/System/Applications/Calendar.app"; }
        { app = "/Applications/Linear.app"; }
        { app = "/Applications/ChatGPT.app"; }
        { app = "/Applications/Claude.app"; }
        { app = "/Applications/Element.app"; }
        { app = "/Applications/Spotify.app"; }
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
        ".direnv/"
      ];
      includes = [
        { path = ./gitconfig; }
      ];
    };

    programs.ssh = {
      enable = true;

      matchBlocks."github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          AddKeysToAgent = "yes";
          # Pinned host keys (below) checked first; falls back to the
          # regular known_hosts so other hosts can still TOFU as normal.
          UserKnownHostsFile = "~/.ssh/github_known_hosts ~/.ssh/known_hosts";
        };
      };
    };

    home.file.".ssh/github_known_hosts".source = ./known_hosts;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.uv.enable = true;

    home.packages = [
      pkgs.just
      pkgs.fnm
    ];

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
    programs.awscli.enable = true;

    programs.kubeswitch = {
      enable = true;
      enableZshIntegration = true;
      commandName = "kx";
    };

    programs.kubecolor = {
      enable = true;
      enableAlias = true;
      enableZshIntegration = true;
    };

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
        theme = "Nord";
      };
    };

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
      extraPackages = with pkgs; [
        tree-sitter
      ];
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
