{ config, meta, ... }:
{
  age.secrets.wslUserPasswordHash.file = ./secrets/wsl-user-password-hash.age;

  users.users.${meta.username} = {
    isNormalUser = true;
    description = "Emin's NixOS";
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.age.secrets.wslUserPasswordHash.path;
  };
}
