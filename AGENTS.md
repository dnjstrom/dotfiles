# AGENTS.md

This repo is Daniel's personal macOS system configuration — not an application.
It declaratively configures a single machine (`daniel-aarch64-darwin`) via
[nix-darwin](https://github.com/nix-darwin/nix-darwin),
[home-manager](https://github.com/nix-community/home-manager), and
[Determinate Nix](https://docs.determinate.systems/), using a Nix flake.
There is no build/test suite — "correctness" means the config evaluates and
applying it produces the intended machine state.

## Layout

- `flake.nix` — entry point. Defines the `darwinConfigurations` for this
  machine, a `devShell` with an `apply-nix-darwin-configuration` script, and
  `formatter` (`nixfmt`).
- `configuration.nix` — the actual system config: Homebrew casks/taps, macOS
  `system.defaults`, and all `home-manager.users.daniel` programs. This is
  where most edits happen.
- `apply-system-config.sh` — thin wrapper around
  `nix develop --command apply-nix-darwin-configuration`, which itself runs
  `sudo darwin-rebuild switch --flake .#daniel-aarch64-darwin`.
- Plain dotfiles pulled in by `configuration.nix`, **not managed standalone**:
  `zshrc`, `gitconfig`, `tmux.conf`, `nvim.lua`, `phoenix.js`,
  `alacritty.toml`. Some are inlined via `builtins.readFile` (e.g. `zshrc`,
  `tmux.conf`) and some are symlinked via `.source` (e.g. `nvim.lua`,
  `phoenix.js`, `alacritty.toml`) — check `configuration.nix` before assuming
  how a given file is wired in, and update the reference there if you rename
  or move one of these files.

## Making changes

- Match existing style: 2-space indentation everywhere, no trailing tooling
  beyond what's already configured (e.g. `luacheck` for `nvim.lua`).
- Format `.nix` files with the flake's formatter (`nix fmt`) before
  considering a change done.
- Sanity-check Nix syntax with `nix-instantiate --parse configuration.nix`
  (or `nix flake check`). This does not require sudo and is safe to run
  freely.
- Never commit secrets into `zshrc` or `gitconfig` — secrets are meant to be
  sourced from `~/.zshrc.secrets` (untracked, machine-local), not this repo.
- Keep commit messages short and imperative, matching `git log` (e.g. "Quick
  wins", "Finder, neovim theme/completion").

## Do not do without explicit confirmation

- **Never run `./apply-system-config.sh`, `darwin-rebuild switch`, or any
  `sudo` command.** These mutate the live machine (installs/removes Homebrew
  casks per `cleanup = "zap"`, changes system defaults, etc.) and are
  irreversible in practice. Only the user should trigger an apply, after
  reviewing the diff.
- Treat `flake.lock` as generated — don't hand-edit it; regenerate via
  `nix flake update` only if asked.
