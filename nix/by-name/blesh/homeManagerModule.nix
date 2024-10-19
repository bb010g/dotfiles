{ ... }:
{ lib, config, pkgs, ... }:
let
  cfg = config.programs.blesh;
in {
  options = {
    programs.blesh = {
      enable = lib.mkEnableOption "blesh, a full-featured line editor written in pure Bash";
      package = lib.mkPackageOption pkgs "blesh" { };

      enableBashIntegration = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable loading ble.sh at the beginning of `~/.bashrc` and attaching it at the end.
          No effect if <code>programs.bash.enable</code> is false.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    programs.bash.bashrcExtra = lib.mkIf cfg.enableBashIntegration (lib.mkBefore ''
      [[ $- == *i* ]] && source ${lib.escapeShellArg cfg.package}'/share/blesh/ble.sh' --attach=none
    '');

    programs.bash.initExtra = lib.mkIf cfg.enableBashIntegration (lib.mkOrder 2000 ''
      [[ ''${BLE_VERSION-} ]] && ble-attach
    '');
  };
}
