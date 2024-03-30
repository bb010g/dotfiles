let
  inherit (builtins) elemAt length map match removeAttrs replaceStrings toJSON;
  escape = builtins.escape or (let
    escape = list: replaceStrings list (map (c: "\\${c}") list);
  in escape);
  escapeNixIdentifier = builtins.escapeNixIdentifier or (let
    escapeNixIdentifier = s:
      # Regex from https://github.com/NixOS/nix/blob/d048577909e383439c2549e849c5c2f2016c997e/src/libexpr/lexer.l#L91
      if match "[a-zA-Z_][a-zA-Z0-9_'-]*" s != null
      then s else escapeNixString s;
  in escapeNixIdentifier);
  escapeNixString = builtins.escapeNixString or (let
    escapeNixString = s: escape ["$"] (toJSON s);
  in escapeNixString);
  foldr = builtins.foldr or (let
    foldr = op: nul: list: let
      len = length list;
      foldlAt = n: if n == len then nul else
        op (elemAt list n) (foldlAt (n + 1));
    in foldlAt 0;
  in foldr);
in rec {
  composeProto = this: parent: final: prev: this final (parent final prev);
  composeProtos = foldr composeProto identityProto;
  extensionToProto = extension: final: prev: prev // extension final prev;
  getMeta = obj: obj.__meta__ or {
    base = { };
    proto = final: prev: prev // obj;
    name = "attrs";
  };
  getProto = obj: getProtoOfMeta (getMeta obj);
  getProtoOfMeta = meta: meta.proto or (throw "getProto can't handle object ${
    if meta ? name then escapeNixIdentifier meta.name else "<unknown>"
  }");
  getTopProtoOfMeta = meta: final: prev: prev // { __meta__ = meta; };
  extendObj = proto: obj: extendObj' null proto obj;
  extendObj' = extendObj'' (meta: meta);
  extendObj'' = metaF: hookProto: proto: obj:
    let
      bareMeta = getMeta obj;
      base = bareMeta.base;
      hookProto' = if hookProto != null then
        if bareMeta ? hookProto then composeProto hookProto bareMeta.hookProto else hookProto
      else
        bareMeta.hookProto or null;
      proto' = if proto != null then composeProto proto bareMeta.proto else bareMeta.proto;
      hookedProto = if hookProto' != null then
        if proto' != null then composeProto proto' hookProto' else hookProto'
      else
        if proto' != null then proto' else identityProto;
      bareObj = hookedProto obj' base;
      obj' = bareObj // { __meta__ = metaF (bareObj.__meta__ or { } // {
        base = base;
        proto = proto';
        ${if hookProto' != null then "hookProto" else null} = hookProto';
      }); };
    in obj';
  hookObj = hookProto: obj: extendObj' hookProto null obj;
  identityProto = final: prev: prev;
  identityExtension = final: prev: { };
  instantiateProto = proto: prev: let final = proto final prev; in final;
  instantiateObj = proto: base:
    let
      bareObj = proto obj base;
      obj = bareObj // {
        __meta__ = bareObj.__meta__ or { } // { inherit base proto; };
      };
    in obj;
  mapMeta = f: obj: obj // { __meta__ = f (getMeta obj); };
  removeMeta = obj: removeAttrs obj [ "__meta__" ];
  setDefaultName = name: mapMeta (setDefaultNameOfMeta name);
  setDefaultNameOfMeta = defaultName: meta: meta // { name = meta.name or defaultName; };
  setName = name: mapMeta (setNameOfMeta name);
  setNameOfMeta = name: meta: meta // { inherit name; };
}
