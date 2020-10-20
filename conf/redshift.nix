{ config, lib, pkgs, ... }:

{
  imports = [
    ../secrets/geolocation.nix
  ];

  config = {
    services.redshift = {
      enable = true;
      tray = true;
      latitude = config.secrets.geolocation.latitude;
      longitude = config.secrets.geolocation.longitude;
      temperature = {
        day = 6500;
        night = 3700;
      };
    };
  };
}
# vim:ft=nix:et:sw=2:tw=78
