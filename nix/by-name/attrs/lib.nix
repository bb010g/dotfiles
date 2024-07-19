prevLib: finalLib:
let
  inherit (builtins)
    attrNames
    concatMap
    listToAttrs
    ;
  inherit (finalLib.attrs)
    concatMapAttrsToList
    ;
in
{
  concatMapAttrs' = f: attrs: listToAttrs (concatMapAttrsToList f attrs);
  concatMapAttrsToList = f: attrs: concatMap (name: f name attrs.${name}) (attrNames attrs);
}
