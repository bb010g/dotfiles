{ config, lib, pkgs, ... }:

{
  config = {
    home.packages = lib.mkIf config.programs.git.enable [
      pkgs.git-revise
    ];

    programs.git.difftastic.enable = true;
    programs.git.enable = true;
    programs.git.extraConfig.diff.algorithm = "histogram";
    programs.git.extraConfig.merge.conflictStyle = "zdiff3";
    programs.git.extraConfig.url."ssh://git@git.sr.ht/".pushInsteadOf = "https://git.sr.ht/";
    programs.git.extraConfig.url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
    programs.git.extraConfig.url."ssh://git@gitlab.com/".pushInsteadOf = "https://gitlab.com/";
    programs.git.extraConfig.url."ssh://git@gitlab.gnome.org/".pushInsteadOf = "https://gitlab.gnome.org/";
    programs.git.ignores = [
      "*.swp"
      ".direnv"
    ];
    programs.git.lfs.enable = true;
    programs.git.package = pkgs.gitFull;
    programs.git.userEmail = "me@bb010g.com";
    programs.git.userName = "Dusk Banks";
  };
}
