{ config, lib, ... }:

{
  config = lib.mkMerge [
    {
      boot.loader.efi.efiSysMountPoint = "/efi";

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/79a0b269-ed1c-4475-8cf1-247a73ce3353";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };

      fileSystems."/efi" = {
        device = "/dev/disk/by-uuid/2A8C-E551";
        fsType = "vfat";
        options = [ "x-systemd.automount" "x-systemd.mount-timeout=1s" ];
      };

      swapDevices = [
        { device = "/dev/disk/by-uuid/a5f7aa1b-131b-4530-b99a-60266a1bac51"; }
      ];
    }
    {
      assertions = [
        {
          assertion = config.boot.initrd.systemd.enable;
          message = "User disk configuration expects systemd in initrd.";
        }
      ];
      boot.initrd.supportedFilesystems.vfat = true;
      boot.initrd.supportedFilesystems.zfs = true;
      # boot.zfs.allowHibernation = true; # swap is not on ZFS
      boot.zfs.devNodes = "/dev/disk/by-partuuid";
      # boot.zfs.forceImportRoot = false;
      networking.hostId = lib.mkOverride 500 "6db95b20";
    }
    {
      assertions = [
        {
          assertion = config.boot.loader.efi.canTouchEfiVariables;
          message = "User disk configuration expects the installation process to modify EFI boot variables.";
        }
        # {
        #   assertion = config.boot.loader.systemd-boot.enable;
        #   message = "User disk configuration expects the systemd-boot EFI boot manager.";
        # }
      ];
      boot.loader.efi.efiSysMountPoint = "/efi";
      # boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
    }
  ];
}
