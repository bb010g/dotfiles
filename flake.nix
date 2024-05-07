{
  description = "woah NixOS configuration";

  nixConfig.extra-substituters = "https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.url = "github:bb010g/nix-impermanence/f/method";
  inputs.impermanence-contrib.inputs.impermanence.follows = "impermanence";
  inputs.impermanence-contrib.inputs.nixpkgs.follows = "nixpkgs";
  inputs.impermanence-contrib.url = "github:rehno-lindeque/nixos-impermanence";
  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.plasma-manager.inputs.home-manager.follows = "home-manager";
  inputs.plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.plasma-manager.url = "github:pjones/plasma-manager";
  inputs.systems.flake = false;
  inputs.systems.url = "github:nix-systems/default";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (
    let
      _flakeLib = import ./nix/lib/_lib.nix;
      homeManagerData = homeManagerDataForPath ./home-manager;
      homeManagerDataForPath = _flakeLib.dataOfPath.withShortNames.moduleDataForPath;
      nixosData = nixosDataForPath ./nixos;
      nixosDataForPath = _flakeLib.dataOfPath.withShortNames.moduleDataForPath;
    in
    { config, getSystem, inputs, lib, moduleLocation, options, self, ... }:
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
      flakeInputs = inputs;
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
                extraSpecialArgs = { inherit _flakeLib flakeConfig flakeOptions flakeInputs flakeSelf; };
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
                modules = [ config.flake.nixosModules.externalModules module ];
                specialArgs = {
                  inherit _flakeLib flakeConfig flakeInputs flakeOptions flakeSelf;
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
          externalModules = [
            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModules.impermanence
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.home-manager.nixosModules.home-manager
            {
              config.home-manager.sharedModules = config.flake.homeManagerModuleLists.sharedModules;
              config.home-manager.extraSpecialArgs =
                { inherit _flakeLib flakeConfig flakeOptions flakeInputs flakeSelf; };
            }
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
      ];
      config.systems = import inputs.systems;
    }
  );
}
# vim: set sta et sw=2 ts=8:
