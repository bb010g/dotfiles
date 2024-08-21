{ ... }:
prevLib: finalLib:
let
  inherit (finalLib.functions)
    flip2
    flip1_1
    flip1_1_1
    flip1_1_1_1
    flip1_1_1_1_1
    flip1_1_1_1_1_1
    isFunction
    ;
  # TODO(bb010g): source generation for `/flip\d+(_\d+)+/`
  lib.functions.flip = flip2;
  lib.functions.flip1 = f: a: f a;
  lib.functions.flip1_1 = f: b: a: f a b;
  lib.functions.flip1_1_1 = f: c: b: a: f a b c;
  lib.functions.flip1_1_1_1 = f: d: c: b: a: f a b c d;
  lib.functions.flip1_1_1_1_1 = f: e: d: c: b: a: f a b c d e;
  lib.functions.flip1_1_1_1_1_1 = f: i: e: d: c: b: a: f a b c d e i;
  lib.functions.flip1_1_2 = f: c: d: b: a: f a b c d;
  lib.functions.flip1_1_2_1 = f: e: c: d: b: a: f a b c d e;
  lib.functions.flip1_1_2_2 = f: e: i: c: d: b: a: f a b c d e i;
  lib.functions.flip1_1_3 = f: c: d: e: b: a: f a b c d e;
  lib.functions.flip1_1_4 = f: c: d: e: i: b: a: f a b c d e i;
  lib.functions.flip1_2 = f: b: c: a: f a b c;
  lib.functions.flip1_2_1 = f: d: b: c: a: f a b c d;
  lib.functions.flip1_2_1_1 = f: e: d: b: c: a: f a b c d e;
  lib.functions.flip1_2_1_1_1 = f: i: e: d: b: c: a: f a b c d e i;
  lib.functions.flip1_2_2 = f: d: e: b: c: a: f a b c d e;
  lib.functions.flip1_2_2_1 = f: i: d: e: b: c: a: f a b c d e i;
  lib.functions.flip1_2_3 = f: d: e: i: b: c: a: f a b c d e i;
  lib.functions.flip1_3 = f: b: c: d: a: f a b c d;
  lib.functions.flip1_4 = f: b: c: d: e: a: f a b c d e;
  lib.functions.flip1_5 = f: b: c: d: e: i: a: f a b c d e i;
  lib.functions.flip2 = flip1_1;
  lib.functions.flip2_1 = f: c: a: b: f a b c;
  lib.functions.flip2_2 = f: c: d: a: b: f a b c d;
  lib.functions.flip2_3 = f: c: d: e: a: b: f a b c d e;
  lib.functions.flip2_4 = f: c: d: e: i: a: b: f a b c d e i;
  lib.functions.flip3 = flip1_1_1;
  lib.functions.flip3_1 = f: d: a: b: c: f a b c d;
  lib.functions.flip3_2 = f: d: e: a: b: c: f a b c d e;
  lib.functions.flip3_3 = f: d: e: i: a: b: c: f a b c d e i;
  lib.functions.flip4 = flip1_1_1_1;
  lib.functions.flip5 = flip1_1_1_1_1;
  lib.functions.flip6 = flip1_1_1_1_1_1;
  lib.functions.toFunction = val: if isFunction val then val else _: val;
in
prevLib // { functions = prevLib.functions or { } // lib.functions; }
