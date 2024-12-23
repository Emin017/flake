{ self, deploy-rs, ... }: {
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
}
