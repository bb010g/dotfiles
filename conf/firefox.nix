let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:

let
  inherit (srcs)
    sources-ext
  ;
in
{
  config = {
    home.packages = [
      # for Firefox MozLz4a JSON files (.jsonlz4)
      pkgs.nur.pkgs.bb010g.mozlz4-tool
    ];

    programs.firefox = {
      enable = true;
      package = ((pkgs.nur.lib.mozilla.firefoxOverlay.firefoxVersion {
        name = "Firefox Nightly";
        # https://product-details.mozilla.org/1.0/firefox_versions.json
        #  : FIREFOX_NIGHTLY
        inherit (sources-ext.firefox-nightly) version;
        # system: ? arch (if stdenv.system == "i686-linux" then "linux-i686" else "linux-x86_64")
        # https://download.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-${version}.en-US.${system}.buildhub.json
        #  : download -> url -> (parse)
        #  - https://archive.mozilla.org/pub/firefox/nightly/%Y/%m/%Y-%m-%d-%H-%m-%s-mozilla-central/firefox-${version}.en-US.${system}.tar.bz2
        #  : build -> date -> (parse) also works
        #  - %Y-%m-%dT%H:%m:%sZ
        #  need %Y-%m-%d-%H-%m-%s
        inherit (sources-ext.firefox-nightly) timestamp;
        release = false;
      }).overrideAttrs (o: {
        buildCommand = lib.replaceStrings [ ''
          --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
        '' ] [ ''
          --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
          --set SNAP_NAME firefox \
        '' ] o.buildCommand;
      }));
      # https://github.com/NixOS/nixpkgs/issues/59276
      # enableAdobeFlash = true;
    };
  };
}
