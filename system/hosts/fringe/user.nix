{
  pkgs,
  config,
  meta,
  ...
}:
{
  age.secrets.fringeUserPasswordHash.file = ./secrets/fringe-user-password-hash.age;

  users.users.${meta.username} = {
    isNormalUser = true;
    description = "Emin's NixOS";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "uinput"
    ];
    hashedPasswordFile = config.age.secrets.fringeUserPasswordHash.path;
    packages = with pkgs; [
      neovim
    ];
  };
}
