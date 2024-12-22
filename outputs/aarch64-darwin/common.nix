{ nix-darwin, home-manager, user, ... }:
let
  self = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ../../system/darwin/darwin.nix
      home-manager.darwinModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user} = import ../../system/darwin/home.nix;
        };
      }
    ];
  };
in self
