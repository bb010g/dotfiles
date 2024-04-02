let
  inherit (builtins)
    isPath
    map
    match
    replaceStrings
    stringLength
    substring
    throw
    toJSON
    ;
  inherit (lib.strings)
    escape
    escapeNixString
    validateSubstring
    ;
  lib = import ./_lib.nix;
in
{
  escape = builtins.escape or (
    let
      escape = list: replaceStrings list (map (c: "\\${c}") list);
    in
    escape
  );
  escapeNixIdentifier = builtins.escapeNixIdentifier or (
    let
      escapeNixIdentifier = s:
        # Regex from https://github.com/NixOS/nix/blob/d048577909e383439c2549e849c5c2f2016c997e/src/libexpr/lexer.l#L91
        if match "[a-zA-Z_][a-zA-Z0-9_'-]*" s != null then
          s
        else
          escapeNixString s;
    in
    escapeNixIdentifier
  );
  escapeNixString = builtins.escapeNixString or (
    let
      escapeNixString = s: escape ["$"] (toJSON s);
    in
    escapeNixString
  );
  hasPrefix =
    prefix:
    let
      prefix' = validateSubstring (msg: "bb010g-lib.strings.hasPrefix: The first argument ${msg}") prefix;
      prefixLength = stringLength prefix';
    in
    str:
    let
      strLength = stringLength str;
    in
    prefixLength <= strLength && substring 0 prefixLength str == prefix';
  hasSuffix =
    suffix:
    let
      suffix' = validateSubstring (msg: "bb010g-lib.strings.hasSuffix: The first argument ${msg}") suffix;
      suffixLength = stringLength suffix';
    in
    str:
    let
      strLength = stringLength str;
      substrLength = strLength - suffixLength;
    in
    suffixLength <= strLength && substring substrLength suffixLength str == suffix';
  removePrefix =
    prefix:
    let
      prefix' = validateSubstring (msg: "bb010g-lib.strings.removePrefix: The first argument ${msg}") prefix;
      prefixLength = stringLength prefix';
    in
    str:
    let
      strLength = stringLength str;
      substrLength = strLength - prefixLength;
    in
    if prefixLength <= strLength && substring 0 prefixLength str == prefix' then
      substring prefixLength substrLength str
    else
      null;
  removeSuffix =
    suffix:
    let
      suffix' = validateSubstring (msg: "bb010g-lib.strings.removeSuffix: The first argument ${msg}") suffix;
      suffixLength = stringLength suffix';
    in
    str:
    let
      strLength = stringLength str;
      substrLength = strLength - suffixLength;
    in
    if suffixLength <= strLength && substring substrLength suffixLength str == suffix' then
      substring 0 substrLength str
    else
      null;
  validateSubstring =
    msgFn:
    substr:
    if isPath substr then
      throw (msgFn
        ''${escapeNixString (toString substr)} is a path value, but only strings are supported.''
      )
    else
      substr;
}
