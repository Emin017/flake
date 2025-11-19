{ pkgs, meta, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${meta.hostname} = {
    isNormalUser = true;
    description = "Emin's NixOS";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPassword =
      "$y$j9T$/Q3RRMjw264NerMQa4C3Z/$nZmWm63fXW2V6dUeQvQ0zafoRiJlHNnZeFS7RytH6T7";
    packages = with pkgs;
      [
        #  thunderbird
        # firefox
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
