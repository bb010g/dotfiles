let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:
let nur = srcs.nur { inherit pkgs; }; in

{
  imports = [
    nur.modules.bb010g.home-manager.programs.pijul
  ];

  config = {
    programs.pijul = {
      enable = true;
      # configDir = "${config.xdg.configHome}/pijul";
      package = nixpkgs-unstable.pijul;
      global = {
        author = "bb010g <me@bb010g.com>";
        signing_key = "/home/bb010g/.config/pijul/config/signing_secret_key";
      };
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
