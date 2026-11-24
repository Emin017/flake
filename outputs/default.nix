{
  self,
  nixpkgs,
  deploy-rs,
  treefmt-nix,
  parts,
  ...
}@inputs:
parts.lib.mkFlake { inherit inputs; } {
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
  imports = [
    treefmt-nix.flakeModule
    ./../system
    ./../lib
    ./deploy.nix
  ];
  flake = {
    # Import the deploy configurations
    # Import the hydra jobs
    hydraJobs = {
      fringe = self.nixosConfigurations.fringe.config.system.build.toplevel;
      wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
      hydra = self.nixosConfigurations.hydra.config.system.build.toplevel;
      ryzen = self.nixosConfigurations.ryzen.config.system.build.toplevel;
    };
    checks = nixpkgs.lib.recursiveUpdate (builtins.mapAttrs (
      system: deployLib: deployLib.deployChecks self.deploy
    ) deploy-rs.lib) { };
  };
  perSystem =
    {
      inputs',
      pkgs,
      system,
      ...
    }:
    {

      devShells = {
        default =
          with pkgs;
          mkShell {
            nativeBuildInputs =
              with pkgs;
              [
                git
                vim
                nixd
                openssh
                inputs'.agenix.packages.default
              ]
              ++ lib.optionals stdenv.hostPlatform.isLinux [ wl-clipboard ];
            shellHook = ''
              export EDITOR=vim
              source ${../scripts/agenix.sh}
              export -f _agenix_repo_root agenix-decrypt agenix-rekey agenix-password agenix-onboard agenix-help
            '';
          };
      };
      imports = [
        ./treefmt.nix
      ];
    };
}
