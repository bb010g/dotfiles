moduleArgs@{ config, lib, pkgs, ... }:

let
  cfg = config.programs.firefox;
  nixosConfig = moduleArgs.nixosConfig or null;
in
{
  config = lib.mkIf (nixosConfig != null) {
    services.kdeconnect.package = lib.mkIf nixosConfig.services.desktopManager.plasma6.enable (
      lib.mkDefault pkgs.kdePackages.kdeconnect-kde
    );
  };
}
