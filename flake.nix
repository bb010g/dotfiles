{
  description = "woah NixOS configuration";

  nixConfig.extra-substituters = "https://cache.lix.systems https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

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
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.plasma-manager.inputs.home-manager.follows = "home-manager";
  inputs.plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.plasma-manager.url = "github:pjones/plasma-manager";
  inputs.pre-commit-hooks-nix.inputs.flake-compat.follows = "flake-compat";
  inputs.pre-commit-hooks-nix.inputs.gitignore.follows = "gitignore";
  inputs.pre-commit-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  inputs.systems.flake = false;
  inputs.systems.url = "github:nix-systems/default";

  outputs =
    inputs:
    let
      inherit (byName)
        byNameLib
        config
        lib
        nameDirEntries
        nameEntries
        transposedNameEntries
        ;
      inherit (byNameLib) importNameDirEntries;
      inherit (lib)
        concatMapAttrs'
        import
        importModules
        mapAttr
        pipe
        readDirEntries
        removeAttr
        transposeAttrs
        ;
      byName = builtins.import ./nix/by-name/byName/lib.nix { } { inherit byName; } // {
        config.importNamedDirEntries =
          let
            importNamedDirEntries =
              config: name: nameEntry: namedDirEntries:
              let
                final = pipe {
                  inherit namedDirEntries;
                  namedEntries = { };
                } config.namedDirEntriesImporters;
              in
              assert final.namedDirEntries == { };
              final.namedEntries;
          in
          importNamedDirEntries;
        config.namedDirEntriesImporters =
          let
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
          in
          [
            (mapNamedDirEntry "flakeModule.nix" (
              { path, ... }:
              mapAttr "namedEntries" (
                namedEntries: namedEntries // { flakeModule = importModules path [ (import' path) ]; }
              )
            ))
            (mapNamedDirEntry "lib.nix" (
              { path, ... }:
              mapAttr "namedEntries" (
                namedEntries: namedEntries // { lib = import path { inherit byName; } lib'; }
              )
            ))
            (mapNamedDirEntry "nixpkgsOverlay.nix" (
              { path, ... }:
              mapAttr "namedEntries" (namedEntries: namedEntries // { nixpkgsOverlay = import' path; })
            ))
          ];
        # by-name/<name>/package.nix -> packagesByName.<name>
        # by-name/<name>/<resource>.nix -> <resource>sByName.<name>
        # by-name/<name>/<resource>.nix -> resourcesByName.<name>.<resource>
        # by-name/<name>/<resource-name>.nix -> byResourceNameByName.<name>.<resource-name>
        # by-name/<name>/<resource-name>.nix -> byNameByResourceName.<resource-name>s.<name>
        # by-name/<name>/package.nix -> byNameByResourceName.packages.<name>

        # by-name/<name>/<named>.nix -> namedByName.<name>.<named>
        # by-name/<name>/<named>.nix -> nameByNamed.<named>s.<name>
        # by-name/<name>/package.nix -> nameByNamed.packages.<name>

        # by-name/<name>/<type>.nix -> typedByName.<name>.<type>
        # by-name/<name>/<type>.nix -> namedByType.<type>s.<name>
        # by-name/<name>/package.nix -> namedByType.packages.<name>

        # by-name/<name>/* -> dirEntriesByName.<name>
        # by-name/<name>/<type>.nix ->

        # by-name/<name>/package.nix -> by-name.named.packages.<name>
        # by-name/<name>/package.nix -> by-name.names.<name>.package

        # Maybe the non-transposed structure shouldn't be returned at all.

        # by-name/<name>/<resource>.nix -> namedResources.<name>.<resource>
        # by-name/hello/package.nix -> valueByTypeNameByName.hello.package
        # helloTypedValues = valueByTypeByName.hello
        # by-name/hello/package.nix -> valueByNameByType.package.hello
        # packageDataByName = valueByNameByType.package
        # by-name/hello/package.nix -> namedDataByType.package.hello
        # namedPackageData = namedDataByType.package
        config.transposedNameEntryNames = {
          flakeModule = "flakeModules";
          nixpkgsOverlay = "nixpkgsOverlays";
        };
        nameDirEntries = readDirEntries ./nix/by-name;
        nameEntries = importNameDirEntries config nameDirEntries;
        transposedNameEntries =
          let
            namesCfg = config.transposedNameEntryNames or { };
          in
          concatMapAttrs' (name: value: [
            {
              inherit value;
              name = namesCfg.${name} or name;
            }
          ]) (transposeAttrs nameEntries);
      };
      import' = path: import path transposedNameEntries';
      specialArgs.byName = byName;
      specialArgs' = {
        inherit inputs;
      } // specialArgs;
      transposedNameEntries' = specialArgs' // transposedNameEntries;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs specialArgs; } ./flake-module.nix;
}
# vim: set sta et sw=2 ts=8:
