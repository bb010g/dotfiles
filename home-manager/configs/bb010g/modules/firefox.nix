moduleArgs@{ config, lib, pkgs, ... }:

let
  cfg = config.programs.firefox;
  nixosConfig = moduleArgs.nixosConfig or null;
  nixosCfg = nixosConfig.programs.firefox;
in
{
  config = lib.mkMerge [
    (lib.mkIf (nixosCfg != null) {
      programs.firefox.package = nixosCfg.package;
    })
    {
    }
  ];
}
