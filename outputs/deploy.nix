{ self, inputs, ... }:
let
  inherit (inputs) deploy-rs;
  inherit (self) nixosConfigurations;
in
{
  # Import the deploy configurations
  # Use command `nix run github:serokell/deploy-rs -- -d -s .#hydra` to deploy the configuration to the server
  flake.deploy = {
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
            path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.hydra;
          };
        };
      };
    };
  };
}
