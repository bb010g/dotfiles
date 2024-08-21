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
  inherit (bareBuiltins.builtins) mapAttrs throw;
  inherit (builtins) trace;
  inherit (builtins') builtins;
  bareBuiltins' = mapAttrs (name: value: throw "Bare builtin: ${name}") bareBuiltins;
  builtins' = bareBuiltins.scopedImport scope ./_builtins.nix bareBuiltins.builtins builtins;
  lib = builtins.scopedImport scope ./lib.nix { inherit builtins; } lib;
  overriddenBuiltins = builtins.intersectAttrs bareBuiltins.builtins builtins';
  overriddenBuiltins' = builtins.removeAttrs overriddenBuiltins [ "builtins" ];
  outputs = scope // { inherit bareBuiltins; } // lib // { inherit lib; };
  scope = bareBuiltins';
in
if overriddenBuiltins' != { } then
  trace "overridden builtins:" (trace overriddenBuiltins' outputs)
else
  outputs
