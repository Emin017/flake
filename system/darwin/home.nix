{ config, pkgs, lib, ... }: {
  home.stateVersion = "24.05";
  home.username = lib.mkForce "qimingchu";
  home.homeDirectory = lib.mkForce "/Users/qimingchu";

  home.packages = with pkgs;
    [
      curl
      wget
      neofetch
      zip
      xz
      unzip
      nixd

      ripgrep
      jq
      fzf
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      gnupg

      glow # markdown previewer in terminal

      btop # replacement of htop/nmon
      iftop # network monitoring
      yazi
    ] ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];

  imports = [
    ../../modules/programs/git.nix
    ../../modules/programs/direnv.nix
    ../../modules/programs/yazi.nix
    ../../modules/neovim
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
