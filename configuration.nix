# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, modulesPath, ... }:

let
  fromEnv = import (modulesPath + "/../lib/from-env.nix");
  nixosConfigDir = builtins.dirOf nixosConfigPath;
  nixosConfigPath = fromEnv "NIXOS_CONFIG" <nixos-config>;
  self = import ./default.nix;
in
{
  imports = [
    # self.nixosModules.configuration-nixos
    self.inputs.disko.nixosModules.disko
    self.inputs.disko.nixosModules.impermanence
    # Include the portable parts of the configuration.
    ./portable-configuration.nix
    # Include the disk partitioning and formatting.
    ./disk-configuration.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  config = {
    system.extraSystemBuilderCmds = lib.optionalString config.system.copySystemConfiguration ''
      ln -s ${lib.escapeShellArg (nixosConfigDir + "/flake.nix")} "$out/flake.nix"
      ln -s ${lib.escapeShellArg (nixosConfigDir + "/flake.lock")} "$out/flake.lock"
      ln -s ${lib.escapeShellArg (nixosConfigDir + "/default.nix")} "$out/default.nix"'';
  };
}
# vim: set sta et sw=2 ts=8:
