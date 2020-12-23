let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:

let
  inherit (srcs)
    nixpkgs-unstable
  ;
in
{
  config = {
    home.packages = let
      # deal with buggy libredirect glibc linking (it shouldn't be linked)
      sublime-merge = let sublime-mergeRelPath =
        "/pkgs/applications/version-management/sublime-merge";
      in (pkgs.callPackage (nixpkgs-unstable.path + sublime-mergeRelPath) {
      }).sublime-merge.overrideAttrs (o: {
        installPhase =
          let regex = "(makeWrapper [^\n]*)"; in
          lib.concatStrings (lib.concatMap (matches:
            if !(lib.isList matches) then [ matches ] else
              matches ++ [ " --argv0 '$0'" ]
          ) (builtins.split regex o.installPhase));
      });
      sublime_merge = "${sublime-merge}/bin/sublime_merge";
      sublime-merge-tool = pkgs.writeShellScriptBin "smergetool"
        ''exec -a smerge ${lib.escapeShellArg sublime_merge} mergetool "$@"'';
    in [
      pkgs.gitAndTools.git-crypt
      pkgs.gitAndTools.git-imerge
      pkgs.nur.pkgs.bb010g.gitAndTools.git-my
      pkgs.nur.pkgs.bb010g.gitAndTools.git-revise
      sublime-merge
      sublime-merge-tool
    ];

    programs.git = {
      enable = true;
      extraConfig = {
        core = {
          commentChar = "auto";
        };
        diff = {
          algorithm = "histogram";
          submodule = "log";
        };
        github = {
          user = "bb010g";
        };
        merge = {
          tool = "smerge";
        };
        mergetool = {
          smerge = {
            cmd = ''smerge mergetool "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'';
            trustExitCode = "true";
          };
        };
        push = {
          recurseSubmodules = "check";
        };
        status = {
          submoduleSummary = "true";
          showStash = "true";
        };
      };
      lfs = {
        enable = true;
      };
      package = pkgs.gitAndTools.gitFull;
      userEmail = "me@bb010g.com";
      userName = "Dusk Banks";
    };

    xdg = {
      configFile = {
        "git/ignore".source = ../gitignore_global;
      };
    };
  };
}
