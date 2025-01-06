{ ... }:
{ config, lib, ... }:

let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;
  cfg = config.programs.direnv;
in
{
  options.programs.direnv = {
    gitIntegration = {
      enable = mkEnableOption "Git integration";
    };
  };
  config = mkIf cfg.enable {
    programs.git = mkIf cfg.gitIntegration.enable {
      ignores = [
        ".direnv"
      ];
    };
  };
}
