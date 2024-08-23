prevLib: finalLib:
let
  inherit (finalLib.strings)
    ;
  lib.strings.addPrefix = prefix: string:
    "${prefix}${string}";
  lib.strings.addSuffix = suffix: string:
    "${string}${suffix}";
in
prevLib // { strings = prevLib.strings or { } // lib.strings; }
