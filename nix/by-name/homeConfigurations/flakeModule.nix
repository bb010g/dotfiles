{ ... }:
{ lib, flake-parts-lib, moduleLocation, ... }:
let
  inherit (lib)
    mkOption
    types
    literalExpression
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      homeConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          Instantiated home-manager configurations. Used by `home-manager`.

          `homeConfigurations` is for specific users.
          If you want to expose reusable configurations,
          add them to [`homeManagerModules`](#opt-flake.homeManagerModules)
          in the form of modules (no `home-manager.lib.homeManagerConfiguration`),
          so that you can reference them in this or another flake's `homeConfigurations`.
        '';
        example = literalExpression ''
          {
            alice = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                ./users/alice/home.nix
                config.homeManagerModules.my-module
              ];
            };
          }
        '';
      };
    };
  };
}
