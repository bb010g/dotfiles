{ inputs, nixosModules, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.nix-flatpak.nixosModules.nix-flatpak
    # ({ config, ... }: { config.assertions = [ { assertion = config.nixpkgs.overlays == [ ]; message = "Overlays were provided to Nixpkgs: ${lib.generators.toPretty { allowPrettyValues = true; } config.nixpkgs.overlays}"; } ]; })
    nixosModules.cachix-agent
    nixosModules.home-manager
    nixosModules.home-manager-default
    # nixosModules.impermanence-contrib
    nixosModules.lix
    nixosModules.nix
    nixosModules.nixpkgs
    nixosModules.plasma6
    nixosModules.tuigreet
    nixosModules.udev
    nixosModules.vesktop
  ];
}
