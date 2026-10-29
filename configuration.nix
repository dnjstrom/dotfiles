# For docs on the nix-darwin config options
# https://nix-darwin.github.io/nix-darwin/manual/

{ pkgs, inputs, ... }:

let
  # claude-code releases far more often than the nixpkgs release branch picks
  # it up, so that one package tracks nixpkgs-unstable instead.
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  # Not in nixpkgs and has no tagged releases, so pinned to a commit.
  # To upgrade: bump rev, then re-fetch the hash with
  # `nix flake prefetch "https://github.com/accessd/tmux-agent-indicator/archive/<rev>.tar.gz"`
  tmuxAgentIndicator = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-agent-indicator";
    rtpFilePath = "agent-indicator.tmux";
    version = "unstable-2026-08-14";
    src = pkgs.fetchFromGitHub {
      owner = "accessd";
      repo = "tmux-agent-indicator";
      rev = "553c3cca8bea6fe17e0709ec04f737417de42141";
      hash = "sha256-VCq7Muvpke9goN1RTcIChW+c/SkFHUSJdoEGKH+CaMQ=";
    };
    meta = {
      homepage = "https://github.com/accessd/tmux-agent-indicator";
      description = "Visual feedback (pane border/window title/status bar) for AI agent states: running, needs-input, done";
    };
  };
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    reattach-to-user-namespace
    _1password-cli

    kubectl
    mosh

    # Language servers, etc.
    nixd
    nixfmt
    eslint_d
    prettierd
    typescript
    typescript-language-server
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
      {
        name = "mongodb/brew";
        trusted = true;
      }
    ];

    brews = [
      "git-select-branch"
      "mongodb-community"
      # Recommended deps of mongodb-community — must be listed explicitly or
      # `cleanup = "zap"` tries (and fails) to remove them as orphaned.
      "mongosh"
      "mongodb/brew/mongodb-database-tools"
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
      "docker-desktop"
      "handy"
    ];
  };

  services = {
    tailscale.enable = true;

    postgresql = {
      enable = false;
      package = pkgs.postgresql_16;
      dataDir = "/Users/daniel/.local/share/postgresql";
      # Single-user machine: trust local socket connections instead of the
      # default peer auth, which requires the OS user to match the PG role.
      authentication = "local all all trust";
      # Without explicit args, initdb falls back to locale C, which yields
      # SQL_ASCII encoding and breaks any migration that inserts non-ASCII text.
      initdbArgs = [
        "--locale=en_US.UTF-8"
        "--encoding=UTF8"
      ];
    };

    redis = {
      enable = true;
      dataDir = "/Users/daniel/.local/share/redis";
      bind = "127.0.0.1";
    };
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
        { app = "/Applications/Figma.app"; }
        { app = "/Applications/Claude.app"; }
        # Safari web apps (File > Add to Dock in Safari on meet.google.com /
        # messenger.com), not cask-managed. Must be recreated manually if
        # these paths are missing.
        { app = "/Users/daniel/Applications/Google Meet.app"; }
        { app = "/Users/daniel/Applications/Messenger.app"; }
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
  home-manager.users.daniel = { config, ... }: {
    # Pick the Home Manager release you begin with; do not casually change it.
    home.stateVersion = "26.05";

    # User-installed binaries (e.g. from curl | sh installers)
    home.sessionPath = [ "$HOME/.local/bin" ];

    # Possibly temporary workaround: the nixpkgs claude-code wrapper (since
    # ~2.1.311) sets CLAUDE_CODE_CERT_STORE=system, which fails TLS to
    # api.anthropic.com with UNABLE_TO_GET_ISSUER_CERT_LOCALLY. The wrapper
    # doesn't override an existing value, so use the bundled CA store. Remove
    # once a newer claude-code package works without it.
    home.sessionVariables.CLAUDE_CODE_CERT_STORE = "bundled";

    programs.git = {
      enable = true;
      lfs.enable = true;
      ignores = [
        ".DS_Store"
        "*.secret.*"
        ".direnv/"
        ".claude/settings.local.json"
      ];
      includes = [
        { path = ./git/gitconfig; }
      ];
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      # UseKeychain is Apple-only; Nix's OpenSSH (which Nix's mosh is
      # hard-wired to) rejects the whole config without this.
      extraOptionOverrides.IgnoreUnknown = "UseKeychain";

      # Runs the homelab stack; see github.com/dnjstrom/machines. The Docker
      # context uses the FQDN, so it must be listed here or none of this
      # applies to deploys.
      settings."server 10.0.1.200 server.tail463646.ts.net" = {
        User = "daniel";

        # The Docker CLI opens a new SSH connection per API request, so a
        # `docker compose` run against the homelab stack bursts enough
        # connections that sshd drops them, and the deploy fails with
        # "kex_exchange_identification: read: Connection reset by peer".
        # Reusing one connection avoids it. See ~/Code/homelab/README.md.
        ControlMaster = "auto";
        ControlPath = "~/.ssh/cm-%r@%h-%p";
        ControlPersist = "10m";
      };

      # Local LLM server; see github.com/dnjstrom/macbook-pro-llm-server.
      # A reinstall regenerates its host key, so update ssh/known_hosts then.
      settings."llm llm.tail463646.ts.net llm.local" = {
        User = "daniel";
      };

      # Defaults for every host. Always emitted last by home-manager, so the
      # host blocks above take precedence for anything they set.
      settings."*" = {
        # One local key for everything (GitHub, server, llm, workstation);
        # its public half is in github.com/dnjstrom/machines ssh/authorized_keys.
        # The passphrase lives in the macOS keychain, so non-interactive ssh
        # (scripts, Docker, Claude Code) never prompts. Needed even with
        # ControlMaster: past sshd's MaxSessions, Docker falls back to fresh
        # connections with no TTY. If the keychain loses the entry,
        # `ssh-add --apple-use-keychain ~/.ssh/id_ed25519` restores it.
        IdentityFile = "~/.ssh/id_ed25519";
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
        # Pinned host keys (ssh/known_hosts) checked first; falls back to the
        # regular known_hosts so other hosts can still TOFU as normal.
        UserKnownHostsFile = "${./ssh/known_hosts} ~/.ssh/known_hosts";
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      # Silence the loading/export log lines; errors (e.g. a blocked .envrc)
      # still print. log_filter only shows messages matching it, so "^$"
      # hides them all. (log_format = "-", the documented way, is broken in
      # direnv 2.37 and prints the "-" as a format string.)
      config.global.log_filter = "^$";
    };

    programs.uv.enable = true;

    home.packages = [
      pkgs.just
      pkgs.fnm
      pkgs.mongosh
    ];

    # redis-server refuses to start if its data dir doesn't exist;
    home.file.".local/share/redis/.keep".text = "";

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.gh.enable = true;
    programs.ripgrep.enable = true;
    programs.fd.enable = true;
    programs.htop.enable = true;
    programs.jq.enable = true;
    programs.claude-code = {
      enable = true;
      package = unstable.claude-code;
      agents = {
        research-primer = ./claude/agents/research-primer.md;
        plan-validator = ./claude/agents/plan-validator.md;
        code-reviewer = ./claude/agents/code-reviewer.md;
        admin = ./claude/agents/admin.md;
      };
      commands = {
        ship = ./claude/commands/ship.md;
      };
      skills = {
        review-pr = ./claude/skills/review-pr;
        request-review = ./claude/skills/request-review;
        address-pr-comments = ./claude/skills/address-pr-comments;
        write-pr-description = ./claude/skills/write-pr-description;
      };
      lspServers = {
        # Bare command on purpose: ty is provided per project by .envrc, so
        # claude must be launched from a direnv-loaded shell to find it.
        python = {
          command = "ty";
          args = [ "server" ];
          extensionToLanguage = {
            ".py" = "python";
            ".pyi" = "python";
          };
        };
        # Uses the project's own tsserver from node_modules when present.
        typescript = {
          command = "${pkgs.typescript-language-server}/bin/typescript-language-server";
          args = [ "--stdio" ];
          extensionToLanguage = {
            ".ts" = "typescript";
            ".tsx" = "typescriptreact";
            ".mts" = "typescript";
            ".cts" = "typescript";
            ".js" = "javascript";
            ".jsx" = "javascriptreact";
            ".mjs" = "javascript";
            ".cjs" = "javascript";
          };
        };
      };
      context = ''
        # Global instructions

        When drafting content meant to be sent externally on Daniel's
        behalf — emails, Slack/Teams messages, PR or issue descriptions,
        review and ticket comments, and similar outward-facing
        communication — never write as if you are Daniel, or as any human.
        No first-person opinions ("I think", "I'd prefer"), no invented
        personal experience, no human pleasantries or sign-offs. Use a
        professional, neutral tone and concise, to-the-point prose: state
        the point, its reason or consequence, and any ask. No filler,
        hedging or restating.

        Exception: when Daniel explicitly asks for a draft to post in
        Daniel's own name, write it in Daniel's first-person voice. Tone
        and concision still apply.

        # Pull requests

        Open every PR as a draft (`gh pr create --draft`), and never mark
        one ready for review (`gh pr ready`): Daniel reviews the draft and
        marks it ready.

        # dex

        `dex`'s dependencies come from the nix flake in `~/Dema.ai`, so
        it only runs inside that environment. Run it as
        `direnv exec ~/Dema.ai ~/.local/bin/dex <args>`, from a cwd at or
        below `~/Dema.ai`. Stack-scoped commands pick the stack from the
        cwd, so run them from the stack's folder
        (`~/Dema.ai/workspaces/<stack>`) or pass `--stack <name>`.
      '';
      settings = {
        theme = "auto";
        permissions.defaultMode = "auto";
        effortLevel = "high";
        # The dex plugin, served straight from the local checkout so it
        # tracks whatever branch is checked out there.
        extraKnownMarketplaces.dex.source = {
          source = "directory";
          path = "/Users/daniel/Dema.ai/repositories/dex";
        };
        enabledPlugins."dex@dex" = true;
        # Mirrors tmux-agent-indicator's own hooks/claude-hooks.json (plugin
        # defined below) so it can track Claude's state per pane. The two
        # UserPromptSubmit hooks run in order: "off" clears any leftover
        # needs-input/done flag from the previous turn before "running"
        # re-marks the pane active. The Subagent* hooks let Stop hold off on
        # "done" while background subagents are still running (see
        # claude/agent-state-hook.sh).
        hooks =
          let
            agentStateHook = pkgs.writeShellApplication {
              name = "claude-agent-state-hook";
              runtimeInputs = [ pkgs.jq ];
              text =
                builtins.replaceStrings
                  [ "@agentState@" ]
                  [
                    "${tmuxAgentIndicator}/share/tmux-plugins/tmux-agent-indicator/scripts/agent-state.sh"
                  ]
                  (builtins.readFile ./claude/agent-state-hook.sh);
            };
            hook = state: {
              hooks = [
                {
                  type = "command";
                  command = "${agentStateHook}/bin/claude-agent-state-hook ${state}";
                }
              ];
            };
          in
          {
            UserPromptSubmit = [
              (hook "off")
              (hook "running")
            ];
            PermissionRequest = [ (hook "needs-input") ];
            SubagentStart = [ (hook "subagent-start") ];
            SubagentStop = [ (hook "subagent-stop") ];
            Stop = [ (hook "done") ];
          };
      };
    };
    programs.awscli.enable = true;
    programs.lazydocker.enable = true;

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
      history.share = false;
      setOptions = [ "INC_APPEND_HISTORY" ];
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
        ${builtins.readFile ./zsh/zshrc}
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
        tmux-fzf # prefix + F: fuzzy-manage sessions/windows/panes
        tmuxAgentIndicator # per-pane/window Claude state (running/needs-input/done)
      ];

      # CPU and battery must load after the status-line placeholders in
      # tmux.conf so they can interpolate those values.
      extraConfig = ''
        # tmux-fzf's scripts live in the nix store, so tmux.conf (a plain
        # file with no nix interpolation) references this indirectly via
        # #{@tmux_fzf_scripts} instead of hardcoding the path itself.
        set -g @tmux_fzf_scripts "${pkgs.tmuxPlugins.tmux-fzf}/share/tmux-plugins/tmux-fzf/scripts"

        ${builtins.readFile ./tmux/tmux.conf}

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
    xdg.configFile."nvim/init.lua".source = ./nvim/nvim.lua;

    # Window manager config. Linked to the repo checkout rather than copied
    # into the store, so Phoenix reloads on save without a rebuild.
    home.file.".phoenix.js".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/phoenix/phoenix.js";

    # Alacritty config
    xdg.configFile."alacritty/alacritty.toml".source = ./alacritty/alacritty.toml;

    # Helper used by tmux.conf's pane-border-format
    xdg.configFile."tmux/tmux-pane-border.sh" = {
      source = ./tmux/tmux-pane-border.sh;
      executable = true;
    };
  };
}
