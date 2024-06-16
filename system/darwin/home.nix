{
  config,
  pkgs,
  lib,
  ...
}: {
  home.stateVersion = "24.05";
  home.username = "qimingchu";
  home.homeDirectory = "/Users/qimingchu";

  # Direnv, load and unload environment variables depending on the current directory.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

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
    ]
    ++ lib.optionals stdenv.isDarwin [
      cocoapods
      m-cli # useful macOS CLI commands
    ];
  # git 相关配置
  programs.git = {
    enable = true;
    userName = "Qiming Chu";
    userEmail = "cchuqiming@gmail.com";
  };

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
