# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: ⓒ 2003-2024 Eelco Dolstra and the Nixpkgs/NixOS contributors

# This file turns the by-name directory into imports of all its Nix files.
# No validity checks are done here,
# instead this file is optimised for performance,
# and validity checks are done by CI on PRs.

# Type: Overlay

prevLib: finalLib:
let
  inherit (finalLib.byName) supportLib supportLibProto;
  inherit (finalLib.filesystem) import;
  inherit (finalLib.protos) instantiateProto;
  inherit (finalLib.strings) hasPrefix;

  currentLib = prevLib // {
    byName = prevByName // lib.byName;
  };

  lib.byName.instantiateConfigurationProto =
    configurationProto:
    instantiateProto (
      prevByName: finalByName:
      let
        inherit (finalByName)
          collectionNameByEntryName
          collections
          collectionsFromEntriesByNamePath
          collectionsFromConfiguration
          configuration
          entriesDirEntryByName
          entriesByName
          entriesByNameFromEntriesByNamePath
          entriesByNameFromConfiguration
          entryNameByEntryBaseName
          lib
          ;
        inherit (lib) builtins;
        inherit (lib.attrs)
          attrNames
          concatMapAttrsToList
          filterAttrs
          listToAttrs
          mapAttrs
          mapAttrsToList
          wrapAttrPosString
          zipAttrsWith
          zipConcatMapAttrsWith
          zipMapAttrsWith
          ;
        inherit (lib.byName) isIgnoredEntryDirEntry;
        inherit (lib.evaluation) addErrorContext throw;
        inherit (lib.lists)
          concatMap
          filter
          getSingletonElem
          head
          length
          map
          visitSingleton
          ;
        inherit (lib.filesystem)
          import
          pathExists
          readDir
          readDirEntries
          ;
        inherit (lib.functions) identity const;
        inherit (lib.nulls)
          filterNullable
          ifNull
          isNull
          mapNullable
          null
          visitNullable
          ;
        inherit (lib.protos) composeProtos instantiateProto;
        inherit (lib.strings)
          addPrefix
          baseNameOf
          concatStringsSep
          dirOf
          escapeNixIdentifier
          ;
        inherit (lib.values) toString;
        byNameConfigurations = collections.byNameConfigurations or { };
        collectionConfigurations = configuration.collections or { };
      in
      prevByName
      // {
        entryNameByEntryBaseName =
          zipConcatMapAttrsWith
            (
              entryBaseName: entryNames:
              visitSingleton (
                entryNames:
                throw "lib.byName: entry base name ${escapeNixIdentifier entryBaseName} defined by more than one collection:\n${
                  concatStringsSep "\n" (
                    map (
                      entryName:
                      let
                        collectionName = collectionNameByEntryName.${entryName};
                      in
                      "- `collections.${escapeNixIdentifier collectionName}`${
                        wrapAttrPosString " at " "" entryBaseName collectionConfigurations.${collectionName}.entryBaseNames
                      }"
                    ) entryNames
                  )
                }"
              ) identity entryNames
            )
            (
              collectionName: collectionConfiguration:
              mapAttrsToList (entryBaseName: entryBaseNameConfiguration: {
                ${entryBaseName} =
                  collectionConfiguration.entryName
                    or (throw "lib.byName: entry name for collection `${escapeNixIdentifier collectionName}` is not configured");
              }) collectionConfiguration.entryBaseNames or { }
            )
            collectionConfigurations;
        collectionNameByEntryName =
          zipMapAttrsWith
            (
              entryName: collectionNames:
              visitSingleton (
                collectionNames:
                throw "lib.byName: entry `${escapeNixIdentifier entryName}` defined by more than one collection:\n${
                  concatStringsSep "\n" (
                    map (
                      collectionName:
                      "- `collections.${escapeNixIdentifier collectionName}`${
                        wrapAttrPosString " at " "" "entryName" collectionConfigurations.${collectionName}
                      }"
                    ) collectionNames
                  )
                }"
              ) identity collectionNames
            )
            (collectionName: collectionConfiguration: {
              ${
                collectionConfiguration.entryName
                  or (throw "lib.byName: entry name for collection `${escapeNixIdentifier collectionName}` is not configured")
              } = collectionName;
            })
            collectionConfigurations;
        collections =
          collectionsFromConfiguration
          // mapAttrs (
            collectionName: entryByName: collectionsFromConfiguration.${collectionName} or { } // entryByName
          ) collectionsFromEntriesByNamePath;
        collectionsFromConfiguration =
          filterAttrs (collectionName: entryByName: collectionConfigurations.${collectionName} ? entryByName)
            (
              mapAttrs (
                collectionName: collectionConfiguration:
                collectionConfiguration.entryByName finalByName {
                  inherit byNameConfigurations collectionConfiguration collectionName;
                  inherit (collectionConfiguration) entryName;
                }
              ) collectionConfigurations
            );
        collectionsFromEntriesByNamePath =
          zipAttrsWith (collectionName: values: zipAttrsWith (name: values: getSingletonElem values) values)
            (
              concatMapAttrsToList (
                name: entries:
                mapAttrsToList (entryName: entry: {
                  ${collectionNameByEntryName.${entryName}}.${name} = entry;
                }) entries
              ) entriesByNameFromEntriesByNamePath
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
                  byNameConfigurations.entryBaseNames."byNameConfiguration.nix".import =
                    byName@{ lib, ... }: named@{ ... }: { path, ... }: import path byName named;
                  byNameConfigurations.entryName = "byNameConfiguration";
                };
                entriesByNameConfigurationPath = mapNullable (
                  entriesByNamePath: entriesByNamePath + "/by-name.nix"
                ) finalConfiguration.entriesByNamePath;
                entriesByNamePath = null;
                outputs = byName@{ ... }: byName;
                readEntriesDirEntryByName =
                  entriesByNamePath:
                  let
                    entriesShardsPath = entriesByNamePath;
                  in
                  zipMapAttrsWith
                    (
                      name: entriesDirEntries:
                      visitSingleton (
                        entriesDirEntries:
                        throw "lib.byName: name `${escapeNixIdentifier name}` defined by more than one entries by-name shard:\n${
                          concatStringsSep "\n" (
                            map (
                              entriesDirEntry: "- ${escapeNixIdentifier (baseNameOf (dirOf (toString entriesDirEntry.path)))}"
                            ) entriesDirEntries
                          )
                        }"
                      ) identity entriesDirEntries
                    )
                    (
                      entriesShardName: entriesShardType:
                      if entriesShardType == "directory" then
                        readDirEntries (entriesShardsPath + "/${entriesShardName}")
                      else
                        { }
                    )
                    (readDir entriesShardsPath);
              }
            );
          in
          visitNullable defaultedConfiguration (
            entriesByNameConfigurationPath:
            instantiateProto (composeProtos (import entriesByNameConfigurationPath {
              inherit lib;
            }) defaultedConfigurationProto) configurationBase
          ) (mapNullable (filterNullable pathExists) defaultedConfiguration.entriesByNameConfigurationPath);
        entriesByName =
          entriesByNameFromConfiguration
          // mapAttrs (
            name: entries:
            let
              entriesFromConfiguration = entriesByNameFromConfiguration.${name} or { };
            in
            if entriesFromConfiguration != { } then entriesFromConfiguration // entries else entries
          ) entriesByNameFromEntriesByNamePath;
        entriesDirEntryByName = configuration.readEntriesDirEntryByName configuration.entriesByNamePath;
        entriesByNameFromConfiguration =
          zipConcatMapAttrsWith
            (name: entries: zipAttrsWith (name: entries: getSingletonElem entries) entries)
            (
              collectionName: entryByName:
              mapAttrsToList (name: entry: {
                ${name}.${
                  collectionConfigurations.${collectionName}.entryName
                    or (throw "lib.byName: entry name for collection `${escapeNixIdentifier collectionName}` is not configured")
                } = entry;
              }) entryByName
            )
            collectionsFromConfiguration;
        entriesByNameFromEntriesByNamePath = mapAttrs (
          name: entriesDirEntry:
          let
            byNameConfiguration = byNameConfigurations.${name} or { };
            byNameCollectionsConfiguration = byNameConfiguration.collections or { };
            entryDirEntries = readDirEntries entriesPath;
            entries = entriesByName.${name};
            entriesPath = entriesDirEntry.path;
            prettyName = escapeNixIdentifier name;
            skipEntryDirEntries = entriesDirEntry.skipDirEntries or false;
          in
          listToAttrs (
            concatMapAttrsToList (
              entryBaseName: entryDirEntry:
              let
                byNameCollectionConfiguration = byNameCollectionsConfiguration.${collectionName} or { };
                byNameEntryBaseNameConfiguration =
                  (byNameCollectionConfiguration.entryBaseNames or { }).${entryBaseName} or { };
                collectionConfiguration = collectionConfigurations.${collectionName};
                collectionIsConfigured = entryNameByEntryBaseName ? ${entryBaseName};
                collectionName = collectionNameByEntryName.${entryName};
                entryBaseNameConfiguration =
                  (collectionConfiguration.entryBaseNames or { }).${entryBaseName} or { };
                entryName =
                  entryNameByEntryBaseName.${entryBaseName}
                    or (throw "lib.byName: collection for entry base name `${prettyEntryBaseName}` is not configured");
                entryPath = entryDirEntry.path;
                entryByNameConfiguration = collectionConfiguration.entryByName or { };
                entryByNameConfigurationPosSuffix =
                  wrapAttrPosString "\nat " "" "entryByName"
                    collectionConfiguration;
                entryFromConfigurationPosSuffix = wrapAttrPosString " at " "" name entryByNameConfiguration;
                importDirEntry =
                  if entryName != "byNameConfiguration" && byNameEntryBaseNameConfiguration ? import then
                    byNameEntryBaseNameConfiguration.import
                  else
                    entryBaseNameConfiguration.import;
                prettyEntryBaseName = escapeNixIdentifier entryBaseName;
                prettyCollectionName =
                  if collectionIsConfigured then escapeNixIdentifier collectionName else "<collection>";
                prettyEntryName = if collectionIsConfigured then escapeNixIdentifier entryName else "<entry>";
                prettyEntryPath = toString entryPath;
              in
              addErrorContext
                "lib.byName: while evaluating entry value `entriesByName.${prettyName}.${prettyEntryName}` (for collection `collections.${prettyCollectionName}`)\nat ${prettyEntryPath}"
                (
                  if isIgnoredEntryDirEntry entryBaseName entryDirEntry then
                    [ ]
                  else
                    [
                      {
                        name = entryName;
                        value =
                          if (collectionsFromConfiguration.${collectionName} or { }) ? ${name} then
                            throw "lib.byName: entry ${prettyName} value${entryFromConfigurationPosSuffix} already defined by `collections.${prettyCollectionName}.entryByName`${entryByNameConfigurationPosSuffix}"
                          else
                            importDirEntry finalByName {
                              inherit
                                byNameEntryBaseNameConfiguration
                                byNameCollectionConfiguration
                                byNameConfiguration
                                collectionName
                                entries
                                entryBaseName
                                entryBaseNameConfiguration
                                entryName
                                name
                                ;
                            } entryDirEntry;
                      }
                    ]
                )
            ) entryDirEntries
          )
        ) entriesDirEntryByName;
        lib = supportLib;
        outputs = configuration.outputs finalByName;
      }
    ) { };

  lib.byName.isIgnoredEntryDirEntry =
    let
      isIgnoredEntryBaseName = hasPrefix "_";
      lib.byName.isIgnoredEntryDirEntry =
        entryBaseName: entryDirEntry: isIgnoredEntryBaseName entryBaseName;
    in
    lib.byName.isIgnoredEntryDirEntry;

  lib.byName.supportLib = supportLibProto currentLib finalLib;

  lib.byName.supportLibProto = prevByName.supportLibProto or (import ./_supportLib.nix);

  prevByName = prevLib.byName or { };
in
currentLib
