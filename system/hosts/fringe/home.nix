{
  lib,
  pkgs,
  meta,
  inputs,
  ...
}:
let
  deps = import ../../../modules/deps { inherit pkgs lib; };
  blur-my-shell = pkgs.callPackage ../../../modules/deps/blur-my-shell.nix {
    source = deps.modules.blur-my-shell;
  };
  # gnomeExtensions already follows GNOME 51 (NixOS/nixpkgs#575552) while gnome-shell is still 50
  # until NixOS/nixpkgs#559510 leaves staging; v94 only declares GNOME 51, v92 is the GNOME 49/50 release
  kimpanel =
    if lib.versionOlder pkgs.gnome-shell.version "51" then
      pkgs.gnomeExtensions.kimpanel.overrideAttrs {
        version = "92";
        src = pkgs.fetchzip {
          url = "https://extensions.gnome.org/extension-data/kimpanelkde.org.v92.shell-extension.zip";
          hash = "sha256-ad9NaWmXN+nWXkkqOGVhwSiYWXiYk0KTFKVl412m4n0=";
          stripRoot = false;
        };
      }
    else
      pkgs.gnomeExtensions.kimpanel;
in
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
    fastfetch
    wget
    tree
    fd

    tigervnc
    wl-clipboard

    zip
    xz
    unzip

    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    icdiff

    lazygit # A simple terminal UI for git

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
    gnomeExtensions.appindicator # Tray icons (StatusNotifier/AppIndicator) support
    gnomeExtensions.clipboard-indicator
    kimpanel # pinned to the GNOME 50 release, see above
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-dock
    gnomeExtensions.rounded-window-corners-reborn
    blur-my-shell # upstream master, see modules/deps/blur-my-shell.nix

    # for development
    vscode
    zed-editor

    ghostty
    nixd
    binutils
    gcc
    cmake
    llvm_20
    nodejs
    pnpm
    bubblewrap

    # jetbrains.idea

    # Social
    wechat
    discord
    wemeet
    feishu

    wpsoffice-cn
    mailspring
    obsidian
  ];

  imports =
    let
      modulePrefix = ../../../modules/programs;
      modules =
        with builtins;
        modulePrefix
        |> readDir
        |> attrNames
        |> lib.filter (f: f != "yazi.nix" && f != "restic.nix")
        |> map (f: modulePrefix + "/${f}");
    in
    modules
    ++ [
      ../../../modules/neovim
      inputs.zen-browser.homeModules.beta
      inputs.nur-packages.modules.magpie
    ];
  programs.zen-browser.enable = true;
  programs.zen-browser.policies = {
    DisableAppUpdate = true;
    DisableTelemetry = true;
  };

  # magpie 托盘应用：跟随图形会话自启动（模块来自 Emin017/nur-packages）
  services.magpie = {
    enable = true;
    package = inputs.nur-packages.legacyPackages.${pkgs.system}.magpie;
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
