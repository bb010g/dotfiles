# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: ⓒ 2003-2024 Eelco Dolstra and the Nixpkgs/NixOS contributors

prevBuiltins@{
  abort,
  attrNames,
  attrValues,
  baseNameOf,
  break,
  builtins,
  concatMap,
  derivation,
  derivationStrict,
  dirOf,
  elemAt,
  false,
  fetchGit,
  fetchMercurial,
  fetchTarball,
  fetchTree,
  filter,
  foldl',
  fromJSON,
  fromTOML,
  getAttr,
  hasAttr,
  import,
  intersectAttrs,
  isAttrs,
  isNull,
  isPath,
  length,
  listToAttrs,
  map,
  mapAttrs,
  match,
  null,
  partition,
  placeholder,
  pathExists,
  readDir,
  readFile,
  readFileType,
  removeAttrs,
  replaceStrings,
  scopedImport,
  seq,
  stringLength,
  substring,
  throw,
  toJSON,
  toString,
  trace,
  true,
  /**
    # Type

    ```
    builtins.zipAttrsWith :: (n <: String) => (n -> [a] -> b) -> [Attrs n a] -> Attrs n b
    ```
  */
  zipAttrsWith,
  ...
}:
finalBuiltins:
let
  inherit (finalBuiltins)
    abort
    attrNames
    baseNameOf
    break
    concatMap
    concatMapAttrsToList
    derivation
    derivationStrict
    dirOf
    elemAt
    escape
    escapeNixString
    false
    fetchGit
    fetchMercurial
    fetchTarball
    fetchTree
    filter
    filterAttrs
    foldl
    foldl'
    foldr'
    fromTOML
    getAttr
    import
    isNull
    isPath
    length
    map
    mapAttrs
    mapAttrsToList
    match
    null
    partition
    pass
    placeholder
    readDir
    readFileType
    removeAttr
    removeAttrs
    replaceStrings
    scopedImport
    seq
    stringLength
    substring
    throw
    toJSON
    toString
    true
    zipAttrsWith
    ;

  /**
    Appends string context from string like object `src` to `target`.

    :::{.warning}
    This is an implementation
    detail of Nix and should be used carefully.
    :::

    Strings in Nix carry an invisible `context` which is a list of strings
    representing store paths. If the string is later used in a derivation
    attribute, the derivation will properly populate the `inputDrvs` and
    `inputSrcs`.


    # Inputs

    `src`
    : String to take the context from. If the argument is not a string,
      it will be implicitly converted to a string.

    `target`
    : String to append the context to. If the argument is not a string,
      it will be implicitly converted to a string.

    # Type

    ```
    builtins.appendContext :: (a <: String) -> String -> a -> a
    ```

    # Examples
    :::{.example}
    ## `builtins.appendContext` usage example

    ```nix
    pkgs = import <nixpkgs> { };
    builtins.appendContext pkgs.coreutils "bar"
    => "bar"
    ```

    The context can be displayed using the `toString` function:

    ```nix
    builtins.getContext (builtins.appendContext pkgs.coreutils "bar")
    => {
      "/nix/store/m1s1d2dk2dqqlw3j90jl3cjy2cykbdxz-coreutils-9.5.drv" = { ... };
    }
    ```

    :::
  */
  builtins.appendContext = src: target: substring 0 0 src + target;

  /**
    Return the application of the function `f` to the argument `value`.

    # Inputs

    `f`
    : Function to apply.

    `value`
    : Value to pass.

    # Type

    ```
    builtins.apply :: (a -> b) -> a -> b
    ```

    # Examples
    :::{.example}
    ## `builtins.apply` usage example

    ```nix
    builtins.apply (x: x + 1) 3
    => 4
    ```

    :::
  */
  builtins.apply = f: value: f value;

  builtins.attrAt = attrs: name: getAttr name attrs;

  /**
    Return a list of a `name`-`value` pair for each attribute in the given
    attrset.

    # Inputs

    `attrs`
    : Attribute set to convert.

    # Type

    ```
    builtins.attrsToList :: (n <: String) => Attrs n a -> [{ name :: n; value :: a; }]
    ```

    # Examples
    :::{.example}
    ## `builtins.attrsToList` usage example

    ```nix
    builtins.attrsToList { x = "a"; y = "b"; }
    => [ { name = "x"; value = "a"; } { name = "y"; value = "b"; } ]
    ```

    :::
  */
  builtins.attrsToList = attrs: mapAttrsToList (name: value: { inherit name value; }) attrs;

  builtins.builtins = builtins // prevBuiltins;

  /**
    Return the first argument, discarding the second argument.

    # Inputs

    `value`
    : Value to return.

    `_`
    : Value to discard.

    # Type

    ```
    builtins.const :: a -> b -> a
    ```

    # Examples
    :::{.example}
    ## `builtins.const` usage example
    ```nix
    builtins.const "foo" "bar"
    => "foo"
    ```

    :::
  */
  builtins.const = value: _: value;

  /**
    This function is equivalent to
    `builtins.concatLists (builtins.mapAttrsToList f attrs)` but is more
    efficient.

    Call a function for each attribute in the given set and return the
    concatenation of the result lists.

    # Inputs

    `f`
    : Function that, given an attribute's name and value,
      returns a new list of values.

    `attrs`
    : Attribute set to map over.

    # Type

    ```
    builtins.concatMapAttrsToList :: (n <: String) => (n -> a -> [b]) -> Attrs n a -> [b]
    ```

    # Examples
    :::{.example}
    ## `builtins.concatMapAttrsToList` usage example

    ```nix
    builtins.concatMapAttrsToList (name: value: [ name (name + value) value ])
       { x = "a"; y = "b"; }
    => [ "x" "xa" "a" "y" "yb" "b" ]
    ```

    :::
  */
  builtins.concatMapAttrsToList = f: attrs: concatMap (name: f name attrs.${name}) (attrNames attrs);

  /**
    Escape occurrences in `string` of elements of `list` by
    prefixing each occurrence with a backslash.

    # Inputs

    `list`
    : List of strings to find.

    `str`
    : String to escape.

    # Type

    ```
    builtins.escape :: [String] -> String -> String
    ```

    # Examples
    :::{.example}
    ## `builtins.escape` usage example
    ```nix
    builtins.escape ["(" ")"] "(foo)"
    => "\\(foo\\)"
    ```

    :::
  */
  builtins.escape = list: str: replaceStrings list (map (c: "\\${c}") list) str;

  /**
    Quotes a string if it can't be used as an identifier directly.

    # Inputs

    `str`
    : Nix identifier name string.

    # Type

    ```
    builtins.escapeNixIdentifier :: String -> String
    ```

    # Examples
    :::{.example}
    ## `builtins.escapeNixIdentifier` usage example

    ```nix
    builtins.escapeNixIdentifier "hello"
    => "hello"
    builtins.escapeNixIdentifier "0abc"
    => "\"0abc\""
    ```

    :::
  */
  builtins.escapeNixIdentifier =
    str:
    # Regex from https://github.com/NixOS/nix/blob/d048577909e383439c2549e849c5c2f2016c997e/src/libexpr/lexer.l#L91
    if match "[a-zA-Z_][a-zA-Z0-9_'-]*" str != null then str else escapeNixString str;

  /**
    Turn a string into a Nix expression representing that string

    # Inputs

    `str`
    : String to escape.

    # Type

    ```
    builtins.escapeNixString :: String -> String
    ```

    # Examples
    :::{.example}
    ## `builtins.escapeNixString` usage example

    ```nix
    builtins.escapeNixString "hello\${}\n"
    => "\"hello\\\${}\\n\""
    ```

    :::
  */
  builtins.escapeNixString = str: escape [ "$" ] (toJSON str);

  builtins.filterAttrs =
    pred: attrs: removeAttrs attrs (filter (name: !(pred name attrs.${name})) (attrNames attrs));

  /**
    Flip the order of a function's first two arguments.

    Return the application of the function `f` to the second argument `value1`
    and the first argument `value2`.

    # Inputs

    `f`
    : Function to apply to `value1` and `value2`.

    `value2`
    : Value to pass to `f` second.

    `value1`
    : Value to pass to `f` first.

    # Type

    ```
    builtins.apply :: (a -> b -> c) -> b -> a -> c
    ```

    # Examples
    :::{.example}
    ## `builtins.flip` usage example

    ```nix
    builtins.flip (x: y: x + y) "x" "y"
    => "yx"
    builtins.flip builtins.removeAttrs [ "b" ]
       { a = 1; b = 2; }
    => { a = 1; }
    ```

    :::
  */
  builtins.flip =
    f: value2: value1:
    f value1 value2;

  builtins.fix =
    f:
    let
      final = f final;
    in
    final;

  builtins.foldl =
    op: nul: list:
    let
      foldlWorker =
        prevIndex:
        let
          index = prevIndex - 1;
          value = elemAt list index;
          cur = foldlWorker index;
        in
        if prevIndex > 0 then op cur value else nul;
    in
    foldlWorker (length list);

  /**
    Reduce a list by applying a binary operator from left to right,
    starting with an initial accumulator.

    Before each application of the operator,
    the accumulator value is evaluated.
    This behavior makes this function stricter than `builtins.foldl`.

    Unlike `builtins.foldl'`,
    the initial accumulator argument is evaluated before the first iteration.

    A call like

    ```nix
    builtins.foldl'' op acc₀ [ x₀ x₁ x₂ ... xₙ₋₁ xₙ ]
    ```

    is (denotationally) equivalent to the following,
    but with the added benefit that `builtins.foldl'` itself will never
    overflow the stack.

    ```nix
    let
      acc₁   = builtins.seq acc₀   (op acc₀   x₀  );
      acc₂   = builtins.seq acc₁   (op acc₁   x₁  );
      acc₃   = builtins.seq acc₂   (op acc₂   x₂  );
      ...
      accₙ   = builtins.seq accₙ₋₁ (op accₙ₋₁ xₙ₋₁);
      accₙ₊₁ = builtins.seq accₙ   (op accₙ   xₙ  );
    in
    accₙ₊₁

    # Or ignoring builtins.seq
    op (op (... (op (op (op acc₀ x₀) x₁) x₂) ...) xₙ₋₁) xₙ
    ```

    # Inputs

    `op`
    : The binary operation to run, where the two arguments are:

      1. `acc`: The current accumulator value:
         Either the initial one for the first iteration,
         or the result of the previous iteration
      2. `x`: The corresponding list element for this iteration

    `nul`
    : The initial accumulator value.

      The accumulator value is evaluated in any case before the first
      iteration starts.

      To avoid evaluation even before the `list` argument is given an eta
      expansion can be used:

      ```nix
      list: builtins.foldl'' op nul list
      ```

    `list`
    : The list to fold.

    # Type

    ```
    builtins.foldl'' :: (b -> a -> b) -> b -> [a] -> b
    ```

    # Examples
    :::{.example}
    ## `builtins.foldl''` usage example

    ```nix
    builtins.foldl'' (nul: x: nul + x) 0 [ 1 2 3 ]
    => 6
    ```

    :::
  */
  builtins.foldl'' = op: nul: seq nul (foldl' op nul);

  builtins.foldr =
    op: nul: list:
    let
      foldrWorker =
        index:
        let
          value = elemAt list index;
          cur = foldrWorker nextIndex;
          nextIndex = index + 1;
        in
        if index < length list then op value cur else nul;
    in
    foldrWorker 0;

  builtins.foldr' =
    op: nul: list:
    let
      foldrWorker' =
        prevIndex: cur:
        let
          index = prevIndex - 1;
          value = elemAt list index;
          nextCur = op value cur;
        in
        if prevIndex > 0 then foldrWorker' (seq nextCur index) nextCur else cur;
    in
    foldrWorker' (length list) nul;

  builtins.foldr'' = op: nul: seq nul (foldr' op nul);

  builtins.getElem =
    index: list:
    elemAt list index;

  builtins.getOptionalAttr =
    default: name: attrs:
    attrs.${name} or default;

  builtins.hasPrefix =
    prefix:
    let
      prefix' =
        if isPath prefix then
          abort ''hasPrefix: The first argument ${escapeNixString (toString prefix)} is a path value, but only strings are supported.''
        else
          prefix;
      prefixLength = stringLength prefix';
      hasPrefix =
        str:
        let
          strLength = stringLength str;
        in
        prefixLength <= strLength && substring 0 prefixLength str == prefix';
    in
    hasPrefix;

  builtins.hasSuffix =
    suffix:
    let
      suffix' =
        if isPath suffix then
          abort ''hasSuffix: The first argument ${escapeNixString (toString suffix)} is a path value, but only strings are supported.''
        else
          suffix;
      suffixLength = stringLength suffix';
      hasSuffix =
        str:
        let
          strLength = stringLength str;
          substrLength = strLength - suffixLength;
        in
        suffixLength <= strLength && substring substrLength suffixLength str == suffix';
    in
    hasSuffix;

  /**
    Return the argument.

    # Inputs

    `value`
    : Value to return.

    # Type

    ```
    builtins.identity :: a -> a
    ```

    # Examples
    :::{.example}
    ## `builtins.identity` usage example

    ```nix
    builtins.identity null
    => null
    builtins.identity false
    => false
    builtins.identity 42
    => 42
    builtins.identity "foo"
    => "foo"
    builtins.identity [ "foo" "bar" ]
    => [ "foo" "bar" ]
    builtins.identity { a = 6; b = 7; }
    => { a = 6; b = 7; }
    builtins.identityentity builtins.identity
    => builtins.identity
    ```

    :::
  */
  builtins.identity = value: value;

  builtins.mapAttr =
    f: name: attrs:
    if attrs ? ${name} then attrs // { ${name} = f attrs.${name}; } else attrs;

  builtins.mapOptionalAttr =
    default: f: name: attrs:
    attrs // { ${name} = if attrs ? ${name} then f attrs.${name} else default; };

  /**
    Call a function for each attribute in the given set and return the result
    in a list.

    # Inputs

    `f`
    : Function that, given an attribute's name and value,
      returns a new value.

    `attrs`
    : Attribute set to map over.

    # Type

    ```
    builtins.mapAttrsToList :: (n <: String) => (n -> a -> b) -> Attrs n a -> [b]
    ```

    # Examples
    :::{.example}
    ## `builtins.mapAttrsToList` usage example

    ```nix
    builtins.mapAttrsToList (name: value: name + value)
       { x = "a"; y = "b"; }
    => [ "xa" "yb" ]
    ```

    :::
  */
  builtins.mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (attrNames attrs);

  builtins.partitionAttr =
    name: attrs:
    if attrs ? ${name} then
      {
        right = attrs.${name};
        wrong = removeAttr name attrs;
      }
    else
      { wrong = attrs; };

  builtins.partitionOptionalAttr =
    default: name: attrs:
    let
      attrPresent = attrs ? ${name};
    in
    {
      right = if attrPresent then attrs.${name} else default;
      wrong = if attrPresent then removeAttrs attrs [ name ] else attrs;
    };

  /**
    Given a predicate function `pred`,
    this function returns an attrset containing an attrset named `right`,
    containing the attributes in `attrs` for which `pred` returned `true`,
    and an attrset named `wrong`,
    containing the attributes in `attrs` for which `pred` returned `false`.

    # Inputs

    `pred`
    : Predicate function that is given an attribute's name and value.

    `attrs`
    : Attribute set to partition.

    # Type

    ```
    builtins.partitionAttrs :: (n <: String) => (n -> a -> b) -> Attrs n a -> [b]
    ```

    # Examples
    :::{.example}
    ## `builtins.partitionAttrs` usage example

    ```nix
    builtins.partitionAttrs (name: value: value > 10)
       { a = 1; b = 23; c = 9; d = 3; e = 42; }
    => { right = { b = 23; e = 42; }; wrong = { a = 1; c = 9; d = 3; }; }
    ```

    :::
  */
  builtins.partitionAttrs =
    pred: attrs:
    let
      inherit (partition (name: pred name attrs.${name}) (attrNames attrs)) right wrong;
    in
    {
      right = removeAttrs attrs wrong;
      wrong = removeAttrs attrs right;
    };

  builtins.pass = value: f: f value;

  builtins.pipe = functions: value: foldl pass value functions;

  builtins.readDirEntries =
    path:
    mapAttrs (baseName: type: {
      inherit type;
      path = path + "/${baseName}";
    }) (readDir path);

  builtins.readDirEntry = path: {
    inherit path;
    type = readFileType path;
  };

  /**
    Relative complement of attrset `removedAttrs` in attrset `attrs`.
  */
  builtins.relativeComplementAttrs = removedAttrs: attrs:
    filterAttrs (name: value: !(removedAttrs ? ${name})) attrs;

  builtins.removeAttr = name: attrs: if attrs ? ${name} then removeAttrs attrs [ name ] else attrs;

  builtins.removePrefix =
    prefix:
    let
      prefix' =
        if isPath prefix then
          abort ''builtins.removePrefix: The first argument ${escapeNixString (toString prefix)} is a path value, but only strings are supported.''
        else
          prefix;
      prefixLength = stringLength prefix';
      removePrefix =
        str:
        let
          strLength = stringLength str;
          substrLength = strLength - prefixLength;
        in
        if prefixLength <= strLength && substring 0 prefixLength str == prefix' then
          substring prefixLength substrLength str
        else
          null;
    in
    removePrefix;

  builtins.removeSuffix =
    suffix:
    let
      suffix' =
        if isPath suffix then
          abort ''builtins.removeSuffix: The first argument ${escapeNixString (toString suffix)} is a path value, but only strings are supported.''
        else
          suffix;
      suffixLength = stringLength suffix';
      removeSuffix =
        str:
        let
          strLength = stringLength str;
          substrLength = strLength - suffixLength;
        in
        if suffixLength <= strLength && substring substrLength suffixLength str == suffix' then
          substring 0 substrLength str
        else
          null;
    in
    removeSuffix;

  /**
    Difference of attrset `attrs` and `removedAttrs`.
  */
  builtins.subAttrs = attrs: removedAttrs:
    filterAttrs (name: value: !(removedAttrs ? ${name})) attrs;

  /**
    Left-biased attrset union.
  */
  builtins.unionAttrs = newAttrs: attrs: attrs // newAttrs;

  builtins.unsafeGetAttrPos = name: attrs: null;

  /**
    Like `zipAttrsWith`,
    except that the zipped attrs come from the lists from mapping a function
    over an attrset.

    # Inputs

    `valueFunction`
    : Function that, given an attribute's name and values,
      returns a final value.

    `attrsListFunction`
    : Function that, given an attribute's name and value,
      returns a list of attribute sets.

    # Type

    ```
    builtins.zipConcatMapAttrsWith :: (m <: String, n <: String) => (n -> [b] -> c) -> (m -> a -> [Attrs n b]) -> Attrs m a -> Attrs n c
    ```
  */
  builtins.zipConcatMapAttrsWith =
    valueFunction: attrsListFunction: attrs:
    zipAttrsWith valueFunction (concatMapAttrsToList attrsListFunction attrs);

  /**
    Like `zipAttrsWith`,
    except that the zipped attrs come from mapping a function over an attrset.

    # Inputs

    `valueFunction`
    : Function that, given an attribute's name and values,
      returns a final value.

    `attrsFunction`
    : Function that, given an attribute's name and value,
      returns an attribute set.

    # Type

    ```
    builtins.zipMapAttrsWith :: (m <: String, n <: String) => (n -> [b] -> c) -> (m -> a -> Attrs n b) -> Attrs m a -> Attrs n c
    ```
  */
  builtins.zipMapAttrsWith =
    valueFunction: attrsFunction: attrs:
    zipAttrsWith valueFunction (mapAttrsToList attrsFunction attrs);
in
builtins
