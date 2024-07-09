{ lib, ... }:

{
  # disko.devices.disk.a = {
  #   device = "/dev/sda";
  #   content.type = "gpt";
  #   content.partitions.ESP = {
  #     size = "512M";
  #     type = "EF00";
  #     priority = 100;
  #     content.type = "filesystem";
  #     content.format = "vfat";
  #     content.mountpoint = "/efi";
  #     content.mountOptions = [ "x-systemd.automount" "x-systemd.mount-timeout=1s" ];
  #   };
  #   content.partitions.XBOOTLDR = {
  #     size = "4G";
  #     type = "EA00";
  #     priority = 150;
  #     content.type = "filesystem";
  #     content.format = "vfat";
  #     content.mountpoint = "/boot";
  #     content.mountOptions = [ "x-systemd.automount" "x-systemd.mount-timeout=1s" ];
  #   };
  #   content.partitions.swap = {
  #     size = "8G";
  #     priority = 300;
  #     content.type = "swap";
  #     content.resumeDevice = true;
  #   };
  #   content.partitions.nixos = {
  #     size = "100%";
  #     type = "BF00"; # Solaris root
  #     content.type = "zfs";
  #     content.pool = "gill-tank";
  #   };
  # };
}
# vim: set sta et sw=2 ts=8:
