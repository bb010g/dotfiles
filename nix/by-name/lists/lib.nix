prevLib: finalLib:
let
  inherit (finalLib.evaluation) throw;
  inherit (finalLib.lists)
    concatMap
    filter
    head
    length
    map
    ;
  inherit (finalLib.values) toString;

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

  /**
    Return the element of a singleton list.

    Throws on an empty list or lists with more than one element.

    # Inputs

    `singleton`
    : Singleton list to get from.

    # Type

    ```
    lib.lists.getSingletonElem :: [a] -> a
    ```

    # Examples
    :::{.example}
    ## `lib.lists.getSingletonElem` usage example

    ```nix
    lib.lists.getSingletonElem [ "foo" ]
    => "foo"
    ```

    :::
  */
  lib.lists.getSingletonElem =
    singleton:
    if length singleton == 1 then
      head singleton
    else
      throw "lib.lists.getSingletonElem: expected a singleton list but found a list with ${toString (length singleton)} elements";

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

  /**
    Visit a list, considering its construction alternatives as non-singleton lists and singleton lists.

    # Inputs

    `listVisitor`
    : Function that, given a non-singleton list,
      returns a result.

    `singletonElemVisitor`
    : Function that, given the element of a singleton list,
      returns a result.

    `list`
    : List to visit.

    # Type

    ```
    lib.lists.visitSingleton :: ([a] -> b) -> (a -> b) -> [a] -> b
    ```

    # Examples
    :::{.example}
    ## `lib.lists.visitSingleton` usage example

    ```nix
    lib.lists.visitSingleton lib.values.toJson (elem: elem + 3) [ 1 2 ]
    => "[1,2]"
    lib.lists.visitSingleton lib.values.toJson (elem: elem + 3) [ 1 ]
    => 4
    ```

    :::
  */
  lib.lists.visitSingleton =
    listVisitor: singletonElemVisitor: list:
    if length list == 1 then singletonElemVisitor (head list) else listVisitor list;
in
prevLib // { lists = prevLib.lists or { } // lib.lists; }
