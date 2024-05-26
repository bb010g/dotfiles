moduleArgs@{ config, lib, pkgs, ... }:

let
  cfg = config.programs.firefox;
  nixosConfig = moduleArgs.nixosConfig or null;
  nixosCfg = nixosConfig.programs.firefox;
in
{
  config = lib.mkIf (nixosCfg != null) {
    programs.firefox.enable = lib.mkDefault nixosCfg.enable;
    programs.firefox.package = lib.mkDefault nixosCfg.finalPackage;
  };
}
