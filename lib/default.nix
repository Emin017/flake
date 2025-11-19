{
  inputs,
  ...
}:
let
  inherit (inputs) home-manager nixpkgs;
in
{
  flake.libGen = {
    genNixSystem =
      username: hostname: system: modules: hmConfig:
      if !builtins.isString username then
        throw "genNixSystem: username must be a string"
      else if !builtins.isString hostname then
        throw "genNixSystem: hostname must be a string"
      else if !builtins.isString system then
        throw "genNixSystem: system must be a string"
      else if !builtins.isList modules then
        throw "genNixSystem: modules must be a list"
      else if !(hmConfig == null || builtins.isAttrs hmConfig) then
        throw "genNixSystem: hmConfig must be an attribute set or null"
      else
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            meta = {
              inherit username hostname;
            };
            inherit inputs;
          };
          modules =
            modules
            ++ [
              ../system/hosts/${hostname}/config.nix
            ]
            ++ nixpkgs.lib.optionals (hmConfig != null) [
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    meta = {
                      inherit username hostname;
                    };
                    inherit inputs;
                  };
                  users.${username} = ../system/hosts/${hostname}/home.nix;
                }
                // hmConfig;
              }
            ]
            ++ [
              {
                nix.settings.trusted-users = [ username ];
              }
            ];
        };

    genHomeManager =
      username: hostname: pkgs: modules:
      if !builtins.isString username then
        throw "genHomeManager: username must be a string"
      else if !builtins.isString hostname then
        throw "genHomeManager: hostname must be a string"
      else if !builtins.isAttrs pkgs then
        throw "genHomeManager: pkgs must be an attribute set"
      else if !builtins.isList modules then
        throw "genHomeManager: modules must be a list"
      else
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = modules ++ [ ../system/hosts/${hostname}/home.nix ];
          extraSpecialArgs = {
            meta = {
              inherit username hostname;
            };
          };
        };
  };
}
