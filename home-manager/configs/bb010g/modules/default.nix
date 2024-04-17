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

    programs.bat.enable = true;

    programs.eza.enable = true;

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
