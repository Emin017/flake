# treefmt.nix
{ pkgs, ... }: {
  # Used to find the project root
  projectRootFile = "flake.nix";
  # Enable the nixfmt-classic program
  programs.nixfmt-classic.enable = true; # nix
}
