{ ... }:
{ config, lib, pkgs, ... }:

let
  cfg = config.nix;

  nixPackage = cfg.package.out;
in
{
  options = {
    nix = {
      package = lib.mkPackageOption pkgs "Nix" {
        default = [ "nix" ];
      };
    };
  };
}
