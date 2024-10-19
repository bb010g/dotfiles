{ ... }:
{ config, lib, nixosConfig ? null, pkgs, ... }:

let
  cfg = config.programs.firefox;
  nixosCfg = nixosConfig.programs.firefox;
in
{
  config = lib.mkIf (nixosConfig != null) {
    programs.firefox.enable = lib.mkDefault nixosCfg.enable;
    programs.firefox.package = lib.mkDefault nixosCfg.finalPackage;
  };
}
