{ config, lib, pkgs, utils, ... }:

let
  inherit (lib)
    escape
    ;
in
{
  escapeUdevString = s: "\"${escape [ "\"" ] s}\"";
}
