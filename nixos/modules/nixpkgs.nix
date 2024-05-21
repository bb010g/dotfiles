{ config, inputs ? { }, lib, ... }:

let
  neovimInput = inputs.neovim or null;
in
{
  config = {
    nixpkgs.overlays = [
      (import ../../pkgs/by-name/ne/neovim/overlay.nix)
      (import ../../pkgs/by-name/ne/neovim-stable/overlay.nix)
    ] ++ lib.optionals (neovimInput != null) [
      (import ../../pkgs/by-name/ne/neovim-unstable/overlay.nix { inherit inputs; })
    ];
  };
}
