{ lib, flake-parts-lib, moduleLocation, ... }:
let
  inherit (builtins)
    toString
    ;
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      homeManagerModuleLists = mkOption {
        type = types.lazyAttrsOf (types.listOf types.unspecified);
        default = { };
        description = ''
          home-manager module lists.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
      homeManagerModules = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
        apply = mapAttrs (k: v: { _file = "${toString moduleLocation}#homeManagerModules.${k}"; imports = [ v ]; });
        description = ''
          home-manager modules.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  };
}
