{ ... }:
prevLib: finalLib:
let
  inherit (builtins)
    ;
  inherit (finalLib.fixedPoints)
    makeExtensibleHook
    makeInheritableHook
    ;
  inherit (finalLib.pop)
    extendObj
    extensionToProto
    hookObj
    instantiateObj
    ;
  lib.fixedPoints.makeExtensible = mkFinal:
    hookObj makeExtensibleHook (instantiateObj (final: prev: prev // mkFinal final) { });
  lib.fixedPoints.makeExtensibleHook = final: prev:
    prev // { __extend__ = extension: extendObj (extensionToProto extension) final; };
  lib.fixedPoints.makeInheritable = obj: hookObj makeInheritableHook obj;
  lib.fixedPoints.makeInheritableHook = final: prev: prev // { __inherit__ = proto: extendObj proto final; };
in
prevLib // { fixedPoints = prevLib.fixedPoints or { } // lib.fixedPoints; }
