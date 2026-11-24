{
  self,
  inputs,
  ...
}:
with self.libGen;
let
  users = {
    emin = "emin";
    Emin = "Emin";
  };
  inherit (inputs)
    home-manager
    disko
    nixos-wsl
    nixpkgs
    ;
  inherit (inputs.nix-darwin.lib) darwinSystem;
in
{
  flake = {
    nixosConfigurations = {
      # Use command `nix flake .#nixosConfigurations.fringe` to build the nixos configuration
      fringe = genNixSystem users.Emin "fringe" "x86_64-linux" [ disko.nixosModules.disko ] {
        backupFileExtension = "backup";
      };
      ryzen = genNixSystem users.emin "ryzen" "x86_64-linux" [ ] { backupFileExtension = "backup"; };
      # Use command `nix flake .#darwinConfigurations.wsl` to build the macbook configuration
      wsl = genNixSystem users.Emin "wsl" "x86_64-linux" [ nixos-wsl.nixosModules.wsl ] {
        backupFileExtension = "backup";
      };
      hydra = genNixSystem users.emin "hydra" "x86_64-linux" [
        ./hosts/hydra/hardware-configuration.nix
      ] null;
    };
    # Home Manager configurations
    homeConfigurations = {
      "server" = genHomeManager users.Emin "server" nixpkgs.legacyPackages.x86_64-linux [ ];
    };
    # Import the darwin configurations
    # Use command `nix flake .#darwinConfigurations.macbook` to build the macbook configuration
    darwinConfigurations = {
      macbook = darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/darwin/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.qimingchu = import ./hosts/darwin/home.nix;
            };
          }
        ];
      };
    };
  };
}
