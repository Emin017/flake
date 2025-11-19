{
  lib,
  pkgs,
  meta,
  config,
  zenBrowser,
  ...
}:
{
  # Change your usrnanme and user directory here
  home.username = lib.mkForce meta.username;
  home.homeDirectory = lib.mkForce "/home/${meta.username}";

  # Set cursor size
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Use home.packages to install packages
  home.packages = with pkgs; [
    git
    neofetch
    wget

    zip
    xz
    unzip

    v2raya

    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    icdiff

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    gnomeExtensions.caffeine # Keep monitor awake
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.kimpanel
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-dock
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.blur-my-shell

    # for development
    vscode
    ghostty
    nixd
    binutils
    gcc
    cmake
    llvm_20
    nodejs

    jetbrains.idea-ultimate

    # Social
    wechat
    discord
    wemeet
    feishu
  ];

  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.gsconnect.extensionUuid
          pkgs.gnomeExtensions.caffeine.extensionUuid
          pkgs.gnomeExtensions.clipboard-indicator.extensionUuid
          pkgs.gnomeExtensions.vitals.extensionUuid
          pkgs.gnomeExtensions.dash-to-dock.extensionUuid
          pkgs.gnomeExtensions.rounded-window-corners-reborn.extensionUuid
          pkgs.gnomeExtensions.kimpanel.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
        ];
      };
    };
  };

  imports =
    let
      modules =
        with builtins;
        ../../../modules/programs |> readDir |> attrNames |> map (f: ../../../modules/programs + "/${f}");
    in
    modules ++ [ zenBrowser.homeModules.beta ];
  programs.zen-browser.enable = true;
  programs.zen-browser.policies = {
    DisableAppUpdate = true;
    DisableTelemetry = true;
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
