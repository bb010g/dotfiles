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
    environment.systemPackages = [
      (lib.getBin pkgs.bat)
      (lib.getBin pkgs.curl)
      (lib.getBin pkgs.eza)
      (lib.getBin pkgs.fd)
      (lib.getBin pkgs.libarchive) # bsdtar
      (lib.getBin pkgs.neovim-unstable)
      pkgs.nix
      (lib.getBin pkgs.nix-search-cli)
      (lib.getBin pkgs.pipx)
      (lib.getBin pkgs.ripgrep)
      (lib.getBin pkgs.roswell)
      (lib.getBin pkgs.zstd)
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

    system-manager.allowAnyDistro = true;
  };
}
