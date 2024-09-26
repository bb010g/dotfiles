{ ... }:
{ config, lib, ... }:

let
  cfg = config.services.desktopManager.plasma6;
in
{
  config = lib.mkIf cfg.enable {
    # services.displayManager.sddm.enable = lib.mkDefault true;
  };
}
