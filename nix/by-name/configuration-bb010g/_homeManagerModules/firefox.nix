{ ... }:
{ config, lib, nixosConfig ? null, pkgs, ... }:

let
  cfg = config.programs.firefox;
  nixosCfg = nixosConfig.programs.firefox;
in
{
  config = lib.mkMerge [
    (lib.mkIf (nixosConfig != null) {
      programs.firefox.package = nixosCfg.finalPackage;
    })
  ];
}
