prevLib: finalLib:
let
  inherit (finalLib.lists) concatMap filter map;

  # TODO: reconsider alongside Witherable
  lib.lists.filterMap =
    pred: f: list:
    concatMap (
      value:
      let
        value' = f value;
      in
      if pred value' then [ value' ] else [ ]
    ) list;

  lib.lists.mapFilter =
    f: pred: list:
    concatMap (
      value:
      let
        value' = f value;
      in
      if pred value then [ value' ] else [ ]
    ) list;

  lib.lists.optional = cond: elem: if cond then [ elem ] else [ ];

  lib.lists.optionalNullable = elem: if elem != null then [ elem ] else [ ];
in
prevLib // { lists = prevLib.lists or { } // lib.lists; }
