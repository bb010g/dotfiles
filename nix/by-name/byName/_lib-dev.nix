let
  bareBuiltins = {
    inherit
      abort
      baseNameOf
      break
      builtins
      derivation
      derivationStrict
      dirOf
      false
      fetchGit
      fetchMercurial
      fetchTarball
      fetchTree
      fromTOML
      import
      isNull
      map
      null
      placeholder
      removeAttrs
      scopedImport
      throw
      toString
      true
      ;
  };
in
let
  inherit (bareBuiltins.builtins) mapAttrs scopedImport throw;
  inherit (builtins') builtins;
  bareBuiltins' = mapAttrs (name: value: throw "Bare builtin: ${name}") bareBuiltins;
  bareLib = libBareMeta.proto libBareMeta.base lib;
  builtins' = scopedImport scope ../builtins/_builtins.nix bareBuiltins.builtins builtins;
  lib = bareLib // {
    __meta = bareLib.__meta or { } // libBareMeta;
  };
  libBareMeta.base = { };
  libBareMeta.proto =
    prevLib: finalLib:
    let
      builtinsLib = builtins.scopedImport scope ../builtins/lib.nix (
        prevLib // { builtinsProto = prevLib.builtinsProto or (prevBuiltins: finalBuiltins: builtins); }
      ) finalLib;
      protosLib = builtinsLib.filesystem.scopedImport scope ../protos/lib.nix builtinsLib finalLib;
      attrsLib = builtinsLib.filesystem.scopedImport scope ../attrs/lib.nix protosLib finalLib;
      listsLib = builtinsLib.filesystem.scopedImport scope ../lists/lib.nix attrsLib finalLib;
      nullsLib = builtinsLib.filesystem.scopedImport scope ../nulls/lib.nix listsLib finalLib;
      stringsLib = builtinsLib.filesystem.scopedImport scope ../strings/lib.nix nullsLib finalLib;
    in
    builtinsLib.filesystem.scopedImport scope ./lib.nix stringsLib finalLib;
  scope = bareBuiltins';
in
scope // { inherit lib; } // lib // lib.byName
