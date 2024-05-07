moduleArgs@{ lib, pkgs, ... }:

let
  flakeConfig = moduleArgs.flakeConfig or null;
in
{
  config = {
    home.homeDirectory = "/home/bb010g";

    home.packages = [
      pkgs.bitwarden-cli # Bitwarden
      pkgs.bitwarden-desktop # Bitwarden
      pkgs.firefox # Web
      pkgs.neochat # Matrix
      pkgs.obsidian # Obsidian
      pkgs.sublime-merge # Git
      pkgs.telegram-desktop # Telegram
    ];

    home.username = "bb010g";

    programs.atuin.enable = true;
    programs.atuin.settings.update_check = false;
    programs.atuin.settings = {
      dialect = "us";
      dotfiles.enabled = false;
      exit_mode = "return-query";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
      search_mode = "skim";
      search_mode_shell_up_key_binding = "prefix";
      style = "compact";
      sync.records = true;
      workspaces = true;
    };

    programs.bat.enable = true;

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

    programs.zellij.enable = true;
    programs.zellij.enableBashIntegration = true;

    # Discord (via Vesktop)
    services.arrpc.enable =
      if flakeConfig != null then
        flakeConfig.programs.vesktop.enable
      else
        lib.mkDefault false;
  };
}
