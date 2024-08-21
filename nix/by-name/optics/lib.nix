{ ... }:
prevLib: finalLib:
let
  inherit (finalLib.optics)
    makeLens
    ;
  lib.optics.attr = name: makeLens {
    get = attrs: attrs.${name};
    set = value: attrs: attrs // { ${name} = value; };
  };
  lib.optics.makeLens = { get, set, ... }: {
    __meta.proto = null;
    __toString = obj: "lens";
  };
in
prevLib // { optics = prevLib.optics or { } // lib.optics; }
