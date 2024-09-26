{ homeManagerModules, nixosModules, ... }:
nixosModuleArgs@{ config, lib, options, pkgs, ... }:
{
  imports = [
    nixosModules.home-manager
  ];
  config = {
    home-manager.sharedModules = [ homeManagerModules.default ];
    home-manager.extraSpecialArgs = {
      inherit nixosModuleArgs;
      # nixosConfig = config; # already passed by home-manager
      nixosLib = lib;
      nixosOptions = options;
      nixosPkgs = pkgs;
    };
  };
}
