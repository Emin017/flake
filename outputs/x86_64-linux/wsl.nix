{ nixpkgs, nixos-wsl, home-manager, user, ... }:
let
  self = nixpkgs.lib.nixosSystem {
    specialArgs = { meta = { hostname = user; }; };
    modules = [
      ../../system/linux/wsl/wsl.nix
      nixos-wsl.nixosModules.wsl
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { meta = { hostname = user; }; };
          users.${user} = import ../../system/linux/wsl/home.nix;
          backupFileExtension = "backup";
        };
        nix.settings.trusted-users = [ "nixos" ];
      }
    ];
  };
in self
