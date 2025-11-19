{ pkgs, meta, ... }:
{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.${meta.hostname}.shell = pkgs.zsh;
}
