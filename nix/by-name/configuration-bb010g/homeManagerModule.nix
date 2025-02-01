collections@{ homeManagerModules, ... }:
{ lib, nixosConfig ? null, pkgs, ... }:

let
  inherit (builtins) import;
  inherit (lib) setDefaultModuleLocation;
  importApply = modulePath: staticArg:
    setDefaultModuleLocation modulePath (import modulePath staticArg);
in
{
  imports = [
    homeManagerModules.default
    homeManagerModules.vscode-bb010g
    (importApply ./_homeManagerModules/firefox.nix collections)
    (importApply ./_homeManagerModules/git.nix collections)
    (importApply ./_homeManagerModules/graphical.nix collections)
    (importApply ./_homeManagerModules/plasma.nix collections)
  ];

  config = {
    home.homeDirectory = "/home/bb010g";

    home.packages = [
      pkgs.beeper # instant messenger (Beeper client, GUI)
      pkgs.bitwarden-cli # password manager (Bitwarden client, CLI)
      pkgs.bitwarden-desktop # password manager (Bitwarden client, GUI)
      pkgs.iamb # instant messenger (Matrix client, TUI)
      # pkgs.neochat # instant messenger (Matrix client, GUI)
      pkgs.obsidian # information manager (text files, GUI)
      pkgs.signal-desktop # instant messenger (Signal client, GUI)
      pkgs.sublime-merge # version control (Git, GUI)
      pkgs.telegram-desktop # instant messenger (Telegram client, GUI)
    ];

    # https://hexdocs.pm/mix/1.17.2/Mix.html
    home.sessionVariables.MIX_XDG = "1";

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

    programs.bat.enable = true;

    # instant messenger (Matrix client, GUI)
    programs.element-desktop.enable = true;
    programs.element-desktop.desktopEntry.enableWayland = true;

    programs.eza.enable = true;

    # web browser (GUI)
    programs.firefox.enable = true;

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
    programs.git.enable = true;

    programs.zellij.enable = true;

    # Discord (via Vesktop)
    services.arrpc.enable = lib.mkIf (nixosConfig != null) nixosConfig.programs.vesktop.enable;

    services.kdeconnect.enable = lib.mkDefault true;
    services.kdeconnect.indicator = lib.mkDefault true;

    services.squeezelite.enable = true;
    services.squeezelite.audioBackend.pulseAudio.enable = true;
    services.squeezelite.extraArgs = "-s banks-media.mouse-grue.ts.net -W";

    systemd.user.startServices = "sd-switch";
  };
}
