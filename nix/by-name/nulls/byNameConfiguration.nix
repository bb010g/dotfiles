byName@{ lib, ... }:
{ ... }:
let
  inherit (lib.filesystem) import;
in
{
  collections.libProtos.entryBaseNames."lib.nix".import = { ... }: { ... }: { path, ... }: import path;
}
