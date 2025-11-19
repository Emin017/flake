{ lib, ... }:
{
  # This file is just an example, please replace the content with your nixos configuration
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8" ];
    defaultGateway = "172.22.1.1";
    defaultGateway6 = {
      address = "fa70::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "2.131.87.17";
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "2e91:4ef:e0:a524::1";
            prefixLength = 64;
          }
          {
            address = "fe80::92dd:3ff:ffbe:f6fa";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "172.22.1.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "172.22.1.1";
            prefixLength = 128;
          }
        ];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="95:00:03:be:f6:fa", NAME="eth0"

  '';
}
