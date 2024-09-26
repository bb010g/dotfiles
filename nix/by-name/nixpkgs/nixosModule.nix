{ nixpkgsOverlays, ... }:
{
  config = {
    nixpkgs.overlays = [
      # inputs.lix-module.overlays.default
      nixpkgsOverlays.neovim
      nixpkgsOverlays.neovim-stable
      nixpkgsOverlays.neovim-unstable
    ];
  };
}
