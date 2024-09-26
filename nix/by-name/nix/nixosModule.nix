{ ... }:
{ lib, ... }:

{
  config = {
    nix.settings.show-trace = lib.mkDefault true;
  };
}
