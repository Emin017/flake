{ config, pkgs, username, ... }: {
  imports = [ ./i18n.nix (import ./zsh.nix { inherit pkgs username; }) ];
}
