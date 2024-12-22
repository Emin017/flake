{ self, ... }: {
  nixosConfigurations = {
    nixos = self.nixosConfigurations.nixos.config.system.build.toplevel;
    wsl = self.nixosConfigurations.wsl.config.system.build.toplevel;
    hydra = self.nixosConfigurations.hydra.config.system.build.toplevel;
  };
}

