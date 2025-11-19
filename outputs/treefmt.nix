# treefmt.nix
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  # Enable the nixfmt-rfc-style program
  programs.nixfmt.enable = true; # nix
}
