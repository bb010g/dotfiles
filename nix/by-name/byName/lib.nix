# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: ⓒ 2003-2024 Eelco Dolstra and the Nixpkgs/NixOS contributors

# This file turns the by-name directory into imports of all its Nix files.
# No validity checks are done here,
# instead this file is optimised for performance,
# and validity checks are done by CI on PRs.

# Type: Overlay

prevLib: finalLib:
let
  inherit (byName) byNameLib lib;
  inherit (lib)
    abort
    apply
    attrNames
    attrValues
    attrsToList
    baseNameOf
    break
    concatMap
    concatMapAttrs'
    concatMapAttrsToList
    derivation
    derivationStrict
    dirOf
    escape
    escapeNixString
    fetchGit
    fetchMercurial
    fetchTarball
    fetchTree
    filter
    filterAttrs
    filterMap
    filterMapAttrs
    foldl'
    foldlAttrs'
    fromJSON
    fromTOML
    getAttr
    getDefaultedAttr
    hasPrefix
    hasSuffix
    id
    import
    importPath
    isAttrs
    isNull
    isPath
    listToAttrs
    map
    mapAttr
    mapAttrOr
    mapAttrOrElse
    mapAttrs
    mapAttrsRecursiveCond
    mapAttrsToList
    mapDefaultedAttr
    mapFilter
    mapFilterAttrs
    mapNull
    mapNullable
    mapOptionalAttr
    match
    nameValuePair
    partition
    partitionAttr
    partitionAttrOr
    partitionAttrOrElse
    partitionAttrs
    pathExists
    pipe
    readDir
    readDirEntries
    readDirEntry
    readFile
    readFileType
    removeAttr
    removeAttrs
    removePrefix
    removeSuffix
    replaceStrings
    stringLength
    substring
    throw
    toJSON
    toString
    transposeAttrs
    updateAttrs
    validateString
    zipAttrsWith
    ;
  inherit (finalLib) byName;
