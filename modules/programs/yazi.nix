{ pkgs, ... }:
let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "8ed253716c60f3279518ce34c74ca053530039d8";
    hash = "sha256-xY2yVCLLcXRyFfnmyP6h5Fw+4kwOZhEOCWVZrRwXnTA=";
  };
in {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    package = pkgs.yazi;
    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
      full-border = "${yazi-plugins}/full-border.yazi";
      max-preview = "${yazi-plugins}/max-preview.yazi";
    };
    initLua = "	require(\"full-border\"):setup()\n";
  };
}
