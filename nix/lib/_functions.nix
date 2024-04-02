let
  inherit (builtins)
    elem
    getEnv
    trace
    ;
  inherit (lib.functions)
    isFunction
    warn
    ;
  builtinIsFunction = builtins.isFunction;
  lib = import ./_lib.nix;
in
{
  isFunction = f: builtinIsFunction f || (f ? __functor && isFunction (f.__functor f));
  toFunction = val: if isFunction val then val else _: val;
  # From <nixpkgs/lib/trivial.nix>
  warn =
    if elem (getEnv "NIX_ABORT_ON_WARN") [ "1" "true" "yes" ] then
      msg: trace "[1;31mwarning: ${msg}[0m"
        (abort "NIX_ABORT_ON_WARN=true; warnings are treated as unrecoverable errors.")
    else
      msg: expr: trace "[1;31mwarning: ${msg}[0m" expr;
  # From <nixpkgs/lib/trivial.nix>
  warnIf =
    cond:
    if cond then
      warn
    else
      msg: expr: expr;
}
