prevLib: finalLib:
let
  inherit (finalLib.attrs)
    attrValues
    filterAttrs
    getAttrPosString
    mapAttrs
    mapFilterAttrs
    isAttrs
    unsafeAttrPosToString
    unsafeGetAttrPos
    zipAttrsWith
    ;
  inherit (finalLib.nulls)
    isNull
    ;

  # TODO: reconsider alongside Witherable
  lib.attrs.filterMapAttrs =
    pred: f: attrs:
    filterAttrs pred (mapAttrs f attrs);

  lib.attrs.getAttrPosString =
    name: attrs:
    let
      pos = unsafeGetAttrPos name attrs;
    in
    if isNull pos then pos else unsafeAttrPosToString pos;

  lib.attrs.mapAttrsRecursiveCond =
    cond: f: attrs:
    let
      recurse =
        path:
        mapAttrs (
          name: value:
          if isAttrs value && cond value then recurse (path ++ [ name ]) value else f (path ++ [ name ]) value
        );
    in
    recurse [ ] attrs;

  lib.attrs.mapFilterAttrs =
    f: pred: attrs:
    mapAttrs f (filterAttrs pred attrs);

  lib.attrs.nameValuePair = name: value: { inherit name value; };

  lib.attrs.transposeAttrs =
    attrs:
    zipAttrsWith (
      innerName: innerValues:
      mapFilterAttrs (outerName: outerValue: outerValue.${innerName}) (
        outerName: outerValue: outerValue ? ${innerName}
      ) attrs
    ) (attrValues attrs);

  lib.attrs.unsafeAttrPosToString =
    attrPos:
    "${attrPos.file}:${toString attrPos.line}:${toString attrPos.column}";

  lib.attrs.wrapAttrPosString =
    prefix: suffix: name: attrs:
    let
      pos = unsafeGetAttrPos name attrs;
    in
    if isNull pos then "" else "${prefix}${unsafeAttrPosToString pos}${suffix}";
in
prevLib // { attrs = prevLib.attrs or { } // lib.attrs; }
