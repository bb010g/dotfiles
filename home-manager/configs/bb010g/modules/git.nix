{ config, lib, pkgs, ... }:

{
  config = {
    home.packages = lib.mkIf config.programs.git.enable [
      pkgs.git-dive
      pkgs.git-revise
      pkgs.git-stack
    ];

    programs.git.difftastic.enable = true;
    programs.git.enable = true;
    # <ansiColor>: black, red, green, yellow, blue, magenta, cyan, white
    # <color>: normal, #<rrggbb>, <ansiColor>, default, bright<ansiColor>, <256-color>
    # <basicAttribute>: bold, dim, italic, ul, blink, reverse, strike
    # <attribute>: <basicAttribute>, no<basicAttribute>, no-<basicAttribute>
    # <colorWord>: reset, <color>, <attribute>
    # <slot> = [reset] [<foreground color> [<background color>]] [<attribute>]…
    programs.git.extraConfig.color.branch = {
      reset = "reset"; # (reset)
      plain = "normal normal"; # (normal)
      remote = "red normal"; # (red)
      local = "normal normal"; # (normal)
      current = "green normal bold"; # (green)
      upstream = "yellow normal"; # (blue)
      worktree = "cyan normal"; # (cyan)
    };
    programs.git.extraConfig.column.branch = "auto column dense";
    programs.git.extraConfig.commit.cleanup = "scissors";
    programs.git.extraConfig.clone.defaultRemoteName = "m";
    programs.git.extraConfig.diff.algorithm = "histogram";
    programs.git.extraConfig.fetch.fsckObjects = true;
    programs.git.extraConfig.fetch.showForcedUpdates = true;
    programs.git.extraConfig.init.defaultBranch = "d/main";
    programs.git.extraConfig.merge.conflictStyle = "zdiff3";
    programs.git.extraConfig.receive.fsckObjects = true;
    programs.git.extraConfig.transfer.fsckObjects = true;
    programs.git.extraConfig.url."ssh://git@git.sr.ht/".pushInsteadOf = "https://git.sr.ht/";
    programs.git.extraConfig.url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
    programs.git.extraConfig.url."ssh://git@gitlab.com/".pushInsteadOf = "https://gitlab.com/";
    programs.git.extraConfig.url."ssh://git@gitlab.gnome.org/".pushInsteadOf = "https://gitlab.gnome.org/";
    programs.git.ignores = [
      "*.swp"
      ".direnv"
    ];
    programs.git.includes = [
      { path = "maintenance-repos.inc.gitconfig"; }
    ];
    programs.git.lfs.enable = true;
    programs.git.package = pkgs.gitFull;
    programs.git.userEmail = "me@bb010g.com";
    programs.git.userName = "Dusk Banks";
  };
}
