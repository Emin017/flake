{ config, meta, ... }:
{
  age.secrets.hydraUserPasswordHash.file = ./secrets/hydra-user-password-hash.age;

  users.users.${meta.username} = {
    isNormalUser = true;
    description = "Emin's NixOS";
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.age.secrets.hydraUserPasswordHash.path;
  };
}
