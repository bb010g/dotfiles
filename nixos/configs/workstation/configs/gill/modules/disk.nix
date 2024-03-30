{ config, lib, ... }:

{
  config = lib.mkMerge [
    # TODO(Dusk): allow defining this in disko
    # TODO(Dusk): systemd.mount(5) for Impermanence?
    {
      fileSystems."/".neededForBoot = true;
      fileSystems."/configroot".neededForBoot = true;
      fileSystems."/spoolroot".neededForBoot = true;
      fileSystems."/stateroot".neededForBoot = true;
      fileSystems."/logroot".neededForBoot = true;
      fileSystems."/cacheroot".neededForBoot = true;
      fileSystems."/tmproot".neededForBoot = true;

      fileSystems."/nix".neededForBoot = true;

      fileSystems."/var".neededForBoot = true;
      fileSystems."/home/bb010g".neededForBoot = true;
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
      networking.hostId = lib.mkOverride 500 "0b3e69d5";
      services.zfs.autoScrub.enable = true;
      services.zfs.trim.enable = true;
      virtualisation.containers.storage.settings.driver = "zfs";
    }
    {
      assertions = [
        {
          assertion = config.boot.loader.efi.canTouchEfiVariables;
          message = "User disk configuration expects the installation process to modify EFI boot variables.";
        }
        {
          assertion = config.boot.loader.systemd-boot.enable;
          message = "User disk configuration expects the systemd-boot EFI boot manager.";
        }
      ];
      boot.loader.efi.efiSysMountPoint = "/efi";
      # boot.loader.systemd-boot.xbootldrMountPoint = "/boot";
    }
    # Configure ZFS snapshots & replication
    {
      services.zrepl.enable = true;
      services.zrepl.settings.jobs = [
        {
          name = "snapjob";
          type = "snap";
          filesystems."gill-tank/home<" = true;
          filesystems."gill-tank/nixos<" = true;
          filesystems."gill-tank/nixos/logroot<" = true;
          filesystems."gill-tank/nixos/cacheroot<" = false;
          filesystems."gill-tank/nixos/tmproot<" = false;
          snapshotting.type = "periodic";
          snapshotting.interval = "15m";
          snapshotting.prefix = "zrepl_";
          pruning.keep = [
            {
              type = "grid";
              grid = "1x1h(keep=all) | 24x1h | 14x1d(keep=3)";
              regex = "^zrepl_.*";
            }
            {
              type = "regex";
              negate = true;
              regex = "^zrepl_.*";
            }
          ];
        }
      ];
    }
  ];
}
