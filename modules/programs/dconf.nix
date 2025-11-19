{ pkgs, ... }:
{
  # Enable dconf
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          pkgs.gnomeExtensions.gsconnect.extensionUuid
          "blur-my-shell@aunetx"
          "caffeine@eon"
        ];
      };
    };
  };
}
