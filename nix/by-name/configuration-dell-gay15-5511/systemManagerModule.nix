collections@{ homeManagerModules, systemManagerModules, ... }:
{ lib, pkgs, ... }:

let
  inherit (builtins) import;
  inherit (lib) setDefaultModuleLocation;
  importApply = modulePath: staticArg:
    setDefaultModuleLocation modulePath (import modulePath staticArg);
in
{
  imports = [
    systemManagerModules.default
  ];

  config = {
    documentation.dev.enable = true;
    documentation.doc.enable = true;
    documentation.enable = true;
    documentation.info.enable = true;
    documentation.man.enable = true;

    environment.extraOutputsToInstall = [
      "devdoc"
      "devinfo"
      "devman"
      "doc"
      "info"
      "man"
    ];

    environment.pathsToLink = [
      "/share/X11/fonts"

      "/share/emacs"
      "/share/hunspell"

      "/share/nvim"

      "/share/terminfo"

      "/etc/xdg/autostart"

      "/share/icons"
      "/share/pixmaps"

      "/share/applications"
      "/share/desktop-directories"
      "/etc/xdg/menus"
      "/etc/xdg/menus/applications-merged"

      "/share/mime"

      "/share/sounds"

      "/etc/bash_completion.d"
      "/share/bash-completion"

      "/share/fish/vendor_conf.d"
      "/share/fish/vendor_completions.d"
      "/share/fish/vendor_functions.d"

      "/share/X11"

      "/share/zsh"

      "/share/wallpapers"

      "/etc/dbus-1"
      "/share/dbus-1"
    ];

    environment.systemPackages = [
      pkgs.bat
      pkgs.curl
      pkgs.earthly
      pkgs.ed
      pkgs.eza
      pkgs.fd
      pkgs.fsarchiver
      pkgs.libarchive # bsdtar
      pkgs.neovim-unstable
      pkgs.nix
      pkgs.nix-search-cli
      pkgs.partclone
      pkgs.pipx
      pkgs.ripgrep
      pkgs.roswell
      pkgs.zstd
    ];

    environment.variables.EDITOR = "ed";
    environment.variables.VISUAL = "nvim";

    home-manager.useGlobalPkgs = true;
    home-manager.users.bb010g = lib.mkMerge [
      homeManagerModules.configuration-dell-gay15-5511-bb010g or { }
      { config.home.stateVersion = "24.05"; }
    ];

    users.users.bb010g = {
      isNormalUser = true;
    };

    nixpkgs.hostPlatform = "x86_64-linux";

    services.flatpak.enable = true;
    services.flatpak.packages = [
      { appId = "com.bitwarden.desktop"; origin = "flathub"; }
      { appId = "com.quexten.Goldwarden"; origin = "flathub"; }
      { appId = "dev.vencord.Vesktop"; origin = "flathub"; }
      { appId = "io.github.ungoogled_software.ungoogled_chromium"; origin = "flathub"; }
      { appId = "org.DolphinEmu.dolphin-emu"; origin = "flathub-beta"; }
      { appId = "org.mozilla.firefox"; origin = "flathub"; }
      { appId = "org.signal.Signal"; origin = "flathub"; }
    ];

    system-graphics.enable = true;

    system-manager.allowAnyDistro = true;
  };
}
