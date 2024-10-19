{ ... }:
{ lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkPerSystemOption
    ;
in
{
  options = {
    perSystem = mkPerSystemOption {
      _file = ./flakeModule.nix;
      options = {
        pkgs = mkOption {
          description = "The system-specific pkgs.";
          readOnly = true;
          type = types.unspecified;
          internal = true;
        };
      };
    };
  };
  config = {
    perSystem = { pkgs, ... }: {
      config = {
        inherit pkgs;
      };
    };
  };
}
