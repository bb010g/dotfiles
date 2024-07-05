{ config, lib, nixosConfig ? null, pkgs, ... }:

let
  cfg = config.services.kdeconnect;
  nixosCfg = nixosConfig.services.kdeconnect;
in
{
  config = lib.mkMerge [
    (lib.mkIf (nixosConfig != null) {
      services.kdeconnect.package = lib.mkIf nixosConfig.services.desktopManager.plasma6.enable (
        lib.mkDefault pkgs.kdePackages.kdeconnect-kde
      );
    })
  ];
}
