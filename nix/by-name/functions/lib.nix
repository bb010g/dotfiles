prevLib: finalLib:
let
  inherit (builtins)
    ;
  inherit (finalLib.functions)
    flip2
    flip1_1
    flip1_1_1
    flip1_1_1_1
    flip1_1_1_1_1
    flip1_1_1_1_1_1
    isFunction
    ;
  builtinIsFunction = builtins.isFunction;
in
{
  # TODO(bb010g): source generation for `/flip\d+(_\d+)+/`
  flip = flip2;
  flip1 = f: a: f a;
  flip1_1 = f: b: a: f a b;
  flip1_1_1 = f: c: b: a: f a b c;
  flip1_1_1_1 = f: d: c: b: a: f a b c d;
  flip1_1_1_1_1 = f: e: d: c: b: a: f a b c d e;
  flip1_1_1_1_1_1 = f: i: e: d: c: b: a: f a b c d e i;
  flip1_1_2 = f: c: d: b: a: f a b c d;
  flip1_1_2_1 = f: e: c: d: b: a: f a b c d e;
  flip1_1_2_2 = f: e: i: c: d: b: a: f a b c d e i;
  flip1_1_3 = f: c: d: e: b: a: f a b c d e;
  flip1_1_4 = f: c: d: e: i: b: a: f a b c d e i;
  flip1_2 = f: b: c: a: f a b c;
  flip1_2_1 = f: d: b: c: a: f a b c d;
  flip1_2_1_1 = f: e: d: b: c: a: f a b c d e;
  flip1_2_1_1_1 = f: i: e: d: b: c: a: f a b c d e i;
  flip1_2_2 = f: d: e: b: c: a: f a b c d e;
  flip1_2_2_1 = f: i: d: e: b: c: a: f a b c d e i;
  flip1_2_3 = f: d: e: i: b: c: a: f a b c d e i;
  flip1_3 = f: b: c: d: a: f a b c d;
  flip1_4 = f: b: c: d: e: a: f a b c d e;
  flip1_5 = f: b: c: d: e: i: a: f a b c d e i;
  flip2 = flip1_1;
  flip2_1 = f: c: a: b: f a b c;
  flip2_2 = f: c: d: a: b: f a b c d;
  flip2_3 = f: c: d: e: a: b: f a b c d e;
  flip2_4 = f: c: d: e: i: a: b: f a b c d e i;
  flip3 = flip1_1_1;
  flip3_1 = f: d: a: b: c: f a b c d;
  flip3_2 = f: d: e: a: b: c: f a b c d e;
  flip3_3 = f: d: e: i: a: b: c: f a b c d e i;
  flip4 = flip1_1_1_1;
  flip5 = flip1_1_1_1_1;
  flip6 = flip1_1_1_1_1_1;
  # From <nixpkgs/lib/trivial.nix>
  isFunction = f: builtinIsFunction f || (f ? __functor && isFunction (f.__functor f));
  mapNullable = f: val: if val != null then f val else null;
  # From <nixpkgs/lib/trivial.nix>
  toFunction = val: if isFunction val then val else _: val;
}
