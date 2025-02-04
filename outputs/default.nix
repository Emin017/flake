{ self, nixpkgs, home-manager, nixos-wsl, nix-darwin, deploy-rs, ... }:
let
  user = "nixos";
  # Systems
  linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
  darwinSystems = [ "aarch64-darwin" ];
  allSystems = linuxSystems ++ darwinSystems;
  forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
  # Arguments for the nixos configurations
  args = import ./args.nix {
    inherit self nixpkgs home-manager user nixos-wsl nix-darwin deploy-rs;
  };
  # Arguments for the devShell
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
  # Enter the devShell for this flake
  # Use command `nix develop` to enter the devShell
  devShells = forAllSystems devShell;

  # Import all the configurations
  # Use command `nix flake .#nixosConfigurations.nixos` to build the nixos configuration
  # Use command `nix flake .#darwinConfigurations.wsl` to build the macbook configuration
  nixosConfigurations = {
    nixos = import ./x86_64-linux/nixos.nix args.nixosArgs;
    wsl =
      import ./x86_64-linux/wsl.nix (args.nixosArgs // { inherit nixos-wsl; });
    hydra = import ./hydra args.hydraArgs;
  };
  # Import the darwin configurations
  # Use command `nix flake .#darwinConfigurations.macbook` to build the macbook configuration
  darwinConfigurations = {
    macbook = import ./aarch64-darwin/common.nix args.darwinArgs;
  };

  # Import the deploy configurations
  # Use command `nix run github:serokell/deploy-rs -- -d -s .#hydra` to deploy the configuration to the server
  deploy = import ./deploy (args.commonArgs // { inherit deploy-rs; });
  # Import the darwin packages
  darwinPackages = self.darwinConfigurations.macbook.pkgs;
  # Import the hydra jobs
  hydraJobs = import ./hydra/jobs.nix args.commonArgs;
  # Use nixfmt-classic as the formatter for all systems
  formatter = nixpkgs.lib.genAttrs allSystems
    (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);
  # Use the deploy-rs library to check the deployments
  checks =
    builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
    deploy-rs.lib;
}
