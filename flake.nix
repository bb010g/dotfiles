{
  description = "woah NixOS configuration";

  nixConfig.extra-substituters = "https://cache.lix.systems https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.url = "github:nix-community/disko";
  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-utils.inputs.systems.follows = "systems";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flakey-profile.url = "github:lf-/flakey-profile";
  inputs.gitignore.inputs.nixpkgs.follows = "nixpkgs";
  inputs.gitignore.url = "github:hercules-ci/gitignore.nix";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  # inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.url = "github:bb010g/nix-impermanence/f/method";
  inputs.impermanence-contrib.inputs.impermanence.follows = "impermanence";
  inputs.impermanence-contrib.inputs.nixpkgs.follows = "nixpkgs";
  inputs.impermanence-contrib.url = "github:rehno-lindeque/nixos-impermanence";
  inputs.lix-module.inputs.flake-utils.follows = "flake-utils";
  inputs.lix-module.inputs.flakey-profile.follows = "flakey-profile";
  inputs.lix-module.inputs.lix.follows = "lix";
  inputs.lix-module.inputs.nixpkgs.follows = "nixpkgs";
  inputs.lix-module.url = "git+https://git.lix.systems/lix-project/nixos-module.git";
  inputs.lix.flake = false;
  inputs.lix.url = "git+https://git.lix.systems/lix-project/lix.git";
  inputs.neovim.flake = false;
  inputs.neovim.url = "github:neovim/neovim";
  inputs.nix-flatpak.url = "github:gmodena/nix-flatpak";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  inputs.nixpkgs.url = "github:bb010g/nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
  inputs.plasma-manager.inputs.home-manager.follows = "home-manager";
  inputs.plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.plasma-manager.url = "github:pjones/plasma-manager";
  inputs.pre-commit-hooks-nix.inputs.flake-compat.follows = "flake-compat";
  inputs.pre-commit-hooks-nix.inputs.gitignore.follows = "gitignore";
  inputs.pre-commit-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.pre-commit-hooks-nix.inputs.nixpkgs-stable.follows = "nixpkgs-stable";
  inputs.pre-commit-hooks-nix.url = "github:cachix/pre-commit-hooks.nix";
  inputs.systems.flake = false;
  inputs.systems.url = "github:nix-systems/default";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./flake-module.nix;
}
# vim: set sta et sw=2 ts=8:
