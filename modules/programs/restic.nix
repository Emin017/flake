{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.restic ];

  home.file.".config/restic/restic-env".text = ''
    export B2_ACCOUNT_ID=<YOUR_ACCOUNT_ID>
    export B2_ACCOUNT_KEY=<YOUR_ACCOUNT_KEY>
    export RESTIC_REPOSITORY=b2:<YOUR_BUCKET_NAME>:<YOUR_BUCKET_PATH>
    export RESTIC_PASSWORD_FILE=~/.config/restic/restic-password
  '';
  home.file.".config/restic/restic-password".text = ''
    YOUR_PASSWORD
  '';
  home.file.".config/restic/backup.sh".text = ''
    #!/bin/env bash
    restic backup --exclude-caches \
    --exclude .Trash --exclude .DS_Store --exclude .localized \
    --exclude .Spotlight-V100 --exclude .fseventsd \
    --exclude .DocumentRevisions-V100 --exclude .MobileBackups \
    --exclude .VolumeIcon.icns --exclude .PKInstallSandboxManager \
    ~/Documents ~/Desktop ~/Downloads ~/Pictures ~/Movies
  '';
}
