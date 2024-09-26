{ ... }:
{ config, lib, options, pkgs, ... }:

let
  cfg = config.programs.vesktop;
in
{
  options = {
    programs.vesktop = {
      enable = lib.mkEnableOption "the Vesktop client for Discord";
      flatpak.enable = lib.mkEnableOption "installation via Flatpak";
      flatpak.package = lib.mkOption {
        type = options.services.flatpak.packages.type.nestedTypes.elemType;
        description = lib.mdDoc "The Vesktop Flatpak package to install";
        default = { appId = "dev.vencord.Vesktop"; };
      };
      package = lib.mkPackageOption pkgs "Vesktop" { default = "vesktop"; };
    };
  };
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (!cfg.flatpak.enable) {
      environment.systemPackages = [
        cfg.package
      ];
    })
    (lib.mkIf cfg.flatpak.enable {
      services.flatpak.packages = [
        cfg.flatpak.package
      ];
    })
  ]);
}
