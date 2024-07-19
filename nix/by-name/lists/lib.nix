prevLib: finalLib:
let
  inherit (builtins)
    attrNames
    concatMap
    elemAt
    length
    listToAttrs
    ;
  inherit (finalLib.lists)
    ;
in
{
  foldr = builtins.foldr or (
    let
      foldr = op: nul: list:
        let
          len = length list;
          foldrAt = n: if n < len then op (elemAt list n) (foldrAt (n + 1)) else nul;
        in
        foldrAt 0;
    in
    foldr
  );
  optional = cond: elem: if cond then [ elem ] else [ ];
  optionalNullable = elem: if elem != null then [ elem ] else [ ];
}
