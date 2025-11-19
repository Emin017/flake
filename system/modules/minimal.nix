{
  config,
  pkgs,
  meta,
  ...
}:
{
  imports = [
    ./i18n.nix
    ./zsh.nix
  ];
}
