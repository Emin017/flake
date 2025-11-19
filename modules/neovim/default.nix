{ pkgs, lib, ... }:
let
  deps = import ../deps { inherit pkgs lib; };
  nvim = deps.modules.nvim;
  nvimRemote = deps.makeRemote nvim.src;
  nvimRev = nvim.src.rev;
in
{
  # This scripts is to fetch neovim configuration from github repo
  home.activation.makeNeovim = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    source ${deps.pullRemote} && _pullRemote ~/.config/nvim ${nvimRemote} ${nvimRev}
  '';
  programs.neovim = {
    enable = true;
  };
}