in
{
  byNameLib = {
    importNamedDirEntries =
      let
        inherit (byNameLib) isIgnored;

        importNamedDirEntries =
          config: name: nameDirEntry: namedDirEntries:
          config.importNamedDirEntries config name nameDirEntry (
            filterAttrs (namedBaseName: namedDirEntry: !(isIgnored namedBaseName namedDirEntry)) namedDirEntries
          );
      in
      importNamedDirEntries;

    importNameDirEntry =
      let
        inherit (byNameLib) importNameDirEntry importNamedDirEntries;
        importNameDirEntries =
          config: name: nameDirEntry:
          importNamedDirEntries config name nameDirEntry (readDirEntries nameDirEntry.path);
      in
      importNameDirEntries;

    importNameDirEntries =
      let
        inherit (byNameLib) importNameDirEntry;
        importNameDirEntries =
          config: nameDirEntries:
          mapAttrs (name: nameDirEntry: importNameDirEntry config name nameDirEntry) nameDirEntries;
      in
      importNameDirEntries;

    isIgnored =
      let
        isIgnored = baseName: dirEntry: isIgnoredBaseName baseName;
        isIgnoredBaseName = hasPrefix "_";
      in
      isIgnored;
  };
  lib = {
    abort = builtins.abort;
    apply = f: value: f value;
    attrNames = builtins.attrNames;
    attrValues = builtins.attrValues;
    attrsToList =
      builtins.attrsToList or (
        let
          attrsToList = attrs: mapAttrsToList (name: value: { inherit name value; }) attrs;
        in
        attrsToList
      );
    baseNameOf = builtins.baseNameOf;
    break = builtins.break;
    concatMap = builtins.concatMap;
    concatMapAttrs' = f: attrs: listToAttrs (concatMapAttrsToList f attrs);
    concatMapAttrsToList =
      builtins.concatMapAttrsToList or (
        let
          concatMapAttrsToList = f: attrs: concatMap (name: f name attrs.${name}) (attrNames attrs);
        in
        concatMapAttrsToList
      );
    derivation = builtins.derivation;
    derivationStrict = builtins.derivationStrict;
    dirOf = builtins.dirOf;
    escape =
      builtins.escape or (
        let
          escape = list: str: replaceStrings list (map (c: "\\${c}") list) str;
        in
        escape
      );
    escapeNixString =
      builtins.escapeNixString or (
        let
          escapeNixString = s: escape [ "$" ] (toJSON s);
        in
        escapeNixString
      );
    fetchGit = builtins.fetchGit;
    fetchMercurial = builtins.fetchMercurial;
    fetchTarball = builtins.fetchTarball;
    fetchTree = builtins.fetchTree;
    filter = builtins.filter;
    filterAttrs =
      builtins.filterAttrs or (
        let
          filterAttrs =
            pred: attrs: removeAttrs (filter (name: !(pred name attrs.${name})) (attrNames attrs)) attrs;
        in
        filterAttrs
      );
    filterMap =
      builtins.filterMap or (
        let
          filterMap =
            pred: f: list:
            concatMap (
              value:
              let
                value' = f value;
              in
              if pred value' then [ value' ] else [ ]
            ) list;
        in
        filterMap
      );
    filterMapAttrs =
      builtins.filterMapAttrs or (
        let
          filterMapAttrs =
            pred: f: attrs:
            filterAttrs pred (mapAttrs f attrs);
        in
        filterMapAttrs
      );
    foldl' = builtins.foldl';
    foldlAttrs' =
      builtins.foldlAttrs' or (
        let
          foldlAttrs' =
            op: nul: attrs:
            foldl' (cur: name: op cur name attrs.${name}) nul (attrNames attrs);
        in
        foldlAttrs'
      );
    fromJSON = builtins.fromJSON;
    fromTOML = builtins.fromTOML;
    getAttr = builtins.getAttr;
    getDefaultedAttr =
      name: default: attrs:
      attrs.${name} or default;
    hasPrefix =
      prefix:
      let
        prefix' = validateString (msg: "hasPrefix: The first argument ${msg}") prefix;
        prefixLength = stringLength prefix';
      in
      str:
      let
        strLength = stringLength str;
      in
      prefixLength <= strLength && substring 0 prefixLength str == prefix';
    hasSuffix =
      suffix:
      let
        suffix' = validateString (msg: "hasSuffix: The first argument ${msg}") suffix;
        suffixLength = stringLength suffix';
      in
      str:
      let
        strLength = stringLength str;
        substrLength = strLength - suffixLength;
      in
      suffixLength <= strLength && substring substrLength suffixLength str == suffix';
    id =
      builtins.id or (
        let
          /**
            Return the argument.

            # Inputs

            `f`

            : Value to return

            # Type

            ```
            id :: a -> a
            ```
          */
          id = value: value;
        in
        id
      );
    import = builtins.import;
    importPath =
      path:
      let
        defaultPath = path + "/default.nix";
      in
      if pathExists defaultPath then
        defaultPath
      else if pathExists path then
        path
      else
        null;
    isAttrs = builtins.isAttrs;
    isNull = builtins.isNull;
    isPath = builtins.isPath;
    listToAttrs = builtins.listToAttrs;
    map = builtins.map;
    mapAttr =
      name: f: attrs:
      attrs // { ${name} = f attrs.${name}; };
    mapAttrOr =
      name: default: f: attrs:
      if attrs ? ${name} then attrs // { ${name} = f attrs.${name}; } else default;
    mapAttrOrElse =
      name: defaultFn: f: attrs:
      if attrs ? ${name} then attrs // { ${name} = f attrs.${name}; } else defaultFn attrs;
    mapAttrs = builtins.mapAttrs;
    mapAttrsRecursiveCond =
      cond: f: attrs:
      let
        recurse =
          path:
          mapAttrs (
            name: value:
            if isAttrs value && cond value then recurse (path ++ [ name ]) value else f (path ++ [ name ]) value
          );
      in
      recurse [ ] attrs;
    mapAttrsToList =
      builtins.mapAttrsToList or (
        let
          mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (attrNames attrs);
        in
        mapAttrsToList
      );
    mapDefaultedAttr =
      name: default: f: attrs:
      attrs // { ${name} = f attrs.${name} or default; };
    mapFilter =
      builtins.mapFilter or (
        let
          mapFilter =
            f: pred: list:
            map f (filter pred list);
        in
        mapFilter
      );
    mapFilterAttrs =
      builtins.mapFilterAttrs or (
        let
          mapFilterAttrs =
            f: pred: attrs:
            mapAttrs f (filterAttrs pred attrs);
        in
        mapFilterAttrs
      );
    mapNull = default: value: if value == null then default else value;
    mapNullable = f: value: if value != null then f value else null;
    mapOptionalAttr =
      name: f: attrs:
      if attrs ? ${name} then attrs // { ${name} = f attrs.${name}; } else attrs;
    match = builtins.match;
    nameValuePair = name: value: { inherit name value; };
    partition = builtins.partition;
    partitionAttr = name: attrs: {
      right = attrs.${name};
      wrong = removeAttr name attrs;
    };
    partitionAttrOr =
      name: default: attrs:
      if attrs ? ${name} then
        {
          right = attrs.${name};
          wrong = removeAttr name attrs;
        }
      else
        default;
    partitionAttrOrElse =
      name: defaultFn: attrs:
      if attrs ? ${name} then
        {
          right = attrs.${name};
          wrong = removeAttr name attrs;
        }
      else
        defaultFn attrs;
    partitionAttrs =
      builtins.partitionAttrs or (
        let
          partitionAttrs =
            pred: attrs:
            let
              inherit (partition (name: pred name attrs.${name}) (attrNames attrs)) right wrong;
            in
            {
              right = removeAttrs wrong attrs;
              wrong = removeAttrs right attrs;
            };
        in
        partitionAttrs
      );
    pathExists = builtins.pathExists;
    pipe = foldl' (value: f: f value);
    readDir = builtins.readDir;
    readDirEntries =
      builtins.readDirEntries or (
        let
          readDirEntries =
            path:
            mapAttrs (baseName: type: {
              inherit type;
              path = path + "/${baseName}";
            }) (readDir path);
        in
        readDirEntries
      );
    readDirEntry =
      builtins.readDirEntry or (
        let
          readDirEntry = path: {
            inherit path;
            type = readFileType path;
          };
        in
        readDirEntry
      );
    readFile = builtins.readFile;
    readFileType = builtins.readFileType;
    removeAttr = name: attrs: removeAttrs [ name ] attrs;
    removeAttrs =
      let
        builtinRemoveAttrs = builtins.removeAttrs;
        removeAttrs = names: attrs: builtinRemoveAttrs attrs names;
      in
      removeAttrs;
    removePrefix =
      prefix:
      let
        prefix' = validateString (msg: "removePrefix: The first argument ${msg}") prefix;
        prefixLength = stringLength prefix';
      in
      str:
      let
        strLength = stringLength str;
        substrLength = strLength - prefixLength;
      in
      if prefixLength <= strLength && substring 0 prefixLength str == prefix' then
        substring prefixLength substrLength str
      else
        null;
    removeSuffix =
      suffix:
      let
        suffix' = validateString (msg: "removeSuffix: The first argument ${msg}") suffix;
        suffixLength = stringLength suffix';
      in
      str:
      let
        strLength = stringLength str;
        substrLength = strLength - suffixLength;
      in
      if suffixLength <= strLength && substring substrLength suffixLength str == suffix' then
        substring 0 substrLength str
      else
        null;
    replaceStrings = builtins.replaceStrings;
    stringLength = builtins.stringLength;
    substring = builtins.substring;
    throw = builtins.throw;
    toJSON = builtins.toJSON;
    toString = builtins.toString;
    transposeAttrs =
      attrs:
      zipAttrsWith (
        innerName: innerValues:
        mapFilterAttrs (outerName: outerValue: outerValue.${innerName}) (
          outerName: outerValue: outerValue ? ${innerName}
        ) attrs
      ) (attrValues attrs);
    updateAttrs = newAttrs: attrs: attrs // newAttrs;
    validateString =
      msgFn: str:
      if isPath str then
        throw (msgFn ''${escapeNixString (toString str)} is a path value, but only strings are supported.'')
      else
        str;
    zipAttrsWith = builtins.zipAttrsWith;
  };
}
