prevLib: finalLib:
let
  inherit (finalLib) builtins;
  inherit (finalLib.attrs)
    removeAttrs
    ;
  inherit (finalLib.bools)
    false
    true
    ;
  inherit (finalLib.byName)
    importNameDirEntries
    importNameDirEntry
    importNamedDirEntries
    isIgnored
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
  inherit (finalLib.evaluation)
    abort
    break
    throw
    ;
  inherit (finalLib.filesystem)
    import
    scopedImport
    ;
  inherit (finalLib.lists)
    map
    ;
  inherit (finalLib.nulls)
    isNull
    null
    ;
  inherit (finalLib.strings)
    baseNameOf
    dirOf
    ;
  inherit (finalLib.values)
    fromTOML
    toString
    ;

  lib.nulls.filterNullable = pred: value: if pred value then value else null;

  lib.nulls.ifNull = default: value: if value == null then default else value;

  lib.nulls.mapNullable = f: value: if value != null then f value else null;

  lib.nulls.visitNullable = default: f: value: if value == null then default else f value;
in
prevLib // { nulls = prevLib.nulls or { } // lib.nulls; }
