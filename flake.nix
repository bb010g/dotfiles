{
  description = "woah NixOS configuration";

  nixConfig.extra-substituters = "https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flakey-profile.url = "github:lf-/flakey-profile";
  inputs.gitignore.inputs.nixpkgs.follows = "nixpkgs";
  inputs.gitignore.url = "github:hercules-ci/gitignore.nix";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.url = "github:bb010g/nix-impermanence/f/method";
  inputs.impermanence-contrib.inputs.impermanence.follows = "impermanence";
  inputs.impermanence-contrib.inputs.nixpkgs.follows = "nixpkgs";
  inputs.impermanence-contrib.url = "github:rehno-lindeque/nixos-impermanence";
  inputs.lix-module.inputs.flake-utils.follows = "flake-utils";
  inputs.lix-module.inputs.flakey-profile.follows = "flakey-profile";
  inputs.lix-module.inputs.lix.follows = "lix";
  inputs.lix-module.inputs.nixpkgs.follows = "nixpkgs";
  inputs.lix-module.url = "git+https://git.lix.systems/lix-project/nixos-module.git";
  inputs.lix.flake = false;
  inputs.lix.url = "git+https://git.lix.systems/lix-project/lix.git";
  inputs.neovim.flake = false;
  inputs.neovim.url = "github:neovim/neovim";
  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs.url = "github:bb010g/nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
                modules = [ config.flake.nixosModules.externalModules module ];
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
          ];
          externalModules-main = [
            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModules.impermanence
            inputs.nix-flatpak.nixosModules.nix-flatpak
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
        }
      ];
      config.systems = import inputs.systems;
    }
  );
}
# vim: set sta et sw=2 ts=8:
