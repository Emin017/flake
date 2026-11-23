# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  meta,
  lib,
  ...
}:
{

  imports =
    let
      modulePrefix = ./../../modules;
      modules =
        with builtins;
        with lib;
        modulePrefix
        |> readDir
        |> filterAttrs (name: type: type == "regular")
        |> attrNames
        |> filter (f: f != "minimal.nix") # This file will import zsh.nix and i18n.nix, which are duplicated
        |> map (f: modulePrefix + "/${f}");
    in
    modules
    ++ [
      # Include the results of the hardware scan.
      ./hardware.nix
      ./user.nix
      # TigerVNC 虚拟桌面
      ./rdp.nix
    ];

  nix.settings.experimental-features = [
    "nix-command"
    "pipe-operators"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "${meta.username}"
  ];
  nix.settings = {
    substituters = [
      # "https://nix-bin.hydro.ac/"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.mutableUsers = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsyRGpCSkN2pgWRCijloPnisVuMm4rY0Jn1qxX04rh5 cchuqiming@gmail.com"
  ];

  users.users."${meta.username}".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPsyRGpCSkN2pgWRCijloPnisVuMm4rY0Jn1qxX04rh5 cchuqiming@gmail.com"
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
      libpng
    ];
  };
  services.tailscale.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    git
    tailscale
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
