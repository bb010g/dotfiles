{ ... }:
{ config, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (lib.options) mkOption;
  inherit (lib.strings) stringLength;
  cfg = config.users;
in
{
  options = {
    users.users = mkOption {
      description = ''
        Additional user accounts to be created automatically by the system.
        This can also be used to set options for root.
      '';
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        options = {
          createHome = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Whether to create the home directory and ensure ownership as well as
              permissions to match the user.
            '';
          };

          home = mkOption {
            type = types.passwdEntry types.path;
            default = "/var/empty";
            description = "The user's home directory.";
          };

          homeMode = mkOption {
            type = types.strMatching "[0-7]{1,5}";
            default = "700";
            description = "The user's home directory mode in numeric format. See chmod(1). The mode is only applied if {option}`users.users.<name>.createHome` is true.";
          };

          isNormalUser = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Indicates whether this is an account for a “real” user.
              This automatically sets {option}`group` to `users`,
              {option}`createHome` to `true`,
              {option}`home` to {file}`/home/«username»`,
              {option}`useDefaultShell` to `true`,
              and {option}`isSystemUser` to `false`.
              Exactly one of `isNormalUser` and `isSystemUser` must be true.
            '';
          };

          isSystemUser = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Indicates if the user is a system user or not. This option
              only has an effect if {option}`uid` is
              {option}`null`, in which case it determines whether
              the user's UID is allocated in the range for system users
              (below 1000) or in the range for normal users (starting at
              1000).
              Exactly one of `isNormalUser` and
              `isSystemUser` must be true.
            '';
          };

          name = mkOption {
            type = types.passwdEntry types.str;
            apply = x: assert (stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"); x;
            description = ''
              The name of the user account.
              If undefined,
              the name of the attribute set will be used.
            '';
          };
        };
        config = mkMerge [
          {
            name = mkDefault name;
          }
          (mkIf config.isNormalUser {
            # group = mkDefault "users";
            createHome = mkDefault true;
            home = mkDefault "/home/${config.name}";
            homeMode = mkDefault "700";
            # useDefaultShell = mkDefault true;
            isSystemUser = mkDefault false;
          })
        ];
      }));
      default = { };
      example = {
        alice = {
          uid = 1234;
          description = "Alice Q. User";
          home = "/home/alice";
          createHome = true;
          group = "users";
          extraGroups = ["wheel"];
          shell = "/bin/sh";
        };
      };
    };

    users.groups = mkOption {
      description = ''
        Additional groups to be created automatically by the system.
      '';
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        name = mkOption {
          type = types.passwdEntry types.str;
          description = ''
            The name of the group.
            If undefined,
            the name of the attribute set will be used.
          '';
        };
      }));
      default = { };
      example = {
        students.gid = 1001;
        hackers = { };
      };
    };
  };
}
