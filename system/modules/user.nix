{ pkgs, meta, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${meta.username} = {
    isNormalUser = true;
    description = "Emin's NixOS";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    hashedPassword = "$y$j9T$9s9RRRZIu5a3/VV35QOQ31$WHtff4z3zBCIt5iH4XGT0SZ2Lbmrb9o7FSuqu9WKTxA";
    packages = with pkgs; [
      #  thunderbird
      # firefox
      neovim
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "Emin";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
