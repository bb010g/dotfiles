let
  _flakeLib = import ./nix/lib/_lib.nix;
  homeManagerData = homeManagerDataForPath ./home-manager;
  homeManagerDataForPath = _flakeLib.dataOfPath.withShortNames.moduleDataForPath;
  nixosData = nixosDataForPath ./nixos;
  nixosDataForPath = _flakeLib.dataOfPath.withShortNames.moduleDataForPath;
in
flakeModuleArgs@{ config, getSystem, inputs, lib, moduleLocation, options, self, ... }:
let
  inherit (builtins)
    attrNames
    concatMap
    listToAttrs
    ;
  inherit (_flakeLib.attrs)
    concatMapAttrs'
    concatMapAttrsToList
    ;
  flakeConfig = config;
  flakeOptions = options;
  flakeSelf = self;
  homeManagerModuleLists =
    let
      f = parentName: name: value:
        let
          name' = "configuration-${name}";
        in
        [
          {
            name = name';
            value = config.flake.homeManagerModuleLists.${parentName} ++ value.moduleList or [ ];
          }
        ] ++ concatMapAttrsToList (f name') value.configs or { };
    in
    listToAttrs (concatMapAttrsToList (f "default") homeManagerData.configs);
  importModules = _file: imports:
    { ${if _file != null then "_file" else null} = _file; inherit imports; };
  nixosModuleLists =
    let
      f = parentName: name: value:
        let
          name' = "configuration-${name}";
        in
        [
          {
            name = name';
            value = config.flake.nixosModuleLists.${parentName} ++ value.moduleList or [ ];
          }
        ] ++ concatMapAttrsToList (f name') value.configs or { };
    in
    listToAttrs (concatMapAttrsToList (f "default") nixosData.configs);
in
{
  imports = [
    ./flake-parts/modules/home-manager.nix
    ./flake-parts/modules/nixos.nix
  ];
  config.flake.flakeModules = {
    home-manager = ./flake-parts/modules/home-manager.nix;
    homeConfigurations = ./flake-parts/modules/homeConfigurations.nix;
    homeManagerModules = ./flake-parts/modules/homeManagerModules.nix;
    nixos = ./flake-parts/modules/nixos.nix;
    nixosModuleLists = ./flake-parts/modules/nixosModuleLists.nix;
  };
  config.flake.homeConfigurations = lib.mkMerge [
    (concatMapAttrs'
      (moduleName: module:
        let
          nameMatches = builtins.match "configuration-(.*)" moduleName;
          configurationName = builtins.elemAt nameMatches 0;
          configuration = inputs.home-manager.lib.homeManagerConfiguration {
            # inherit pkgs;
            modules = [ config.flake.homeManagerModules.externalModules module ];
            extraSpecialArgs = {
              inherit _flakeLib flakeConfig flakeOptions flakeSelf inputs;
            };
          };
        in
        if nameMatches == null then [ ] else
          [ { name = moduleName; value = module; } ])
      config.flake.homeManagerModules)
  ];
  config.flake.homeManagerModuleLists = lib.mkMerge [
    {
      default = homeManagerData.moduleList or [ ];
      externalModules = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ];
      sharedModules = config.flake.homeManagerModuleLists.externalModules ++
        config.flake.homeManagerModuleLists.default;
    }
    homeManagerModuleLists
  ];
  config.flake.homeManagerModules = lib.mkMerge [
    (builtins.mapAttrs
      (name: importModules "${toString moduleLocation}#homeManagerModuleLists.${name}")
      config.flake.homeManagerModuleLists)
  ];
  config.flake.lib = import ./nix/lib;
  config.flake.nixosConfigurations = lib.mkMerge [
    (concatMapAttrs'
      (moduleName: module:
        let
          nameMatches = builtins.match "configuration-(.*)" moduleName;
          configurationName = builtins.elemAt nameMatches 0;
          configuration = inputs.nixpkgs.lib.nixosSystem {
            modules = [ config.flake.nixosModules.externalModules ] ++
              lib.optionals (configurationName != "nixzed") [ config.flake.nixosModules.impermanence-contrib ] ++
              [ module ];
            specialArgs = {
              inherit _flakeLib flakeConfig flakeModuleArgs flakeOptions flakeSelf inputs;
              inherit (config.flake) homeManagerModuleLists homeManagerModules;
            };
          };
        in
        if nameMatches == null then [ ] else
          [ { name = configurationName; value = configuration; } ])
      config.flake.nixosModules)
  ];
  config.flake._nixosData = nixosData;
  config.flake.nixosModuleLists = lib.mkMerge [
    {
      default = nixosData.moduleList or [ ];
      externalModules =
        config.flake.nixosModuleLists.externalModules-lix ++
        config.flake.nixosModuleLists.externalModules-main ++
        config.flake.nixosModuleLists.externalModules-home-manager;
      externalModules-home-manager = [
        inputs.home-manager.nixosModules.home-manager

        config.flake.nixosModules.home-manager-flakeIntegration
      ];
      externalModules-lix = [
        inputs.lix-module.nixosModules.default

        config.flake.nixosModules.lix-substituters
      ];
      externalModules-main = [
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
      impermanence-contrib = [
        nixos/modules/_impermanence-contrib/default.nix
      ];
      sharedModules = config.flake.nixosModuleLists.externalModules ++
        config.flake.nixosModuleLists.default;
    }
    nixosModuleLists
  ];
  config.flake.nixosModules = lib.mkMerge [
    (builtins.mapAttrs
      (name: importModules "${toString moduleLocation}#nixosModuleLists.${name}")
      config.flake.nixosModuleLists)
    {
      home-manager-flakeIntegration = nixosModuleArgs@{ config, lib, options, pkgs, ... }: {
        config.home-manager.sharedModules = flakeConfig.flake.homeManagerModuleLists.sharedModules;
        config.home-manager.extraSpecialArgs = {
          inherit _flakeLib flakeConfig flakeModuleArgs flakeOptions flakeSelf inputs nixosModuleArgs;
          # nixosConfig = config; # already passed by home-manager
          nixosLib = lib;
          nixosOptions = options;
          nixosPkgs = pkgs;
        };
      };
      lix-substituters = {
        config.nix.settings.extra-substituters = [ "https://cache.lix.systems" ];
        config.nix.settings.extra-trusted-public-keys = [ "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" ];
      };
    }
  ];
  config.systems = import inputs.systems;
}
