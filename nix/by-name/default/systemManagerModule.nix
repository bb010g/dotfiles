{ inputs, systemManagerModules, ... }:
{
  imports = [
    inputs.nix-system-graphics.systemModules.default
    systemManagerModules.flatpak
    systemManagerModules.home-manager
    systemManagerModules.home-manager-default
    systemManagerModules.i18n
    systemManagerModules.nix
    systemManagerModules.users-groups
  ];
}
