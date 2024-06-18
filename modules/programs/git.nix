{pkgs, ...}: {
  # Setup git
  programs.git = {
    enable = true;
    userName = "nixos";
    userEmail = "cchuqiming@gmail.com";
  };
  # Enable lazygit
  programs.lazygit.enable = true;
}
