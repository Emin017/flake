{ self, nixpkgs, home-manager, nixos-wsl, nix-darwin, deploy-rs, treefmt-nix
, disko, zenBrowser, ... }:
let
  user = "Emin";
  # Systems
  linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
  darwinSystems = [ "aarch64-darwin" ];
  allSystems = linuxSystems ++ darwinSystems;
  forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
  # Generate nixpkgs attributes for each system
  eachSystem = f:
    nixpkgs.lib.genAttrs allSystems
    (system: f nixpkgs.legacyPackages.${system});
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
  treefmtEval =
    eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
in {
  # Enter the devShell for this flake
  # Use command `nix develop` to enter the devShell
  devShells = forAllSystems devShell;

  # Import all the configurations
  # Use command `nix flake .#nixosConfigurations.nixos` to build the nixos configuration
  # Use command `nix flake .#darwinConfigurations.wsl` to build the macbook configuration
  nixosConfigurations = {
    nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        meta = { hostname = user; };
        inherit zenBrowser;
      };
      modules = [
        ../system/linux/nixos/config.nix
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              meta = { hostname = user; };
              inherit zenBrowser;
            };
            users.${user} = ../system/linux/nixos/home.nix;
          };
          nix.settings.trusted-users = [ user ];
        }
      ];
    };
    wsl = nixpkgs.lib.nixosSystem {
      specialArgs = { meta = { hostname = user; }; };
      modules = [
        ../system/linux/wsl/wsl.nix
        nixos-wsl.nixosModules.wsl
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { meta = { hostname = user; }; };
            users.${user} = import ../system/linux/wsl/home.nix;
            backupFileExtension = "backup";
          };
          nix.settings.trusted-users = [ "nixos" ];
        }
      ];
    };
    hydra = nixpkgs.lib.nixosSystem {
      specialArgs = { meta = { hostname = "hcloud"; }; };
      system = "x86_64-linux";
      modules = [
        ../system/hydra/hardware-configuration.nix
        ../system/hydra/common.nix
      ];
    };
  };
  # Import the darwin configurations
  # Use command `nix flake .#darwinConfigurations.macbook` to build the macbook configuration
  darwinConfigurations = {
    macbook = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ../system/darwin/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = import ../system/darwin/home.nix;
          };
        }
      ];
    };
  };
  # Home Manager configurations
  homeConfigurations = {
    "server" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ../system/linux/server/server.nix ];
      extraSpecialArgs = { meta = { hostname = user; }; };
    };
  };

  # Import the deploy configurations
  # Use command `nix run github:serokell/deploy-rs -- -d -s .#hydra` to deploy the configuration to the server
  deploy = {
    sshUser = "root";
    user = "root";
    sshOpts = [ "-p" "22" ];
    autoRollback = false;
    magicRollback = false;
    nodes = {
      hydra = {
        hostname = "hcloud";
        profiles = {
          hetzner = {
            user = "root";
            confirmTimeout = 300;
            path = deploy-rs.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.hydra;
          };
        };
      };
    };
  };
  # Import the darwin packages
  darwinPackages = self.darwinConfigurations.macbook.pkgs;
  # Import the hydra jobs
  hydraJobs = {
    nixos = self.nixosConfigurations.nixos.config.system.build.toplevel;
    wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
    hydra = self.nixosConfigurations.hydra.config.system.build.toplevel;
  };
  # Use nixfmt-classic as the formatter for all systems
  formatter =
    eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
  # Use the deploy-rs library to check the deployments
  checks = nixpkgs.lib.recursiveUpdate
    (builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy)
      deploy-rs.lib) (eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      }));
}
