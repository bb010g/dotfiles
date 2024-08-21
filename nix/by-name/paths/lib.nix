{ ... }:
prevLib: finalLib:
let
  inherit (builtins)
    attrNames
    baseNameOf
    filter
    filterSource
    mapAttrs
    pathExists
    readDir
    ;
  inherit (finalLib.attrs)
    concatMapAttrs'
    concatMapAttrsToList
    ;
  inherit (finalLib.paths)
    baseOfNixSourceBaseName
    ignoredBaseNamePrefix
    isIgnoredBaseName
    isNixSourceBaseName
    mapExistingPathOr
    mkDirEntries
    pathFilters
    pathFnToDirEntryFn
    pathFnToSourceFn
    ;
  inherit (finalLib.strings)
    hasPrefix
    hasSuffix
    removePrefix
    removeSuffix
    ;
  builtinPath = builtins.path;
  isNixSourcePathFilter = pathFilters.isNixSource;
  lib.paths.baseOfIgnoredBaseName = removePrefix ignoredBaseNamePrefix;
  lib.paths.baseOfNixSourceBaseName = removeSuffix ".nix";
  lib.paths.concatMapDirEntries' = pathFn: dirEntries:
    concatMapAttrs' (pathFnToDirEntryFn pathFn) dirEntries;
  lib.paths.concatMapDirEntriesToList = pathFn: dirEntries:
    concatMapAttrsToList (pathFnToDirEntryFn pathFn) dirEntries;
  lib.paths.filterDirEntries = pathFilter: dirEntries:
    filter (pathFnToDirEntryFn pathFilter) dirEntries;
  lib.paths.filterPath = pathFilter: path:
    filterSource (pathFnToSourceFn pathFilter) path;
  # lib.paths.getNixSourceDirEntries =
  #   args@{
  #     dirEntries,
  #     ...
  #   }:
  #   let
  #     dirEntryFn = baseName: dirEntry@{ path, type, ... }:
  #       let
  #         ignoredBaseName = baseOfIgnoredBaseName baseName;
  #         name = if ignoredBaseName == null then baseOfNixSourceBaseName baseName else null;
  #         dirEntry' = dirEntry // { inherit baseName; };
  #       in
  #       if name != null then [ { inherit name; value = dirEntry'; } ] else [ ];
  #   in
  #   concatMapAttrs' dirEntryFn dirEntries;
  lib.paths.getPath = args: builtinPath (
    if args ? filter then
      args // { filter = pathFnToSourceFn args.filter; }
    else
      args
  );
  lib.paths.ignoredBaseNamePrefix = "_";
  lib.paths.importOr = default: path: mapExistingPathOr import default path;
  lib.paths.isIgnoredBaseName = hasPrefix ignoredBaseNamePrefix;
  lib.paths.isNixSourceBaseName = hasSuffix ".nix";
  lib.paths.mapExistingPathOr = f: default: path: if pathExists path then f path else default;
  lib.paths.mapImportOr = f: default: path: mapExistingPathOr (path: f (import path)) default path;
  lib.paths.mkDirEntries = path: dir:
    mapAttrs (baseName: type: { inherit type; path = path + "/${baseName}"; }) dir;
  lib.paths.pathFnToDirEntryFn = pathFn: (
    baseName: dirEntry@{ path, type, ... }: pathFn baseName path type
  );
  lib.paths.pathFnToSourceFn = pathFn: (
    path: type: pathFn (baseNameOf path) path type
  );
  lib.paths.pathFilters.isNixSource = baseName: path: type:
    !(isIgnoredBaseName baseName) && (type == "directory" || isNixSourceBaseName baseName);
  lib.paths.readDirEntries = path: mkDirEntries path (readDir path);
  # lib.paths.walkDirEntries = walker: path:
  #   concatMapAttrs
in
prevLib // { paths = prevLib.paths or { } // lib.paths; }
