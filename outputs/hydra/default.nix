{ nixpkgs, ... }:
let
  self = nixpkgs.lib.nixosSystem {
    specialArgs = { meta = { hostname = "hcloud"; }; };
    system = "x86_64-linux";
    modules = [
      ../../system/hydra/hardware-configuration.nix
      ../../system/hydra/common.nix
    ];
  };
in self
