{ inputs, systemManagerModules, ... }:
{
  imports = [
    systemManagerModules.environment
    systemManagerModules.flatpak
    systemManagerModules.home-manager
    systemManagerModules.home-manager-default
    systemManagerModules.i18n
    systemManagerModules.nix
    systemManagerModules.users-groups
  ];
}
