{ homeManagerModules, inputs, ... }:
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.plasma-manager.homeManagerModules.plasma-manager
    homeManagerModules.blesh
    homeManagerModules.direnv
    homeManagerModules.element-desktop
    homeManagerModules.firefox
    homeManagerModules.jujutsu
    homeManagerModules.kdeconnect
    homeManagerModules.neovim
    homeManagerModules.squeezelite
  ];
}
