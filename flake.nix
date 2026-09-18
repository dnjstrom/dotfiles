{
  description = "A flake template for nix-darwin and Determinate Nix";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      username = "daniel";
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations."${username}-${system}" =
        inputs.nix-darwin.lib.darwinSystem {
          inherit system;

          modules = [
            inputs.determinate.darwinModules.default
            self.darwinModules.base
            self.darwinModules.determinateNixConfig

            # Makes home-manager.users.<name> available.
            inputs.home-manager.darwinModules.home-manager
            {
              # Home Manager uses the nixpkgs instance from nix-darwin.
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Optional, but helpful if activation encounters an existing
              # unmanaged dotfile it must replace.
              home-manager.backupFileExtension = "hm-backup";

              # Only necessary later if user modules need flake inputs.
              home-manager.extraSpecialArgs = { inherit inputs; };
            }

            ./configuration.nix
          ];
        };

      darwinModules = {
        base =
          { ... }:
          {
            system.stateVersion = 1;
            system.primaryUser = username;

            users.users.${username} = {
              name = username;
              home = "/Users/${username}";
            };
          };

        determinateNixConfig =
          { ... }:
          {
            determinateNix = {
              enable = true;
              customSettings = {
                eval-cores = 0;
                extra-experimental-features = [
                  "build-time-fetch-tree"
                ];
              };
            };
          };
      };

      devShells.${system}.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            (writeShellApplication {
              name = "apply-nix-darwin-configuration";
              runtimeInputs = [
                inputs.nix-darwin.packages.${system}.darwin-rebuild
              ];
              text = ''
		flakeRoot="/Users/daniel/dotfiles"

		echo "> Applying nix-darwin configuration..."
		sudo darwin-rebuild switch --flake "$flakeRoot#${username}-${system}"
		echo "> darwin-rebuild switch was successful ✅";
              '';
            })

            self.formatter.${system}
          ];
        };

      formatter.${system} =
        inputs.nixpkgs.legacyPackages.${system}.nixfmt;
    };
}
