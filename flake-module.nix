flakeModuleArgs@{ config, getSystem, inputs, lib, moduleLocation, options, self, ... }:
let
  inherit (builtins) attrNames concatMap listToAttrs;
  inherit (flakeLib.attrs) concatMapAttrs' concatMapAttrsToList;
  byName = import nix/by-name/byName/lib.nix { } { inherit byName; } // {
    config.importNamedDirEntries =
      let
        inherit (byName) byNameLib lib;
        inherit (lib) pipe;
        importNamedDirEntries =
          config: name: nameEntry: namedDirEntries:
          let
            final = pipe { inherit namedDirEntries; namedEntries = { }; }
              config.namedDirEntriesImporters;
          in
          assert final.namedDirEntries == { };
          final.namedEntries;
      in
      importNamedDirEntries;
    config.namedDirEntriesImporters =
      let
        inherit (byName) byNameLib lib;
        inherit (lib) import mapAttr removeAttr;
        lib' = transposedNameEntries'.lib;
        mapNamedDirEntry =
          namedBaseName: f: acc:
          let
            inherit (acc) namedDirEntries;
            namedDirEntry = namedDirEntries.${namedBaseName};
            namedDirEntries' = removeAttr namedBaseName namedDirEntries;
            acc' = acc // {
              namedDirEntries = namedDirEntries';
            };
          in
          if namedDirEntries ? ${namedBaseName} then f namedDirEntry acc' else acc;
        transposedNameEntries' = byName.transposedNameEntries // { inherit inputs; };
      in
      [
        (mapNamedDirEntry "flake-module.nix" ({ path, ... }: mapAttr "namedEntries" (namedEntries: namedEntries // {
          flakeModule = importModules path [ (import path transposedNameEntries') ];
        })))
        (mapNamedDirEntry "lib.nix" ({ path, ... }: mapAttr "namedEntries" (namedEntries: namedEntries // {
          lib = import path { inherit byName; } lib';
        })))
        (mapNamedDirEntry "nixpkgs-overlay.nix" ({ path, ... }: mapAttr "namedEntries" (namedEntries: namedEntries // {
          nixpkgsOverlay = import path transposedNameEntries';
        })))
      ];
    config.transposedNameEntryNames = {
      flakeModule = "flakeModules";
      nixpkgsOverlay = "nixpkgsOverlays";
    };
    nameDirEntries = byName.lib.readDirEntries ./nix/by-name;
    nameEntries = byName.byNameLib.importNameDirEntries byName.config byName.nameDirEntries;
    transposedNameEntries =
      let
        namesCfg = byName.config.transposedNameEntryNames or { };
      in
      byName.lib.concatMapAttrs'
        (name: value: [ { inherit value; name = namesCfg.${name} or name; } ])
        (byName.lib.transposeAttrs byName.nameEntries);
  };
  flakeConfig = config;
  flakeLib = byName.transposedNameEntries.lib or { };
  flakeOptions = options;
  flakeSelf = self;
  homeManagerData = homeManagerDataForPath ./home-manager;
  homeManagerDataForPath = flakeLib.dataOfPath.withShortNames.moduleDataForPath;
  homeManagerModuleLists =
    let
      f =
        parentName: name: value:
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
  nixosData = nixosDataForPath ./nixos;
  nixosDataForPath = flakeLib.dataOfPath.withShortNames.moduleDataForPath;
  nixosModuleLists =
    let
      f =
        parentName: name: value:
        let
          name' = "configuration-${name}";
        in
        [
          {
            name = name';
            value = config.flake.nixosModuleLists.${parentName} ++ value.moduleList or [ ];
          }
        ]
        ++ concatMapAttrsToList (f name') value.configs or { };
    in
    listToAttrs (concatMapAttrsToList (f "default") nixosData.configs);
in
{
  imports = [
    byName.transposedNameEntries.flakeModules.home-manager
    byName.transposedNameEntries.flakeModules.nixos
  ];
  config.flake.byName = byName;
  config.flake.flakeModules = byName.transposedNameEntries.flakeModules or { };
  config.flake.homeConfigurations = lib.mkMerge [
    (concatMapAttrs' (
      moduleName: module:
      let
        nameMatches = builtins.match "configuration-(.*)" moduleName;
        configurationName = builtins.elemAt nameMatches 0;
        configuration = inputs.home-manager.lib.homeManagerConfiguration {
          # inherit pkgs;
          modules = [ config.flake.homeManagerModules.externalModules module ];
          extraSpecialArgs = {
            inherit flakeLib flakeConfig flakeOptions flakeSelf inputs;
          };
        };
      in
      if nameMatches == null then [ ] else [ { name = moduleName; value = module; } ]
    ) config.flake.homeManagerModules)
  ];
  config.flake.homeManagerModuleLists = lib.mkMerge [
    {
      default = homeManagerData.moduleList or [ ];
      externalModules = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ];
      sharedModules =
        config.flake.homeManagerModuleLists.externalModules
        ++ config.flake.homeManagerModuleLists.default;
    }
    homeManagerModuleLists
  ];
  config.flake.homeManagerModules = lib.mkMerge [
    (builtins.mapAttrs (
      name: importModules "${toString moduleLocation}#homeManagerModuleLists.${name}"
    ) config.flake.homeManagerModuleLists)
  ];
  config.flake.lib = flakeLib;
  config.flake.nixosConfigurations = lib.mkMerge [
    (concatMapAttrs' (
      moduleName: module:
      let
        nameMatches = builtins.match "configuration-(.*)" moduleName;
        configurationName = builtins.elemAt nameMatches 0;
        configuration = inputs.nixpkgs.lib.nixosSystem {
          modules =
            [ config.flake.nixosModules.externalModules ]
            ++ lib.optionals (configurationName != "nixzed") [ config.flake.nixosModules.impermanence-contrib ]
            ++ [ module ];
          specialArgs = {
            inherit flakeLib flakeConfig flakeModuleArgs flakeOptions flakeSelf inputs;
            inherit (config.flake) homeManagerModuleLists homeManagerModules;
          };
        };
      in
      if nameMatches == null then [ ] else [ { name = configurationName; value = configuration; } ]
    ) config.flake.nixosModules)
  ];
  config.flake._nixosData = nixosData;
  config.flake.nixosModuleLists = lib.mkMerge [
    {
      default = nixosData.moduleList or [ ];
      externalModules =
        config.flake.nixosModuleLists.externalModules-lix
        ++ config.flake.nixosModuleLists.externalModules-main
        ++ config.flake.nixosModuleLists.externalModules-home-manager;
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
        # ({ config, ... }: { config.assertions = [ { assertion = config.nixpkgs.overlays == [ ]; message = "Overlays were provided to Nixpkgs: ${lib.generators.toPretty { allowPrettyValues = true; } config.nixpkgs.overlays}"; } ]; })
      ];
      impermanence-contrib = [ nixos/modules/_impermanence-contrib/default.nix ];
      sharedModules =
        config.flake.nixosModuleLists.externalModules
        ++ config.flake.nixosModuleLists.default;
    }
    nixosModuleLists
  ];
  config.flake.nixosModules = lib.mkMerge [
    (builtins.mapAttrs (
      name: importModules "${toString moduleLocation}#nixosModuleLists.${name}"
    ) config.flake.nixosModuleLists)
    {
      home-manager-flakeIntegration = nixosModuleArgs@{ config, lib, options, pkgs, ... }: {
        config.home-manager.sharedModules = flakeConfig.flake.homeManagerModuleLists.sharedModules;
        config.home-manager.extraSpecialArgs = {
          inherit flakeLib flakeConfig flakeModuleArgs flakeOptions flakeSelf inputs nixosModuleArgs;
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
  config.flake.overlays = byName.transposedNameEntries.nixpkgsOverlays or { };
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
