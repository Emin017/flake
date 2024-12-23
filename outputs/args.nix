{ self, nixpkgs, home-manager, user, nix-darwin, ... }: {
  # Arguments for the nixos configurations
  commonArgs = { inherit self user; };
  nixosArgs = {
    inherit nixpkgs home-manager user;
    system = "x86_64-linux";
  };
  hydraArgs = {
    inherit nixpkgs;
    system = "x86_64-linux";
  };
  # Arguments for the darwin configurations
  darwinArgs = {
    inherit nixpkgs nix-darwin home-manager user;
    system = "aarch64-darwin";
  };
}
