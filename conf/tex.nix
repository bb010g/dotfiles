{ config, lib, pkgs, ... }:

{
  config = {
    home.packages = [
      pkgs.texstudio
    ];

    programs.texlive = {
      enable = true;
      # for sane combine
      # TODO(bb010g): Upstream this!
      packageSet = pkgs.nur.pkgs.bb010g.texlive;
      extraPackages = tpkgs: {
        pkgFilter = let inherit (lib) any elem id; in p: any id [
          (p.tlType == "run" || p.tlType == "bin")
          (p.tlType == "doc" && !(elem p.pname [
            # avoid collisions with texlive-bin-YYYY-doc
            "aleph"
            "autosp"
            "latex-bin"
            "synctex"
          ]))
          (p.pname == "core")
        ];
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
