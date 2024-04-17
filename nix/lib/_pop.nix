# NOTE: this isn't POP (Pure Object Prototypes) compliant, but is instead a variation on that theme.
let
  inherit (_lib.lists)
    foldr
    ;
  inherit (_lib.strings)
    escapeNixIdentifier
    ;
  inherit (builtins)
    removeAttrs
    throw
    ;
  _lib = import ./_lib.nix;
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
