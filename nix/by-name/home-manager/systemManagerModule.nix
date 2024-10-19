{ inputs, systemManagerModules, ... }:
{ config, lib, pkgs, utils, ... }:

let
  cfg = config.home-manager;

  serviceEnvironment = lib.optionalAttrs (cfg.backupFileExtension != null) {
    HOME_MANAGER_BACKUP_EXT = cfg.backupFileExtension;
  } // lib.optionalAttrs cfg.verbose { VERBOSE = "1"; } // {
    PATH = lib.mkForce null;
  };
in
{
  imports = [
    (inputs.home-manager + /nixos/common.nix)
    systemManagerModules.i18n
    systemManagerModules.users-groups
  ];

  config = lib.mkMerge [
    {
      home-manager = {
        extraSpecialArgs.systemManagerConfig = config;

        sharedModules = [{
          # # The per-user directory inside /etc/profiles is not known by
          # # fontconfig by default.
          # fonts.fontconfig.enable = lib.mkDefault
          #   (cfg.useUserPackages && config.fonts.fontconfig.enable);

          # Inherit glibcLocales setting from system-manager.
          i18n.glibcLocales = lib.mkDefault config.i18n.glibcLocales;
        }];
      };
    }
    (lib.mkIf (cfg.users != { }) {
      systemd.services = lib.mapAttrs' (_: userCfg:
        let username = userCfg.home.username;
        in lib.nameValuePair ("home-manager-${utils.escapeSystemdPath username}") {
          description = "Home Manager environment for ${username}";
          wantedBy = [ "multi-user.target" ];
          wants = [ "nix-daemon.socket" ];
          after = [ "nix-daemon.socket" ];
          before = [ "systemd-user-sessions.service" ];

          environment = serviceEnvironment;

          unitConfig = { RequiresMountsFor = userCfg.home.homeDirectory; };

          stopIfChanged = false;

          serviceConfig = {
            User = userCfg.home.username;
            Type = "oneshot";
            RemainAfterExit = "yes";
            TimeoutStartSec = "5m";
            SyslogIdentifier = "hm-activate-${username}";

            ExecStart = let
              systemctl =
                "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";

              sed = "${pkgs.gnused}/bin/sed";

              exportedSystemdVariables = lib.concatStringsSep "|" [
                "DBUS_SESSION_BUS_ADDRESS"
                "DISPLAY"
                "WAYLAND_DISPLAY"
                "XAUTHORITY"
                "XDG_RUNTIME_DIR"
              ];

              setupEnv = pkgs.writeScript "hm-setup-env" ''
                #! ${pkgs.runtimeShell} -el

                # The activation script is run by a login shell to make sure
                # that the user is given a sane environment.
                # If the user is logged in, import variables from their current
                # session environment.
                eval "$(
                  ${systemctl} --user show-environment 2> /dev/null \
                  | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
                )"

                exec "$1/activate"
              '';
            in "${setupEnv} ${userCfg.home.activationPackage}";
          };
        }) cfg.users;
    })
  ];
}
