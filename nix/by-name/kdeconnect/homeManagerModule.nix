{ ... }:
{ config, lib, nixosConfig ? null, pkgs, ... }:

let
  cfg = config.services.kdeconnect;
  nixosCfg = nixosConfig.programs.kdeconnect;
in
{
  config = lib.mkMerge [
    (lib.mkIf (nixosConfig != null) {
      services.kdeconnect.enable = lib.mkIf nixosCfg.enable false;
      services.kdeconnect.package = nixosCfg.package;
    })
  ];
}
