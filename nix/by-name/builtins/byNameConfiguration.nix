byName@{ lib, ... }:
{ ... }:
let
  inherit (lib.filesystem) import;
in
{
  collections.lib.entries.lib.suffixes.".nix".import = { ... }: { ... }: { path, ... }: import path;
}
