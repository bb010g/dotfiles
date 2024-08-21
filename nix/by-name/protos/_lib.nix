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
  inherit (builtins') intersectAttrs mapAttrs throw;
  bareBuiltins' = mapAttrs (name: value: throw "Bare builtin: ${name}") bareBuiltins;
  # builtins' = import ../builtins/lib.nix;
  builtins' = builtins;
  lib = builtins'.scopedImport scope ./lib.nix { } lib;
  scope = bareBuiltins' // {
    builtins = builtins';
  };
in
scope // { inherit lib; } // lib // lib.protos
