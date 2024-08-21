prevLib: finalLib:
let
  inherit (finalLib.lists) foldr;
  inherit (finalLib.protos) composeProtos identityProto instantiateProto;

  /**
    Compose a child prototype with a parent prototype.

    Composition of morphisms in the category of prototypes.

    # Inputs

    `childProto`
    : The outer prototype, passed the parent value

    `parentProto`
    : The inner prototype, passed the base value

    # Type

    ```
    composeProtos :: Proto b c -> Proto a b -> Proto a c
    ```
  */
  lib.protos.composeProtos =
    childProto: parentProto: base: final:
    childProto (parentProto base final) final;

  /**
    Compose a list of prototypes, sorted parent-first.

    # Inputs

    `protos`
    : List of prototypes

    # Type

    ```
    pipeProtos :: [ (Proto a b) ... (Proto b c) ] -> Proto a c
    ```
  */
  lib.protos.pipeProtos =
    protos:
    foldr (
      parentProto: childProto: composeProtos childProto parentProto
    ) identityProto protos;

  /**
    A prototype that returns the base value.

    The identity morphism in the category of prototypes.

    Implementation note: Identical to `const`.

    # Inputs

    # Type

    ```
    identityProto :: Proto a a
    ```
  */
  lib.protos.identityProto = base: final: base;

  /**
    Instantiate a prototype with a base value.

    # Inputs

    `proto`
    : Prototype to instantiate

    `base`
    : Base value

    # Type

    ```
    instantiateProto :: Proto a b -> a -> b
    ```
  */
  lib.protos.instantiateProto =
    proto: base:
    let
      final = proto base final;
    in
    final;

  /**
    Instantiate an object.

    # Inputs

    `objectMeta`
    : Object `__meta` attribute to instantiate into an object

    `base`
    : Base value

    # Type

    ```
    instantiateObject :: Meta a b -> a -> b
    ```
  */
  lib.protos.instantiateObject =
    objectMeta: base:
    let
      inherit (objectMeta) proto;
      bareFinalObject = proto base finalObject;
      finalObject = bareFinalObject;
    in
    finalObject;
in
prevLib // { protos = prevLib.protos or { } // lib.protos; }
