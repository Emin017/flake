{
  description = "Emin's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixos-wsl,
    nixpkgs,
    home-manager,
  }: let
    linuxSystems = ["x86_64-linux" "aarch64-linux"];
    darwinSystems = ["aarch64-darwin"];
    # Change the user to your own username
    user = "nixos";
    forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = with pkgs;
        mkShell {
          nativeBuildInputs = with pkgs; [git vim nixd];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
    };
  in {
    devShells = forAllSystems devShell;
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MacBook
    darwinConfigurations."MacBook" = nix-darwin.lib.darwinSystem {
      modules = [
        ./system/darwin/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = import ./system/darwin/home.nix;
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          };
        }
      ];
    };
    # Build wsl flake using:
    # $ darwin-rebuild build --flake .#WSL
    nixosConfigurations."WSL" = nixpkgs.lib.nixosSystem {
      modules = [
        ./system/linux/wsl/wsl.nix
        nixos-wsl.nixosModules.wsl
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = import ./system/linux/wsl/home.nix;
          };
        }
      ];
    };
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook".pkgs;
    # Format files using:
    # $ nix fmt
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
