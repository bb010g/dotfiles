# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: ⓒ 2003-2024 Eelco Dolstra and the Nixpkgs/NixOS contributors

# This file turns the by-name directory into imports of all its Nix files.
# No validity checks are done here,
# instead this file is optimised for performance,
# and validity checks are done by CI on PRs.

# Type: Overlay

prevLib: finalLib:
let
  inherit (finalLib) builtins;
  inherit (finalLib.attrs) filterAttrs mapAttrs removeAttrs;
  inherit (finalLib.bools) false true;
  inherit (finalLib.byName)
    importNameDirEntries
    importNameDirEntry
    importNamedDirEntries
    isIgnoredDirEntry
    supportLib
    supportLibProto
    ;
  inherit (finalLib.derivations)
    derivation
    derivationStrict
    fetchGit
    fetchMercurial
    fetchTarball
    fetchTree
    placeholder
    ;
  inherit (finalLib.evaluation) abort break throw;
  inherit (finalLib.filesystem) import readDirEntries scopedImport;
  inherit (finalLib.lists) map;
  inherit (finalLib.nulls)
    filterNullable
    ifNull
    isNull
    mapNullable
    null
    visitNullable
    ;
  inherit (finalLib.protos) composeProtos identityProto instantiateProto;
  inherit (finalLib.strings) baseNameOf dirOf hasPrefix;
  inherit (finalLib.values) fromTOML toString;

  currentLib = prevLib // {
    byName = prevByName // lib.byName;
  };

  lib.byName.instantiateConfigurationProto =
    configurationProto:
    instantiateProto (
      prevByName: finalByName:
      let
        inherit (finalByName)
          collections
          configuration
          entriesByName
          lib
          metadata
          nameDirEntriesByName
          ;
        inherit (lib.attrs)
          attrNames
          concatMapAttrsToList
          mapAttrs
          mapAttrsToList
          zipAttrsWith
          zipMapAttrsWith
          ;
        inherit (lib.evaluation) throw;
        inherit (lib.lists)
          concatMap
          filter
          map
          head
          length
          ;
        inherit (lib.filesystem) import pathExists;
        inherit (lib.functions) identity;
        inherit (lib.nulls)
          filterNullable
          ifNull
          isNull
          mapNullable
          null
          visitNullable
          ;
        inherit (lib.protos) instantiateProto;
        inherit (lib.strings) concatStringsSep escapeNixIdentifier;
        inherit (lib.values) toJson;
        baseNameConfigurationMetadata = metadata.baseNameConfigurations;
        collectionConfigurations = configuration.collections or { };
        entryConfigurationMetadata = metadata.entryConfigurations;
        getSingleton =
          list:
          assert length list == 1;
          head list;
      in
      prevByName
      // {
        collections =
          zipAttrsWith (collectionName: values: zipAttrsWith (name: values: getSingleton values) values)
            (
              concatMapAttrsToList (
                name: entries:
                mapAttrsToList (entryName: entry: {
                  ${entryConfigurationMetadata.${entryName}.collectionName}.${name} = entry;
                }) entries
              ) entriesByName
            );
        configuration =
          let
            configurationBase = { };
            defaultedConfiguration = instantiateProto defaultedConfigurationProto configurationBase;
            defaultedConfigurationProto = composeProtos (configurationProto { inherit lib; }) (
              prevConfiguration: finalConfiguration:
              prevConfiguration
              // {
                collections = {
                  byNameConfigurations.entries.byNameConfiguration.suffixes.".nix".import =
                    byName@{ lib, ... }: named@{ ... }: { path, ... }: import path byName named;
                };
                configurationPath = mapNullable (path: path + "/by-name.nix") finalConfiguration.path;
                outputs = byName@{ ... }: byName;
                path = null;
              }
            );
          in
          visitNullable defaultedConfiguration (
            configurationPath:
            instantiateProto (composeProtos (import configurationPath {
              inherit lib;
            }) defaultedConfigurationProto) configurationBase
          ) (mapNullable (filterNullable pathExists) defaultedConfiguration.configurationPath);
        lib = supportLib;
        nameDirEntriesByName = configuration.readNameDirEntries configuration.path;
        # TODO: one collection name maps to many entry names, and a name must have at most one entry per collection
        entriesByName =
          let
            prevEntriesByName =
              zipAttrsWith (name: entries: zipAttrsWith (name: entries: getSingleton entries) entries)
                (
                  concatMapAttrsToList (
                    entryName:
                    { entryConfiguration, ... }:
                    mapAttrsToList (name: entry: { ${name}.${entryName} = entry; }) entryConfiguration.values or { }
                  ) entryConfigurationMetadata
                );
            nameDirEntryToEntry =
              name: nameDirEntry:
              let
                byNameConfiguration = entries.byNameConfiguration or { };
                byNameCollectionsConfiguration = byNameConfiguration.collections or { };
                dirEntries = readDirEntries nameDirEntry.path;
                dirEntryNames = filter (baseName: !(isIgnoredDirEntry baseName dirEntries.${baseName})) (
                  attrNames dirEntries
                );
                entries = zipAttrsWith (entryName: entries: getSingleton entries) (
                  map (
                    baseName:
                    let
                      inherit (baseNameConfigurationMetadatum)
                        collectionName
                        entryName
                        suffix
                        suffixConfiguration
                        ;
                      baseNameConfigurationMetadatum =
                        baseNameConfigurationMetadata.${baseName}
                          or (throw "Unknown by-name entry base name: ${toJson baseName}");
                      byNameCollectionConfiguration = byNameCollectionsConfiguration.${collectionName} or { };
                      byNameEntryConfiguration = (byNameCollectionConfiguration.entries or { }).${entryName} or { };
                      byNameSuffixConfiguration = (byNameEntryConfiguration.suffixes or { }).${suffix} or { };
                      dirEntry = dirEntries.${baseName};
                      importDirEntry =
                        if entryName != "byNameConfiguration" && byNameSuffixConfiguration ? import then
                          byNameSuffixConfiguration.import
                        else
                          suffixConfiguration.import;
                    in
                    if prevEntries ? ${entryName} then
                      throw "by-name entry value `entriesByName.${escapeNixIdentifier name}.${escapeNixIdentifier entryName}` is declared through both configuration for collection `${escapeNixIdentifier collectionName}` and a file ${toJson baseName}"
                    else
                      {
                        ${entryName} = importDirEntry finalByName {
                          inherit
                            byNameConfiguration
                            byNameCollectionConfiguration
                            byNameEntryConfiguration
                            byNameSuffixConfiguration
                            collectionName
                            entries
                            entryName
                            name
                            suffix
                            ;
                        } dirEntry;
                      }
                  ) dirEntryNames
                );
                prevEntries = prevEntriesByName.${name} or { };
              in
              if prevEntries != { } then prevEntries // entries else entries;
          in
          prevEntriesByName // mapAttrs nameDirEntryToEntry nameDirEntriesByName;
        metadata.baseNameConfigurations =
          zipAttrsWith
            (
              fileName: baseNameConfigurationMetadata:
              if length baseNameConfigurationMetadata > 1 then
                throw "by-name base name ${toJson fileName} maps to multiple collection entries instead of at most one collection entry: ${
                  concatStringsSep ", " (
                    map (
                      {
                        collectionName,
                        entryName,
                        suffix,
                        ...
                      }:
                      "`collections.${escapeNixIdentifier collectionName}.entries.${escapeNixIdentifier entryName}.suffixes.${escapeNixIdentifier suffix}`"
                    ) baseNameConfigurationMetadata
                  )
                }"
              else
                head baseNameConfigurationMetadata
            )
            (
              concatMapAttrsToList (
                entryName: entryConfigurationMetadata:
                mapAttrsToList (suffix: suffixConfiguration: {
                  "${entryName}${suffix}" = entryConfigurationMetadata // {
                    inherit entryName suffix suffixConfiguration;
                  };
                }) entryConfigurationMetadata.entryConfiguration.suffixes or { }
              ) entryConfigurationMetadata
            );
        metadata.entryConfigurations =
          zipAttrsWith
            (
              entryName: entryConfigurationMetadata:
              if length entryConfigurationMetadata > 1 then
                throw "by-name entry `${escapeNixIdentifier entryName}` maps to multiple collections instead of at most one collection: ${
                  concatStringsSep ", " (
                    map (
                      { collectionName, ... }:
                      "`collections.${escapeNixIdentifier collectionName}.entries.${escapeNixIdentifier entryName}`"
                    ) entryConfigurationMetadata
                  )
                }"
              else
                head entryConfigurationMetadata
            )
            (
              concatMapAttrsToList (
                collectionName: collectionConfiguration:
                mapAttrsToList (entryName: entryConfiguration: {
                  ${entryName} = {
                    inherit collectionConfiguration collectionName entryConfiguration;
                  };
                }) collectionConfiguration.entries or { }
              ) collectionConfigurations
            );
        outputs = configuration.outputs finalByName;
      }
    ) { };

  lib.byName.importNamedDirEntries =
    config: name: nameDirEntry: namedDirEntries:
    config.importNamedDirEntries config name nameDirEntry (
      filterAttrs (
        namedBaseName: namedDirEntry: !(isIgnoredDirEntry namedBaseName namedDirEntry)
      ) namedDirEntries
    );

  lib.byName.importNameDirEntry =
    config: name: nameDirEntry:
    importNamedDirEntries config name nameDirEntry (readDirEntries nameDirEntry.path);

  lib.byName.importNameDirEntries =
    config: nameDirEntries:
    mapAttrs (name: nameDirEntry: importNameDirEntry config name nameDirEntry) nameDirEntries;

  lib.byName.isIgnoredDirEntry =
    let
      isIgnoredBaseName = hasPrefix "_";
      lib.byName.isIgnoredDirEntry = baseName: dirEntry: isIgnoredBaseName baseName;
    in
    lib.byName.isIgnoredDirEntry;

  lib.byName.supportLib = supportLibProto currentLib finalLib;

  lib.byName.supportLibProto = prevByName.supportLibProto or (import ./_supportLib.nix);

  prevByName = prevLib.byName or { };
in
currentLib
