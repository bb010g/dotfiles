# NOTE: this isn't POP (Pure Object Prototypes) compliant, but is instead a variation on that theme.
{ ... }:
prevLib: finalLib:
let
  inherit (finalLib.attrs)
    removeAttrs
    ;
  inherit (finalLib.evaluation)
    throw
    ;
  inherit (finalLib.lists)
    foldr
    ;
  inherit (finalLib.pop)
    composeProto
    extendObj'
    extendObj''
    getMeta
    getProtoOfMeta
    identityProto
    mapMeta
    setDefaultNameOfMeta
    setNameOfMeta
    ;
  inherit (finalLib.strings)
    escapeNixIdentifier
    ;
  lib.pop.composeProto = this: parent: final: prev: this final (parent final prev);
  lib.pop.composeProtos = foldr composeProto identityProto;
  lib.pop.extensionToProto = extension: final: prev: prev // extension final prev;
  lib.pop.getMeta = obj: obj.__meta or {
    base = { };
    proto = final: prev: prev // obj;
    name = "attrs";
  };
  lib.pop.getProto = obj: getProtoOfMeta (getMeta obj);
  lib.pop.getProtoOfMeta = meta: meta.proto or (throw "getProto can't handle object ${
    if meta ? name then escapeNixIdentifier meta.name else "<unknown>"
  }");
  lib.pop.getTopProtoOfMeta = meta: final: prev: prev // { __meta = meta; };
  lib.pop.extendObj = proto: obj: extendObj' null proto obj;
  lib.pop.extendObj' = extendObj'' (meta: meta);
  lib.pop.extendObj'' = metaF: hookProto: proto: obj:
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
      obj' = bareObj // { __meta = metaF (bareObj.__meta or { } // {
        base = base;
        proto = proto';
        ${if hookProto' != null then "hookProto" else null} = hookProto';
      }); };
    in obj';
  lib.pop.hookObj = hookProto: obj: extendObj' hookProto null obj;
  lib.pop.identityProto = final: prev: prev;
  lib.pop.identityExtension = final: prev: { };
  lib.pop.instantiateProto = proto: prev: let final = proto final prev; in final;
  lib.pop.instantiateObj = proto: base:
    let
      bareObj = proto obj base;
      obj = bareObj // {
        __meta = bareObj.__meta or { } // { inherit base proto; };
      };
    in obj;
  lib.pop.mapMeta = f: obj: obj // { __meta = f (getMeta obj); };
  lib.pop.removeMeta = obj: removeAttrs obj [ "__meta" ];
  lib.pop.setDefaultName = name: mapMeta (setDefaultNameOfMeta name);
  lib.pop.setDefaultNameOfMeta = defaultName: meta: meta // { name = meta.name or defaultName; };
  lib.pop.setName = name: mapMeta (setNameOfMeta name);
  lib.pop.setNameOfMeta = name: meta: meta // { inherit name; };
in
prevLib // { pop = prevLib.pop or { } // lib.pop; }
