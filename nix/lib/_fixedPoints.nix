let
  inherit (_lib.fixedPoints)
    makeExtensibleHook
    makeInheritableHook
    ;
  inherit (_lib.pop)
    extendObj
    extensionToProto
    hookObj
    instantiateObj
    ;
  inherit (builtins)
    ;
  _lib = import ./_lib.nix;
in
{
  makeExtensible = mkFinal:
    hookObj makeExtensibleHook (instantiateObj (final: prev: prev // mkFinal final) { });
  makeExtensibleHook = final: prev:
    prev // { __extend__ = extension: extendObj (extensionToProto extension) final; };
  makeInheritable = obj: hookObj makeInheritableHook obj;
  makeInheritableHook = final: prev: prev // { __inherit__ = proto: extendObj proto final; };
}
