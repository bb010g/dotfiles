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
  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence-contrib.inputs.impermanence.follows = "impermanence";
  inputs.impermanence-contrib.inputs.nixpkgs.follows = "nixpkgs";
  inputs.impermanence-contrib.url = "github:rehno-lindeque/nixos-impermanence";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.systems.flake = false;
  inputs.systems.url = "github:nix-systems/default";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (
    let
      _moduleDataForPath = import ./nix/lib/_moduleDataForPath.nix;
      # _nixosDataForPath = _moduleDataForPath.withNixosAttrNames;
      _nixosDataForPath = _moduleDataForPath.withShortBaseNames;
      # _nixosDataForPath' = _moduleDataForPath.withNixosBaseNames;
      nixosDataForPath = _nixosDataForPath.moduleDataForPath;
      # nixosDataForPath' = _nixosDataForPath'.moduleDataForPath;
      nixosData = nixosDataForPath ./nixos;
      # safeCwd = builtins.filterSource (path: type: !(builtins.elem (builtins.baseNameOf path) [ ".git" "default.nix" "shell.nix" ])) ./.;
      # nixosData' = nixosDataForPath' safeCwd;
    in
    { config, getSystem, inputs, lib, moduleLocation, options, self, ... }:
    let
      inherit (builtins) attrNames concatMap listToAttrs;
      concatMapAttrs' = f: attrs: listToAttrs (concatMapAttrsToList f attrs);
      concatMapAttrsToList = f: attrs:
        concatMap (attrName: f attrName attrs.${attrName}) (attrNames attrs);
      flakeConfig = config;
      flakeOptions = options;
      importModules = imports: { inherit imports; };

      # nixosModuleData = builtins.
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
            ] ++ concatMapAttrsToList (f name') value.configurations or { };
        in
        listToAttrs (concatMapAttrsToList (f "default") nixosData.configurations);
    in
    {
      imports = [
        ./flake-parts/modules/nixosModuleLists.nix
      ];
      config.flake.flakeModules = {
        nixosModuleLists = ./flake-parts/modules/nixosModuleLists.nix;
      };
      config.flake.lib = import ./nix/lib;
      config.flake.nixosConfigurations = lib.mkMerge [
        (concatMapAttrs'
          (name: value:
            let
              nameMatches = builtins.match "configuration-(.*)" name;
              name' = builtins.elemAt nameMatches 0;
              value' = inputs.nixpkgs.lib.nixosSystem {
                modules = [ value ];
                specialArgs = { inherit self inputs; };
              };
            in
            if nameMatches != null then [ { name = name'; value = value'; } ] else [ ])
          config.flake.nixosModules)
      ];
      config.flake._nixosData = nixosData;
      config.flake.nixosModules = lib.mkMerge [
        {
        }
        (builtins.mapAttrs
          (name: imports: { _file = "${toString moduleLocation}#nixosModuleLists.${name}"; inherit imports; })
          config.flake.nixosModuleLists)
      ];
      config.flake.nixosModuleLists = lib.mkMerge [
        {
          default = [
            inputs.disko.nixosModules.disko
            inputs.impermanence.nixosModules.impermanence
          ] ++ nixosData.moduleList or [ ];
        }
        nixosModuleLists
      ];
      config.systems = import inputs.systems;
    }
  );
}
# vim: set sta et sw=2 ts=8:
