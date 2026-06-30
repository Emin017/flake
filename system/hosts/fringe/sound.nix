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
    src = pkgs.fetchgit {
      url = "https://github.com/alsa-project/alsa-ucm-conf.git";
      rev = "858d3a2443c66a7d5a2b5598308619237e8fc75d";
      sha256 = "sha256-Vds79ITUSZOqg4yf/dnYu2muxrvJuYBpvrtde/7+m9Y=";
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
