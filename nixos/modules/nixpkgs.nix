{ config, flakeConfig, lib, ... }:

{
  config = {
    nixpkgs.overlays = [
      flakeConfig.flake.overlays.neovim
      flakeConfig.flake.overlays.neovim-stable
      flakeConfig.flake.overlays.neovim-unstable
    ];
  };
}
