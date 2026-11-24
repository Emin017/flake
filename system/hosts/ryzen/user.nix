{
  pkgs,
  config,
  meta,
  ...
}:
{
  age.secrets.ryzenUserPasswordHash.file = ./secrets/ryzen-user-password-hash.age;

  users.users.${meta.username} = {
    isNormalUser = true;
    description = "${meta.username}'s NixOS";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    hashedPasswordFile = config.age.secrets.ryzenUserPasswordHash.path;
    packages = with pkgs; [
      neovim
      git
    ];
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "${meta.username}";
}
