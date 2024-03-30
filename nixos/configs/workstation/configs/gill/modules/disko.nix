{ lib, ... }:

{
  disko.devices.disk.a = {
    device = "/dev/sda";
    content.type = "gpt";
    content.partitions.ESP = {
      size = "512M";
      type = "EF00";
      priority = 100;
      content.type = "filesystem";
      content.format = "vfat";
      content.mountpoint = "/efi";
      content.mountOptions = [ "x-systemd.automount" "x-systemd.mount-timeout=1s" ];
    };
    content.partitions.XBOOTLDR = {
      size = "4G";
      type = "EA00";
      priority = 150;
      content.type = "filesystem";
      content.format = "vfat";
      content.mountpoint = "/boot";
      content.mountOptions = [ "x-systemd.automount" "x-systemd.mount-timeout=1s" ];
    };
    content.partitions.swap = {
      size = "8G";
      priority = 300;
      content.type = "swap";
      content.resumeDevice = true;
    };
    content.partitions.zfs = {
      size = "100%";
      type = "BF00"; # Solaris root
      content.type = "zfs";
      content.pool = "gill-tank";
    };
  };

  disko.devices.zpool.gill-tank = { config, ... }: let
    _parent = config;
    ensureSnapshotHook = datasetName: snapshotName: ''
      { zfs get -H -t snapshot -o name name ${datasetName}@${snapshotName} | grep -E '^${datasetName}@${snapshotName}$'; } || zfs snapshot ${datasetName}@${snapshotName}'';
  in {
    config.mode = "";
    config.options."ashift" = "12";
    # config.options."bootfs" = "nixos";
    # config.options."cachefile" = "none";
    # config.rootFsOptions."atime" = "off";
    config.rootFsOptions."canmount" = "noauto";
    config.rootFsOptions."com.sun:auto-snapshot" = "false";
    config.rootFsOptions."compression" = "zstd";
    config.rootFsOptions."dnodesize" = "auto";
    config.rootFsOptions."recordsize" = "64K";
    config.rootFsOptions."relatime" = "on";
    config.rootFsOptions."xattr" = "sa";

    config.postCreateHook = ''zpool set bootfs=${config.name}/nixos ${config.name}'';

    config.datasets."reservation" = let config = { name = "reservation"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      options.mountpoint = "none";
      options.readonly = "on";
      options.redundant_metadata = "some";
      options.refreservation = "186.3G"; # 931.5GiB * 20%
    };

    config.datasets."nix" = let config = { name = "nix"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/nix"; # config.options.mountpoint
      options.acltype = "posix";
      options.atime = "off";
      options.mountpoint = "/nix";
      options.xattr = "sa";
    };

    # nixos
    # nixos/STATE
    # nixos/STATE/home
    # nixos/STATE/roothome
    # nixos/CACHE
    # nixos/RUNTIME
    # nixos/RUNTIME/sysroot

    # root/nixos # sysroot: mountpoint=/ (rolled back on boot to nixos@blank)
    # root/nixos/stateroot # permanent stateroot (like stateroot)
    # root/nixos/var # impermanent stateroot (like cacheroot)
    # root/nixos/var/cache # cacheroot
    # root/nixos/var/tmp # temproot
    # home # canmount=noauto mountpoint=/home
    # home/bb010g

    # root/nixos/configroot # configroot (like /etc/)
    # root/nixos/spoolroot # spoolroot (like /var/spool/)
    # root/nixos/stateroot # stateroot (like /var/lib/)
    # root/nixos/logroot # logroot (like /var/log/)
    # root/nixos/cacheroot # cacheroot (like /var/cache/)
    # root/nixos/tmproot # tmproot (like /var/tmp/)
    # root/nixos # runroot (like /run/)

    config.datasets."nixos" = let config = { name = "nixos"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
      mountpoint = "/"; # config.options.mountpoint
      options.acltype = "posix";
      options.canmount = "noauto";
      options.mountpoint = "/";
      options.xattr = "sa";
    };
    config.datasets."nixos/configroot" = let config = { name = "nixos/configroot"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/configroot";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };
    config.datasets."nixos/spoolroot" = let config = { name = "nixos/spoolroot"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/spoolroot";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };
    config.datasets."nixos/stateroot" = let config = { name = "nixos/stateroot"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/stateroot";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };
    config.datasets."nixos/logroot" = let config = { name = "nixos/logroot"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/logroot";
      options.atime = "off";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };
    config.datasets."nixos/cacheroot" = let config = { name = "nixos/cacheroot"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/cacheroot";
      options.atime = "on";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };
    config.datasets."nixos/tmproot" = let config = { name = "nixos/tmproot"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/tmproot";
      options.atime = "on";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };

    config.datasets."nixos/spoolroot/srv" = let config = { name = "nixos/spoolroot/srv"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/spoolroot/srv";
      options.atime = "off";
    };
    config.datasets."nixos/var" = let config = { name = "nixos/var"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/var";
      options.atime = "on";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };

    config.datasets."home" = let config = { name = "home"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
      options.acltype = "posix";
      options.atime = "on";
      options.canmount = "off";
      options.mountpoint = "/home";
      options.xattr = "sa";
    };
    config.datasets."home/bb010g" = let config = { name = "home/bb010g"; _name = "${_parent.name}/${config.name}"; }; in {
      type = "zfs_fs";
      mountpoint = "/home/bb010g";
      postCreateHook = ''${ensureSnapshotHook config._name "blank"}'';
    };
  };
}
# vim: set sta et sw=2 ts=8:
