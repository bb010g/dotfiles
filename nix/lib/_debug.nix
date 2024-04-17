let
  inherit (_lib.debug)
    warn
    ;
  inherit (builtins)
    elem
    getEnv
    trace
    ;
  _lib = import ./_lib.nix;
in
{
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
