{ nixpkgs, home-manager, user, ... }:
let
  self = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { meta = { hostname = user; }; };
    modules = [
      ../../system/linux/nixos/config.nix
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { meta = { hostname = user; }; };
          users.${user} = ../../system/linux/nixos/home.nix;
        };
        nix.settings.trusted-users = [ "nixos" ];
      }
    ];
  };
in self
