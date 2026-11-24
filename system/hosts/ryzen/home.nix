{
  lib,
  pkgs,
  meta,
  inputs,
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
    fastfetch
    nnn
    firefox
    lazygit

    zip
    xz
    unzip
    curl

    wl-clipboard

    fd
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
    nixd

    # productivity
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
    llvm_19
    llvmPackages_19.clang-tools
    cmake
    ninja
    python3
    ghostty
    gh
    tmux

    nodejs
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
      inputs.nur-packages.modules.magpie
      inputs.nur-packages.homeManagerModules.clash-verge-tailscale
    ];

  programs.clash-verge.tailscale = {
    enable = true;
    tailnet = "tail4121a.ts.net";
  };

  programs.pnpm = {
    enable = true;
  };
  services.magpie = {
    enable = true;
    package = inputs.nur-packages.legacyPackages.${pkgs.system}.magpie;
  };

  # Keep the program, credentials, and mutable review data in the user's home.
  # The webhook service also performs reconciliation; do not enable the legacy timer.
  systemd.user.services = {
    ecc-auto-review-webhook = {
      Unit = {
        Description = "ECC GitHub App webhook receiver and review workers (Go)";
        After = [ "magpie.service" ];
        Wants = [ "magpie.service" ];
        ConditionPathExists = "%h/.config/ecc-auto-review/app.json";
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h/Workbench/auto-review";
        Environment = "PATH=%h/.local/share/pnpm/bin:%h/.local/bin:%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
        ExecStart = "%h/Workbench/auto-review/bin/ecc-auto-review --serve --max-parallel 4";
        Restart = "on-failure";
        RestartSec = 30;
        TimeoutStopSec = 15;
        UMask = "0077";
        KillMode = "control-group";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = [ "default.target" ];
    };

    ecc-auto-review-tunnel = {
      Unit = {
        Description = "Cloudflare Tunnel for ECC auto-review webhook";
        After = [
          "network-online.target"
          "ecc-auto-review-webhook.service"
        ];
        Wants = [
          "network-online.target"
          "ecc-auto-review-webhook.service"
        ];
        ConditionPathExists = "%h/.config/cloudflared/ecc-auto-review.env";
      };
      Service = {
        Type = "simple";
        WorkingDirectory = "%h/Workbench/auto-review";
        EnvironmentFile = "%h/.config/cloudflared/ecc-auto-review.env";
        Environment = [
          "HTTP_PROXY=http://127.0.0.1:7897"
          "HTTPS_PROXY=http://127.0.0.1:7897"
          "ALL_PROXY=http://127.0.0.1:7897"
          "NO_PROXY=127.0.0.1,localhost"
        ];
        ExecStart = "${pkgs.nix} run ${pkgs.cloudflared} -- tunnel run --token \${CLOUDFLARED_TUNNEL_TOKEN} --url http://127.0.0.1:8787 --protocol http2";
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 15;
        UMask = "0077";
        KillMode = "control-group";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install.WantedBy = [ "default.target" ];
    };
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
