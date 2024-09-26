flakeModuleArgs@{ byName, config, getSystem, inputs, lib, options, self, ... }:
let
  inherit (builtins) attrNames concatMap listToAttrs;
  inherit (flakeLib.attrs) concatMapAttrsToList zipMapAttrsWith;
  inherit (flakeLib.lists) head length getSingletonElem;
  inherit (flakeLib.byName.supportLib.modules) importModules;
  flakeConfig = config;
  flakeLib = byName.collections.lib;
  flakeOptions = options;
  flakeSelf = self;
in
{
  imports = [
    byName.collections.flakeModules.home-manager
    byName.collections.flakeModules.nixos
  ];
  config.flake.byName = byName;
  config.flake.flakeModules = byName.collections.flakeModules or { };
  config.flake.homeConfigurations = lib.mkMerge [
    (zipMapAttrsWith (name: values: getSingletonElem values) (
      moduleName: module:
      let
        nameMatches = builtins.match "configuration-(.*)" moduleName;
        configurationName = builtins.elemAt nameMatches 0;
        configuration = inputs.home-manager.lib.homeManagerConfiguration {
          # inherit pkgs;
          modules = [ module ];
          extraSpecialArgs = { };
        };
      in
      { ${if nameMatches != null then configurationName else null} = configuration; }
    ) config.flake.homeManagerModules)
  ];
  config.flake.homeManagerModules = byName.collections.homeManagerModules or { };
  config.flake.lib = flakeLib;
  config.flake.nixosConfigurations = lib.mkMerge [
    (zipMapAttrsWith (name: values: getSingletonElem values) (
      moduleName: module:
      let
        nameMatches = builtins.match "configuration-(.*)" moduleName;
        configurationName = builtins.elemAt nameMatches 0;
        configuration = inputs.nixpkgs.lib.nixosSystem {
          modules = [ module ];
          specialArgs = { };
        };
      in
      { ${if nameMatches != null then configurationName else null} = configuration; }
    ) config.flake.nixosModules)
  ];
  config.flake.nixosModules = byName.collections.nixosModules or { };
  config.flake.overlays = byName.collections.nixpkgsOverlays or { };
  config.perSystem = { config, pkgs, system, ... }: {
    config._module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.lix-module.overlays.default
        flakeConfig.flake.overlays.neovim
        flakeConfig.flake.overlays.neovim-stable
        flakeConfig.flake.overlays.neovim-unstable
      ];
    };
    config.legacyPackages.nixpkgs = lib.dontRecurseIntoAttrs pkgs;
  };
  config.systems = import inputs.systems;
}
