collections@{ homeManagerModules, ... }:
{ config, lib, nixosConfig ? null, pkgs, systemConfig ? null, ... }:

let
  inherit (builtins) import;
  inherit (lib) setDefaultModuleLocation;
  importApply = modulePath: staticArg:
    setDefaultModuleLocation modulePath (import modulePath staticArg);
in
{
  imports = [
    homeManagerModules.default
  ];

  config = {
    home.homeDirectory = "/home/bb010g";

    home.packages = [
      (lib.getBin pkgs.git-branchless)
      (lib.getBin pkgs.git-dive)
      (lib.getBin pkgs.git-octopus)
      (lib.getBin pkgs.git-revise)
      (lib.getBin pkgs.git-stack)
      (lib.getBin pkgs.kdotool)
      (lib.getBin pkgs.nix-search-cli)
    ];

    home.preferXdgDirectories = true;

    # https://hexdocs.pm/mix/1.17.2/Mix.html
    home.sessionVariables.MIX_XDG = "1";
    home.sessionVariables.SSH_AUTH_SOCK = "\${SSH_AUTH_SOCK:-$HOME/.var/app/com.quexten.Goldwarden/data/ssh-auth-sock}";

    home.username = "bb010g";

    programs.atuin.enable = true;
    programs.atuin.settings.update_check = false;
    programs.atuin.settings = {
      dialect = "us";
      dotfiles.enabled = false;
      exit_mode = "return-query";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
      local_timeout = 10; # default: 5
      search_mode = "skim";
      search_mode_shell_up_key_binding = "prefix";
      style = "compact";
      sync.records = true;
      workspaces = true;
    };

    programs.bash.enable = true;
    programs.bash.bashrcExtra = ''
      # Source global definitions
      if [ -f /etc/bashrc ]; then
          . /etc/bashrc
      fi
    '';
    programs.bash.historyControl = [ "ignorespace" ];

    programs.bat.enable = true;

    programs.blesh.enable = true;

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    programs.eza.enable = true;

    programs.foot.enable = true;
    programs.foot.settings = {
      key-bindings.font-decrease = "Control+Alt+minus Control+Alt+KP_Subtract";
      key-bindings.font-increase = "Control+Alt+plus Control+Alt+KP_Add";
      key-bindings.font-reset = "Control+Alt+equal Control+Alt+KP_Enter";
      key-bindings.primary-paste = "Control+Shift+Insert";
      key-bindings.scrollback-down-page = "Control+Alt+Page_Down";
      key-bindings.scrollback-up-page = "Control+Alt+Page_Up";
      key-bindings.spawn-terminal = "none";
      main.dpi-aware = "yes";
      main.font = "monospace:size=10";
      scrollback.lines = 10000;
    };

    # version control (CLI)
    programs.git.difftastic.enable = true;
    programs.git.enable = true;
    programs.git.extraConfig = {
      commit.cleanup = "scissors";
      diff.algorithm = "histogram";
      fetch.fsckObjects = true;
      fetch.showForcedUpdates = true;
      init.defaultBranch = "main";
      merge.conflictStyle = "zdiff3";
      receive.fsckObjects = true;
      url."ssh://bb010g@gerrit.lix.systems:2022/".pushInsteadOf = "https://gerrit.lix.systems/";
      url."ssh://git@git.lix.systems/".pushInsteadOf = "https://git.lix.systems/";
      url."ssh://git@git.sr.ht/".pushInsteadOf = "https://git.sr.ht/";
      url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
      url."ssh://git@gitlab.com/".pushInsteadOf = "https://gitlab.com/";
      url."ssh://git@gitlab.gnome.org/".pushInsteadOf = "https://gitlab.gnome.org/";
    };
    programs.git.ignores = [
      # Vim
      "*.swp"
    ];
    programs.git.lfs.enable = true;
    programs.git.package = pkgs.gitFull;
    programs.git.userEmail = "me@bb010g.com";
    programs.git.userName = "Dusk Banks";
    programs.gitui.enable = true;

    programs.jujutsu.enable = true;
    programs.jujutsu.settings.user.email = config.programs.git.userEmail;
    programs.jujutsu.settings.user.name = config.programs.git.userName;

    programs.zellij.enable = true;

    # Discord (via Vesktop)
    services.arrpc.enable = lib.mkIf (nixosConfig != null) nixosConfig.programs.vesktop.enable;

    services.squeezelite.enable = true;
    services.squeezelite.audioBackend.pulseAudio.enable = true;
    services.squeezelite.extraArgs = "-s banks-media.mouse-grue.ts.net -W";

    systemd.user.startServices = "sd-switch";
  };
}
