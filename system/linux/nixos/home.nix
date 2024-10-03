{ lib, pkgs, meta, ... }: {
  # Change your usrnanme and user directory here
  home.username = lib.mkForce meta.hostname;
  home.homeDirectory = lib.mkForce "/home/${meta.hostname}";

  # Set cursor size
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Use home.packages to install packages
  home.packages = with pkgs; [
    neofetch
    nnn

    zip
    xz
    unzip

    v2raya

    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

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

    # for development
    vscode
    binutils
    gcc
    llvm_17
  ];

  imports = [
    ../../../modules/programs/zsh.nix
    ../../../modules/programs/git.nix
    ../../../modules/programs/direnv.nix
    ../../../modules/programs/dconf.nix
    ../../../modules/programs/neovim.nix
    ../../../modules/programs/i18n.nix
  ];
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
