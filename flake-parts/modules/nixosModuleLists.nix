{ self, lib, flake-parts-lib, ... }:
let
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
      nixosModuleLists = mkOption {
        type = types.lazyAttrsOf (types.listOf types.unspecified);
        default = { };
        description = ''
          NixOS module lists.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  };
}
