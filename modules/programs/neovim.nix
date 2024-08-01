{ pkgs, ... }:
let
  nvimConfig = pkgs.fetchFromGitHub {
    owner = "Emin017";
    repo = "nvim";
    rev = "cc7c47169dab8846d2edf52ecc1ceb00b83bae19";
    sha256 = "sha256-NgqYoacYYC1SnfcosQZXNu7UBxW2I147rdgLKNuoUFg=";
  };
  nvimConfigFixed =
    pkgs.runCommand "nvim-config-fixed" { buildInputs = [ pkgs.coreutils ]; } ''
      cp -r ${nvimConfig} $out
      chmod -R u+rwX,go+rX,go-w $out
    '';
in {
  programs.neovim = { enable = true; };
  home.file.".config/nvim".source = nvimConfigFixed;
}
