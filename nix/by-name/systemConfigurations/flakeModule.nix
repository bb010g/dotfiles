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
      systemConfigs = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          Instantiated system-manager configurations. Used by `system-manager`.

          `systemConfigs` is for specific systems.
          If you want to expose reusable configurations,
          add them to [`systemManagerModules`](#opt-flake.systemManagerModules)
          in the form of modules (no `system-manager.lib.makeSystemConfig`),
          so that you can reference them in this or another flake's `systemConfigs`.
        '';
        example = literalExpression ''
          {
            alice = inputs.system-manager.lib.makeSystemConfig {
              modules = [
                ./systems/alice/configuration.nix
                config.systemManagerModules.my-module
              ];
            };
          }
        '';
      };
    };
  };
}
