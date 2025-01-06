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
    environment.extraOutputsToInstall = [
      "devdoc"
      "devinfo"
      "devman"
      "doc"
      "info"
      "man"
    ];

    environment.systemPackages = [
      pkgs.bat
      pkgs.curl
      pkgs.eza
      pkgs.fd
      pkgs.libarchive # bsdtar
      pkgs.neovim-unstable
      pkgs.nix
      pkgs.nix-search-cli
      pkgs.pipx
      pkgs.ripgrep
      pkgs.roswell
      pkgs.zstd
    ];

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
