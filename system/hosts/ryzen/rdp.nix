# ryzen 的远程桌面：RDP（gnome-remote-desktop）
#
#   sudo grdctl --system rdp set-credentials <用户名> <密码>
#   sudo grdctl --system rdp enable
#   sudo systemctl restart gnome-remote-desktop
# 查看状态：grdctl --system rdp status
{ pkgs, ... }:
{
  services.gnome.gnome-remote-desktop.enable = true;

  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];
  systemd.services.gnome-remote-desktop.after = [ "grd-rdp-config.service" ];
  systemd.services.gnome-remote-desktop.wants = [ "grd-rdp-config.service" ];

  networking.firewall.allowedTCPPorts = [ 3389 ];

  environment.etc."gnome-remote-desktop/grd.conf".text = ''
    [RDP]
    enabled=true
    port=3389
    tls-cert=/var/lib/gnome-remote-desktop/tls.crt
    tls-key=/var/lib/gnome-remote-desktop/tls.key
  '';

  systemd.services.grd-rdp-config = {
    description = "Seed gnome-remote-desktop RDP config and self-signed TLS cert";
    wantedBy = [ "graphical.target" ];
    before = [ "gnome-remote-desktop.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu
      dir=/var/lib/gnome-remote-desktop
      conf=$dir/.local/share/gnome-remote-desktop/grd.conf
      ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$conf")"
      if [ ! -s "$dir/tls.crt" ] || [ ! -s "$dir/tls.key" ]; then
        ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 \
          -keyout "$dir/tls.key" -out "$dir/tls.crt" -days 3650 -nodes \
          -subj "/CN=ryzen" >/dev/null 2>&1
      fi
      ${pkgs.coreutils}/bin/printf '[RDP]\nenabled=true\nport=3389\ntls-cert=%s\ntls-key=%s\n' \
        "$dir/tls.crt" "$dir/tls.key" > "$conf"
      ${pkgs.coreutils}/bin/chown -R gnome-remote-desktop:gnome-remote-desktop "$dir"
      ${pkgs.coreutils}/bin/chmod 0600 "$conf" "$dir/tls.key"
      ${pkgs.coreutils}/bin/chmod 0644 "$dir/tls.crt"
    '';
  };

  # Debug from ssh terminal
  environment.systemPackages = [ pkgs.freerdp ];
}
