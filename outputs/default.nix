{
  self,
  nixpkgs,
  home-manager,
  nixos-wsl,
  nix-darwin,
  deploy-rs,
  treefmt-nix,
  disko,
  zenBrowser,
  parts,
  ...
}@inputs:
let
  user = "Emin";
in
parts.lib.mkFlake { inherit inputs; } {
  systems = [
    "x86_64-linux"
    "aarch64-darwin"
  ];
  imports = [
    treefmt-nix.flakeModule
  ];
  flake = {
    nixosConfigurations = {
      # Use command `nix flake .#nixosConfigurations.fringe` to build the nixos configuration
      fringe = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          meta = {
            username = user;
            hostname = "fringe";
          };
          inherit zenBrowser;
        };
        modules = [
          ../system/hosts/fringe/config.nix
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                meta = {
                  username = user;
                  hostname = "fringe";
                };
                inherit zenBrowser;
              };
              users.${user} = ../system/hosts/fringe/home.nix;
            };
            nix.settings.trusted-users = [ user ];
          }
        ];
      };
      # Use command `nix flake .#darwinConfigurations.wsl` to build the macbook configuration
      wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {
          meta = {
            username = user;
            hostname = "wsl";
          };
        };
        modules = [
          ../system/hosts/wsl/wsl.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                meta = {
                  username = user;
                  hostname = "wsl";
                };
              };
              users.${user} = import ../system/hosts/wsl/home.nix;
              backupFileExtension = "backup";
            };
            nix.settings.trusted-users = [ "nixos" ];
          }
        ];
      };
      hydra = nixpkgs.lib.nixosSystem {
        specialArgs = {
          meta = {
            hostname = "hcloud";
          };
        };
        system = "x86_64-linux";
        modules = [
          ../system/hosts/hydra/hardware-configuration.nix
          ../system/hosts/hydra/common.nix
        ];
      };
    };
    # Home Manager configurations
    homeConfigurations = {
      "server" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ../system/hosts/server/server.nix ];
        extraSpecialArgs = {
          meta = {
            username = user;
            hostname = "server";
          };
        };
      };
    };
    # Import the darwin configurations
    # Use command `nix flake .#darwinConfigurations.macbook` to build the macbook configuration
    darwinConfigurations = {
      macbook = nix-darwin.lib.darwinSystem {
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
    # Import the deploy configurations
    # Use command `nix run github:serokell/deploy-rs -- -d -s .#hydra` to deploy the configuration to the server
    deploy = {
      sshUser = "root";
      user = "root";
      sshOpts = [
        "-p"
        "22"
      ];
      autoRollback = false;
      magicRollback = false;
      nodes = {
        hydra = {
          hostname = "hcloud";
          profiles = {
            hetzner = {
              user = "root";
              confirmTimeout = 300;
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hydra;
            };
          };
        };
      };
    };
    # Import the hydra jobs
    hydraJobs = {
      nixos = self.nixosConfigurations.nixos.config.system.build.toplevel;
      wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
      hydra = self.nixosConfigurations.hydra.config.system.build.toplevel;
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
            nativeBuildInputs = with pkgs; [
              git
              vim
              nixd
            ];
            shellHook = ''
              export EDITOR=vim
            '';
          };
      };
      imports = [
        ./treefmt.nix
      ];
    };
}
