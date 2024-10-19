{ homeManagerModules, systemManagerModules, ... }:
systemManagerModuleArgs@{ config, lib, options, pkgs, ... }:
{
  imports = [
    systemManagerModules.home-manager
  ];
  config = {
    home-manager.sharedModules = [ homeManagerModules.default ];
    home-manager.extraSpecialArgs = {
      inherit systemManagerModuleArgs;
      # systemManagerConfig = config; # already passed by system-manager
      systemManagerLib = lib;
      systemManagerOptions = options;
      systemManagerPkgs = pkgs;
    };
  };
}
