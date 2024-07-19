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
in
{
  makeExtensible = mkFinal:
    hookObj makeExtensibleHook (instantiateObj (final: prev: prev // mkFinal final) { });
  makeExtensibleHook = final: prev:
    prev // { __extend__ = extension: extendObj (extensionToProto extension) final; };
  makeInheritable = obj: hookObj makeInheritableHook obj;
  makeInheritableHook = final: prev: prev // { __inherit__ = proto: extendObj proto final; };
}
