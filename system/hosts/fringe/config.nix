# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports =
    let
      modules =
        with builtins;
        with lib;
        ./../../modules
        |> readDir
        |> filterAttrs (name: type: type == "regular")
        |> attrNames
        |> filter (f: f != "minimal.nix") # This file will import zsh.nix and i18n.nix, which are duplicated
        |> map (f: ./../../modules + "/${f}");
    in
    modules
    ++ [
      # Include the results of the hardware scan.
      ./hardware.nix
      ./sound.nix
    ];

  # workaround for https://github.com/NixOS/nixpkgs/issues/6481
  systemd.tmpfiles.rules = lib.concatLists (
    lib.mapAttrsToList (
      _: user:
      lib.optionals user.createHome [
        "d ${lib.escapeShellArg user.home} ${user.homeMode} ${user.name} ${user.group}"
      ]
    ) config.users.users
  );

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.printing.drivers = [ pkgs.brlaser ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  virtualisation.docker.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall.extraCommands =
    let
      dockerSubnet = "172.17.0.0/16";
    in
    ''
      iptables -t nat -I TP_RULE 1 -s ${dockerSubnet} -j RETURN || true
    '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
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
