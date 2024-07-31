{pkgs, ...}: {
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.nixos.shell = pkgs.zsh;
}
