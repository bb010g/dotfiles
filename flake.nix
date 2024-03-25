{
  description = "woah NixOS configuration";

  nixConfig.extra-substituters = "https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence-contrib.inputs.impermanence.follows = "impermanence";
  inputs.impermanence-contrib.inputs.nixpkgs.follows = "nixpkgs";
  inputs.impermanence-contrib.url = "github:rehno-lindeque/nixos-impermanence";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.systems.flake = false;
  inputs.systems.url = "github:nix-systems/default";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (
    { config, getSystem, inputs, lib, options, self, ... }:
    let
      flakeConfig = config;
      flakeOptions = options;
      importModules = imports: { inherit imports; };
    in
    {
      imports = [
      ];
      config.flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          config.flake.nixosModules.configuration-nixos
        ];
        specialArgs = { inherit self inputs; };
      };
      # replicated in configuration.nix
      config.flake.nixosModules.configuration-nixos = importModules [
        inputs.disko.nixosModules.disko
        inputs.impermanence.nixosModules.impermanence
        # Include the portable parts of the configuration.
        config.flake.nixosModules.default
        # Include the disk partitioning and formatting.
        config.flake.nixosModules.default-disk
        # Include the results of the hardware scan.
        config.flake.nixosModules.default-hardware
      ];
      config.flake.nixosModules.default = ./portable-configuration.nix;
      config.flake.nixosModules.default-disk = ./disk-configuration.nix;
      config.flake.nixosModules.default-disko = ./disko-configuration.nix;
      config.flake.nixosModules.default-hardware = ./hardware-configuration.nix;
      config.systems = import inputs.systems;
    }
  );
}
# vim: set sta et sw=2 ts=8:
