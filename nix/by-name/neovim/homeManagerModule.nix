{ ... }:
{ config, lib, ... }:
let
  inherit (lib.types) types;
  inherit (lib.modules) mkBefore mkIf;
  inherit (lib.options) mkOption;
  cfg = config.programs.neovim;
in
{
  options.programs.neovim.extraLuaConfigFirst = mkOption {
    type = types.lines;
    default = "";
    description = "Custom Lua lines, placed before any other generated configuration.";
  };
  config = mkIf cfg.enable {
    xdg.configFile."nvim/init.lua" = mkIf (cfg.extraLuaConfigFirst != "") {
      text = mkBefore cfg.extraLuaConfigFirst;
    };
  };
}
