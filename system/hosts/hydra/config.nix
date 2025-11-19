{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix
    ./hydra.nix
  ];
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "hcloud";
  networking.domain = "";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzeeeeeeeeeefasjdfkjasdlfajsdflaljkkkkkkkkjghkhF user@example.com"
  ];

  nix = {
    settings = {
      trusted-users = [
        "root"
        "hydra"
      ];
      auto-optimise-store = true;
      allowed-uris = [
        "https://github.com"
        "https://gitlab.com"
        "github:"
      ];
      max-jobs = 1;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override { modules = [ pkgs.nginxModules.zstd ]; };
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."serve.eminrepo.cc" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          # ssl is very important
          ssl = true;
        }
      ];
      locations."/".proxyPass = "http://127.0.0.1:5000";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 1024M;

        zstd on;
        zstd_types application/x-nix-archive;
      '';
      forceSSL = true;
      useACMEHost = "serve.eminrepo.cc";
      acmeRoot = "/var/lib/acme/machine-cache";
    };
    virtualHosts."hydra.eminrepo.cc" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          # ssl is very important
          ssl = true;
        }
      ];
      locations."/".proxyPass =
        "http://${config.services.hydra.listenHost}:${toString config.services.hydra.port}";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
      forceSSL = true;
      useACMEHost = "hydra.eminrepo.cc";
      acmeRoot = "/var/lib/acme/machine-hydra";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "user@examples.com";
    certs."serve.eminrepo.cc" = {
      webroot = "/var/lib/acme/machine-cache";
      group = "nginx";
    };
    certs."hydra.eminrepo.cc" = {
      webroot = "/var/lib/acme/machine-hydra";
      group = "nginx";
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.nginx.defaultHTTPListenPort
    config.services.nginx.defaultSSLListenPort
  ];

  environment = {
    systemPackages = with pkgs; [
      git
      wget
      curl
      lsof
      nethogs
      htop
      fastfetch

      neovim
      rsync
    ];
  };
  system.stateVersion = "24.05";
}
