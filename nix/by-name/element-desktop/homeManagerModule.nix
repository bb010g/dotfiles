{ ... }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.element-desktop;
in
{
  options = {
    programs.element-desktop = {
      enable = lib.mkEnableOption "the Element Desktop Matrix client";
      package = lib.mkPackageOption pkgs "Element Desktop" { default = "element-desktop"; };
      desktopEntry.enableWayland = lib.mkEnableOption "using Wayland when Element Desktop is executed from its desktop entry";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = lib.mkMerge [
      [ cfg.package ]
      (lib.mkIf cfg.desktopEntry.enableWayland [
        (lib.hiPrio (pkgs.substitute {
          pname = "${cfg.package.pname}-wayland";
          version = cfg.package.version;
          src = cfg.package + "/share/applications/element-desktop.desktop";
          dir = "share/applications";
          substitutions = [
            "--replace-fail"
            "Exec=element-desktop"
            "Exec=env NIXOS_OZONE_WL=1 element-desktop"
          ];
        }))
      ])
    ];
  };
}
