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

  outputs = { self, nix-darwin, nixos-wsl, nixpkgs, home-manager, ... }:
    let
      # Change the user to your own username
      user = "nixos";
      homeDirectory = "/home/${user}";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [ git vim nixd ];
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
      # $ sudo nixos-rebuild switch --flake .#WSL
      nixosConfigurations."WSL" = nixpkgs.lib.nixosSystem {
        specialArgs = { meta = { hostname = user; }; };
        modules = [
          ./system/linux/wsl/wsl.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { meta = { hostname = user; }; };
              users.${user} = import ./system/linux/wsl/home.nix;
            };
          }
        ];
      };
      nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { meta = { hostname = user; }; };
        modules = [
          ./system/linux/nixos/config.nix
          # ./system/linux/nixos/config.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { meta = { hostname = user; }; };
              users.${user} = ./system/linux/nixos/home.nix;
            };
          }
        ];
      };
      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."MacBook".pkgs;
      # Format files using:
      # $ nix fmt
      formatter = nixpkgs.lib.genAttrs allSystems
        (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);
    };
}
