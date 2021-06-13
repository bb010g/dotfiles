{ config, lib, pkgs, ... }:

{
  options = {
    programs.texlive = {
      package = lib.mkOption {
        type = lib.types.package;
        # TODO(bb010g): This is an immensely dirty bodge.
        readOnly = false;
      };
    };
  };

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

      package = lib.mkForce (let
        cfg = config.programs.texlive;
        texlive = cfg.packageSet;
        texlivePkgs = cfg.extraPackages texlive;
      in (texlive.combine texlivePkgs).override (super: {
        paths = let
          pathsSuper = super.paths or [ ];
          inherit (builtins) match storeDir;
          inherit (lib) isStorePath partition removePrefix substring;
          removeStoreAndHashPrefix = p: substring 34 (-1) (removePrefix storeDir p);
          isTlBinDoc = p: isStorePath p && match "texlive-bin-[0-9]{4}-doc(/.*)?" (removeStoreAndHashPrefix p) != null;
          rightThenWrong = { right, wrong, ... }: right ++ wrong;
        in rightThenWrong (partition isTlBinDoc pathsSuper);
        ignoreCollisions = true;
      }));
    };
  };
}
