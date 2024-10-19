{ inputs, ... }:
{ config, lib, ... }:
let
  cfg = config.services.flatpak;
in
{
  imports = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  options = {
    services.flatpak = {
      enable = lib.mkEnableOption "Flatpak";
    };
  };
}
