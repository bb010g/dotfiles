{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.secrets;
in
{
  options = {
    secrets = {
      tokens = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Personal secret tokens.";
      };
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
