{
  self,
  inputs,
  user,
  ...
}:
with self.libGen;
let
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
      fringe = genNixSystem user "fringe" "x86_64-linux" [ disko.nixosModules.disko ] { };
      # Use command `nix flake .#darwinConfigurations.wsl` to build the macbook configuration
      wsl = genNixSystem user "wsl" "x86_64-linux" [ nixos-wsl.nixosModules.wsl ] {
        backupFileExtension = "backup";
      };
      hydra = genNixSystem user "hydra" "x86_64-linux" [
        ../system/hosts/hydra/hardware-configuration.nix
      ] null;
    };
    # Home Manager configurations
    homeConfigurations = {
      "server" = genHomeManager user "server" nixpkgs.legacyPackages.x86_64-linux [ ];
    };
    # Import the darwin configurations
    # Use command `nix flake .#darwinConfigurations.macbook` to build the macbook configuration
    darwinConfigurations = {
      macbook = darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ../system/hosts/darwin/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ../system/hosts/darwin/home.nix;
            };
          }
        ];
      };
    };
  };
}
