{ config, lib, pkgs, ... }:

{
  config = {
    programs.autorandr = {
      enable = true;
      profiles = let
        # TODO: refactor to use modules and `config`
        genProfiles = displays: lib.mapAttrs (name: value: value // {
          fingerprint = lib.mapAttrs' (n: _: {
            name = displays.${n}.output; value = displays.${n}.fingerprint;
          }) value.config;
          config = lib.mapAttrs' (n: v: {
            name = displays.${n}.output; value = displays.${n}.config // v;
          }) value.config;
        });
        # { <profile> = { output = "<name>"; fingerprint = "…"; config = {…}; … }; … }
        displays = import ../private-displays.nix;
      in genProfiles displays {
        mobile.config = {
          laptop = { };
        };
        home-docked.config = {
          laptop = { enable = false; };
          home-docked-vga = { };
          home-docked-dp = { };
        };
        home-hdmi.config = {
          laptop = { };
          home-hdmi = { };
        };
        home-docked-hdmi.config = {
          laptop = { enable = false; };
          home-hdmi = { };
        };
      };
    };
  };
}
