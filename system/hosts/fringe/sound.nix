{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  systemWide = config.services.pipewire.systemWide;
  ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";

  lnl-alsa-ucm-conf = pkgs.alsa-ucm-conf.overrideAttrs (oldAttrs: {
    src = fetchTarball {
      url = "https://github.com/alsa-project/alsa-ucm-conf/archive/421e37b.tar.gz";
      sha256 = "sha256:08rsv6wn32d9zrw1gl2jp7rqzj8m6bdkn0xc7drzf9gfbf6fvmpb";
    };
    installPhase = ''
      mkdir -p $out/share/alsa
      cp -r ucm2 $out/share/alsa/
    '';
    postInstall = "";
  });
in
{
  environment = {
    systemPackages = with pkgs; [ lnl-alsa-ucm-conf ];
    pathsToLink = [ "/share/alsa" ];
  };

  systemd = {
    services.pipewire.environment.ALSA_CONFIG_UCM2 = mkIf systemWide ALSA_CONFIG_UCM2;
    services.wireplumber.environment.ALSA_CONFIG_UCM2 = mkIf systemWide ALSA_CONFIG_UCM2;
    user.services.pipewire.environment.ALSA_CONFIG_UCM2 = mkIf (!systemWide) ALSA_CONFIG_UCM2;
    user.services.wireplumber.environment.ALSA_CONFIG_UCM2 = mkIf (!systemWide) ALSA_CONFIG_UCM2;
  };

  hardware.firmware = [
    pkgs.sof-firmware
    pkgs.alsa-firmware
  ];
}
