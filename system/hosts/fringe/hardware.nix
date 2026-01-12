{
  config,
  pkgs,
  user,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  networking.hostId = "5b465bb4";

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    zfs.package = pkgs.zfs_unstable;
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = config.disko.devices.disk.main.content.partitions.esp.content.mountpoint;
      };
      systemd-boot = {
        enable = true;
        xbootldrMountPoint = config.disko.devices.disk.main.content.partitions.boot.content.mountpoint;
        extraInstallCommands = "${pkgs.coreutils}/bin/install -D -m0755 ${pkgs.refind}/share/refind/drivers_x64/* -t ${config.boot.loader.efi.efiSysMountPoint}/EFI/systemd/drivers";
      };
      timeout = 1;
    };
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    kernelParams = [
      # 1 GiB
      "zfs.zfs_arc_min=1073741824"
    ];
  };

  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-SKHynix_HFS001TFM9X179N_BSDCN43881040CI3E";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              label = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/efi";
                mountOptions = [ "umask=0077" ];
              };
            };
            boot = {
              label = "boot";
              size = "4G";
              type = "EA00";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            swap = {
              label = "swap";
              size = "32G";
              content = {
                type = "swap";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "fringe";
              };
            };
          };
        };
      };
    };
    zpool = {
      fringe = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          relatime = "on";
          compression = "zstd";
          xattr = "sa";
        };
        options.ashift = "12";

        datasets = {
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              mountpoint = "legacy";
            };
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
            };
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              mountpoint = "legacy";
            };
          };
        };
      };
    };
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth.enable = true;
    firmware = with pkgs; [
      # lnl-bt-firmware
    ];
  };
}
