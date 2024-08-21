{ ... }:
prevLib: finalLib:
let
  inherit (finalLib.strings)
    ;
  lib.strings = { };
in
prevLib // { strings = prevLib.strings or { } // lib.strings; }
