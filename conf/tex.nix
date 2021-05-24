{ config, lib, pkgs, ... }:

{
  config = {
    home.packages = [
      pkgs.texstudio
    ];

    programs.texlive = {
      enable = true;
      packageSet = pkgs.texlive;
      extraPackages = tpkgs: {
        pkgFilter = p: p.tlType == "run" || p.tlType == "bin" || p.tlType == "doc" || p.pname == "core";
        inherit (tpkgs)
          collection-bibtexextra
          collection-context
          collection-fontsextra
          collection-formatsextra
          collection-games
          collection-humanities
          collection-latexextra
          collection-luatex
          collection-mathscience
          collection-music
          collection-pictures
          collection-pstricks
          collection-publishers
          latexmk
          scheme-small
          scheme-tetex
        ;
      };
    };
  };
}
