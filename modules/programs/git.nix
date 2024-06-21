{pkgs, ...}: {
  # Setup git
  programs.git = {
    enable = true;
    userName = "Qiming Chu";
    userEmail = "cchuqiming@gmail.com";
  };
  # Enable lazygit
  programs.lazygit.enable = true;
}
