{ ... }:
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
  inherit (lib.modules)
    setDefaultModuleLocation
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      homeManagerModules = mkOption {
        type = types.lazyAttrsOf types.unspecified;
        default = { };
        apply = mapAttrs (k: v: setDefaultModuleLocation "${toString moduleLocation}#homeManagerModules.${k}" v);
        description = ''
          home-manager modules.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  };
}
