{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.secrets;
in
{
  options = {
    secrets = {
      # might drop this for geoclude2, b/c this is just consumed by redshift rn
      geolocation = {
        latitude = mkOption {
          type = types.str;
          description = "Your current latitude, between -90.0 and 90.0";
        };
        longitude = mkOption {
          type = types.str;
          description = "Your current longitude, between -180.0 and 180.0";
        };
      };

      tokens = mkOption {
        type = types.attrsOf types.str;
        default = { };
        description = "Personal secret tokens.";
      };
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
