let
  inherit (builtins)
    attrNames
    concatMap
    listToAttrs
    ;
  inherit (lib.attrs)
    concatMapAttrsToList
    ;
  lib = import ./_lib.nix;
in
{
  concatMapAttrs' = f: attrs: listToAttrs (concatMapAttrsToList f attrs);
  concatMapAttrsToList = f: attrs: concatMap (name: f name attrs.${name}) (attrNames attrs);
}
