let
  bareLib = libBareMeta.proto libBareMeta.base lib;
  lib = bareLib // {
    __meta = bareLib.__meta or { } // libBareMeta;
  };
  libBareMeta.base = { };
  libBareMeta.proto =
    prevLib: finalLib:
    let
      builtinsLib = builtins.import ../builtins/lib.nix (
        prevLib // { builtinsProto = prevLib.builtinsProto or (builtins.import ../builtins/_builtins.nix); }
      ) finalLib;
      protosLib = builtinsLib.filesystem.import ../protos/lib.nix builtinsLib finalLib;
      attrsLib = builtinsLib.filesystem.import ../attrs/lib.nix protosLib finalLib;
      listsLib = builtinsLib.filesystem.import ../lists/lib.nix attrsLib finalLib;
      nullsLib = builtinsLib.filesystem.import ../nulls/lib.nix listsLib finalLib;
    in
    builtinsLib.filesystem.import ./lib.nix nullsLib finalLib;
in
lib
