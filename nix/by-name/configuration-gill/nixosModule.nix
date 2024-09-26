collections@{ nixosModules, ... }:
{ config, lib, ... }:

let
  inherit (builtins) import;
  inherit (lib) setDefaultModuleLocation;
  importApply = modulePath: staticArg:
    setDefaultModuleLocation modulePath (import modulePath staticArg);
in
{
  imports = [
    nixosModules.configuration-workstation
    nixosModules.impermanence-contrib
    (importApply ./_nixosModules/disk.nix collections)
    ./_nixosModules/disko.nix
    (importApply ./_nixosModules/hardware.nix collections)
  ];
  config = {
    home-manager.users.bb010g.config.home.stateVersion = "23.11";

    networking.hostName = "gill"; # Define your hostname. Resurrection.

    # # Can't enable yet due to user-level PipeWire.
    # services.squeezelite.enable = true;

    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    system.stateVersion = "23.11"; # Did you read the comment?

    users.users.bb010g.linger = true;
  };
}
