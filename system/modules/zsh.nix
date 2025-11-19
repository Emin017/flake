{ pkgs, meta, ... }:
{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.${meta.username}.shell = pkgs.zsh;
}
