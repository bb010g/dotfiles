moduleArgs@{ config, lib, ... }:

let
  inherit (_flakeLib.attrs)
    concatMapAttrs'
    ;
  inherit (_flakeLib.lists)
    optionalNullable
    ;
  # _flakeLib = moduleArgs._flakeLib or (import ../../../../nix/lib/_lib.nix);
  _flakeLib = import ../../../../nix/lib/_lib.nix;
  flakeConfig = moduleArgs.flakeConfig or { };
  flakeFlake = flakeConfig.flake or { };
  flakeHomeManagerModules = flakeFlake.homeManagerModules or { };
in
{
  config = {
    # home-manager.users = concatMapAttrs'
    #   (name: _: optionalNullable flakeHomeManagerModules."configuration-${name}" or null)
    #   config.users.users;
    home-manager.users.bb010g = flakeHomeManagerModules.configuration-bb010g;
  };
}
