{
  description = "Emin's nix flake";

  nixConfig = {
    # a self host nix cache for Emin's nix store
    extra-trusted-substituters = [
      "https://serve.eminrepo.cc/"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
    ];
    extra-trusted-public-keys =
      [ "serve.eminrepo.cc:fgdTGDMn75Z0NOvTmus/Z9Fyh6ExgoqddNVkaYVi5qk=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = inputs: import ./outputs inputs;

}
