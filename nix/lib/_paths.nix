let
  inherit (_lib.attrs)
    concatMapAttrs'
    concatMapAttrsToList
    ;
  inherit (_lib.paths)
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
  inherit (_lib.strings)
    hasPrefix
    hasSuffix
    removePrefix
    removeSuffix
    ;
  inherit (builtins)
    attrNames
    baseNameOf
    filter
    filterSource
    mapAttrs
    pathExists
    readDir
    ;
  _lib = import ./_lib.nix;
  builtinPath = builtins.path;
  isNixSourcePathFilter = pathFilters.isNixSource;
in
{
  baseOfIgnoredBaseName = removePrefix ignoredBaseNamePrefix;
  baseOfNixSourceBaseName = removeSuffix ".nix";
  concatMapDirEntries' = pathFn: dirEntries:
    concatMapAttrs' (pathFnToDirEntryFn pathFn) dirEntries;
  concatMapDirEntriesToList = pathFn: dirEntries:
    concatMapAttrsToList (pathFnToDirEntryFn pathFn) dirEntries;
  filterDirEntries = pathFilter: dirEntries:
    filter (pathFnToDirEntryFn pathFilter) dirEntries;
  filterPath = pathFilter: path:
    filterSource (pathFnToSourceFn pathFilter) path;
  # getNixSourceDirEntries =
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
  getPath = args: builtinPath (
    if args ? filter then
      args // { filter = pathFnToSourceFn args.filter; }
    else
      args
  );
  ignoredBaseNamePrefix = "_";
  importOr = default: path: mapExistingPathOr import default path;
  isIgnoredBaseName = hasPrefix ignoredBaseNamePrefix;
  isNixSourceBaseName = hasSuffix ".nix";
  mapExistingPathOr = f: default: path: if pathExists path then f path else default;
  mapImportOr = f: default: path: mapExistingPathOr (path: f (import path)) default path;
  mkDirEntries = path: dir:
    mapAttrs (baseName: type: { inherit type; path = path + "/${baseName}"; }) dir;
  pathFnToDirEntryFn = pathFn: (
    baseName: dirEntry@{ path, type, ... }: pathFn baseName path type
  );
  pathFnToSourceFn = pathFn: (
    path: type: pathFn (baseNameOf path) path type
  );
  pathFilters.isNixSource = baseName: path: type:
    !(isIgnoredBaseName baseName) && (type == "directory" || isNixSourceBaseName baseName);
  readDirEntries = path: mkDirEntries path (readDir path);
  # walkDirEntries = walker: path:
  #   concatMapAttrs
}
