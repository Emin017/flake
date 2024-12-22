{ config, ... }: {
  services.hydra = {
    enable = true;
    listenHost = "127.0.0.1";
    port = 3000;
    hydraURL = "https://hydra.eminrepo.cc";
    notificationSender = "hydra@eminrepo";
    buildMachinesFiles = [ ];
    useSubstitutes = true;
  };
  networking.firewall = { allowedTCPPorts = [ 3000 ]; };

  services.harmonia = {
    enable = true;
    # Generate a key with:
    # $ nix-store --generate-binary-cache-key user.youdomain.tld /var/lib/secrets/secrets-key.pem /var/lib/secrets/secrets.pub
    signKeyPaths = [ "/var/lib/secrets/serets-key.pem" ];
    settings = { bind = "127.0.0.1:5000"; };
  };
}
