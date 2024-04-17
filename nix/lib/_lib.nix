let
  inherit (builtins)
    attrNames
    concatMap
    elemAt
    listToAttrs
    mapAttrs
    match
    readDir
    removeAttrs
    ;
  concatMapAttrs' = f: attrs: listToAttrs (concatMapAttrsToList f attrs);
  concatMapAttrsToList = f: attrs: concatMap (name: f name attrs.${name}) (attrNames attrs);
  mapNullable = f: val: if val != null then f val else null;
  mkDirEntries = path: dir:
    mapAttrs (baseName: type: { inherit type; path = path + "/${baseName}"; }) dir;
  optionalNullable = elem: if elem != null then [ elem ] else [ ];
  readDirEntries = path: mkDirEntries path (readDir path);
in
removeAttrs
  (concatMapAttrs'
    (
      baseName: { path, type, ... }:
      let
        name = mapNullable
          (matches: let name = elemAt matches 0; in if name != "lib" then name else null)
          (match ''_(.*).nix'' baseName);
        value = import path;
      in
      optionalNullable (mapNullable (name: { inherit name value; }) name)
    )
    (readDirEntries ./.))
  [ "lib" ]
