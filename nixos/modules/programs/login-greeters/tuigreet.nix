{ config, lib, options, pkgs, ... }:

let
  inherit (_lib.attrs)
    concatMapAttrsToList
    ;
  inherit (builtins)
    map
    typeOf
    ;
  inherit (lib)
    concatStringsSep
    escapeShellArg
    isFloat
    isInt
    isString
    literalExpression
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;
  inherit (lib.generators)
    toPretty
    ;
  _lib = import ../../../../nix/lib/_lib.nix;
  cfg = config.programs.loginGreeters.tuigreet;
  displayManagerCfg = config.services.displayManager;
  displayManagerOpts = options.services.displayManager;
  moduleConfig = config;
  moduleOptions = options;
  opts = options.programs.loginGreeters.tuigreet;
in
{
  options = {
    programs.loginGreeters.tuigreet = {
      enable = mkEnableOption "tuigreet, a graphical console greeter for greetd";

      package = mkPackageOption pkgs [ "greetd" "tuigreet" ] { };

      command.command = mkOption {
        type = types.either types.str types.path;
        default = cfg.package + "/bin/tuigreet";
        defaultText = literalExpression ''${opts.package} + "/bin/tuigreet"'';
        description = "The path of the executable for running tuigreet.";
      };

      command.settings = mkOption {
        type = types.submodule ({ config, options, ... }: {
          freeformType = types.attrsOf (types.either types.bool (types.nullOr types.str));

          options.cmd = mkOption {
            type = types.nullOr (types.either types.str types.path);
            default = null;
            example = literalExpression
              ''lib.escapeShellArg "sway --config ''${lib.escapeShellArg swayConfig}"'';
            description = ''
              POSIX shell command for the default free-form session command.
              Note that this option value is unquoted & unescaped POSIX shell code.
            '';
          };

          options.session-wrapper = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Wrapper command for running Wayland sessions.
              Note that this option value is unquoted & unescaped POSIX shell code.
            '';
          };

          options.sessions = mkOption {
            type = types.nullOr types.envVar;
            default = null;
            example = literalExpression
              '''''''${lib.escapeShellArg (${moduleOptions.system.path} + "/share")}''''';
            description = ''
              Colon-separated list of Wayland session paths.
              Defaults to `$XDG_DATA_DIR/wayland-sessions`
              for each `$XDG_DATA_DIR` in {env}`XDG_DATA_DIRS`.
              Note that this option value is unquoted & unescaped POSIX shell code.
            '';
          };

          options.xsession-wrapper = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Wrapper command for running X11 sessions.
              Note that this option value is unquoted & unescaped POSIX shell code.
            '';
          };

          options.xsessions = mkOption {
            type = types.nullOr types.envVar;
            default = null;
            example = literalExpression
              '''''''${lib.escapeShellArg (${moduleOptions.system.path} + "/share")}''''';
            description = ''
              Colon-separated list of X11 session paths.
              Defaults to `$XDG_DATA_DIR/xsessions`
              for each `$XDG_DATA_DIR` in {env}`XDG_DATA_DIRS`.
              Note that this option value is unquoted & unescaped POSIX shell code.
            '';
          };

          options.width = mkOption {
            type = types.nullOr (types.either types.ints.positive types.str);
            default = null;
            example = 80;
            description = "The width of the main prompt.";
          };

          options.remember = mkEnableOption
            "remembering the last logged-in username";

          options.remember-session = mkEnableOption
            "remembering the last selected session";

          options.remember-user-session = mkEnableOption
            "remembering the last selected session for each user";

          options.user-menu = mkEnableOption
            "graphical selection of users from a menu";

          options.user-menu-min-uid = mkOption {
            type = types.nullOr (types.either types.ints.positive types.str);
            # `pkg-config --variable=system_uid_max systemd` + 1
            default = 1000;
            example = literalExpression
              ''${moduleOptions.security.loginDefs.settings.SYS_UID_MAX} + 1'';
            description = ''
              The minimum UID to display in the user selection menu.
              The default is systemd's maximum system UID (999) + 1.
            '';
          };

          options.user-menu-max-uid = mkOption {
            type = types.nullOr (types.either types.ints.positive types.str);
            # systemd homed max UID
            default = 60513;
            example = 60000;
            description = ''
              The maximum UID to display in the user selection menu.
              The defaults is systemd's last human UID (60513),
              which is greater than systemd's last regular UID (60000).
            '';
          };

          options.asterisks = mkEnableOption
            "redacting secrets when they're typed with characters";

          options.asterisks-char = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "*";
            description = ''
              The characters to redact secrets with when they're typed.
            '';
          };
        });
        description = ''
          The command-line options for running tuigreet.
          Unless otherwise stated, each boolean option is a long switch,
          each string or null option is a long keyed option,
          and each keyed option value is unquoted & unescaped POSIX shell code
          that MUST expand to one shell word.
        '';
      };

      command.extraArgs = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = ''
          Extra POSIX shell arguments for running tuigreet.
          A POSIX shell MUST expand each list element to one shell word.
        '';
      };

      command.args = mkOption {
        type = types.listOf types.str;
        internal = true;
        default =
          concatMapAttrsToList
            (
              longOptionName: optionValue:
              if isString optionValue then
                [ "--${escapeShellArg longOptionName}" optionValue ]
              else if isInt optionValue || isFloat optionValue then
                [ "--${escapeShellArg longOptionName}" (escapeShellArg (toString optionValue)) ]
              else if optionValue == true then
                [ "--${escapeShellArg longOptionName}" ]
              else if optionValue == false || optionValue == null then
                [ ]
              else
                throw "unexpected ${opts.command.settings} option value of type ${typeOf optionValue}: ${toPretty { } optionValue}"
            )
            cfg.command.settings ++
          cfg.command.extraArgs;
      };
    };
  };
  config = mkMerge [
    (mkIf displayManagerCfg.enable {
      programs.loginGreeters.tuigreet.command.settings.sessions = escapeShellArg
        (displayManagerCfg.sessionData.desktops + "/share/wayland-sessions");
      programs.loginGreeters.tuigreet.command.settings.xsessions = escapeShellArg
        (displayManagerCfg.sessionData.desktops + "/share/xsessions");
    })
    (mkIf cfg.enable (mkMerge [
      {
        services.greetd.enable = mkDefault true;
        services.greetd.settings.default_session.command = mkDefault (
          concatStringsSep " " ([ (escapeShellArg cfg.command.command) ] ++ cfg.command.args)
        );
      }
      (mkIf displayManagerCfg.enable {
        # # TODO: support for default session
        # programs.loginGreeters.tuigreet.command.settings.default-session =
        #   mkIf (displayManagerCfg.defaultSession != null) (
        #     mkDefault (escapeShellArg displayManagerCfg.defaultSession)
        #   );
        # # TODO: support for dynamic user discovery
        # # TODO: support for hiding users
        # programs.loginGreeters.tuigreet.command.settings.hidden-users =
        #   mkDefault (map escapeShellArg displayManagerCfg.hiddenUsers);
        programs.loginGreeters.tuigreet.command.settings.xsession-wrapper =
          mkDefault (escapeShellArg displayManagerCfg.sessionData.wrapper);
        systemd.services.display-manager.enable = mkDefault false;
        systemd.services.greetd.environment = displayManagerCfg.environment;
      })
      # feature request for autologin with sessions:
      # https://github.com/apognu/tuigreet/issues/118
      (mkIf (displayManagerCfg.enable && displayManagerCfg.autoLogin.enable) {
        assertions = [
          {
            assertion = cfg.command.settings.cmd != null;
            msg = ''
              tuigreet auto-login requires that ${opts.command.settings.cmd} is not null.
            '';
          }
          {
            assertion = displayManagerCfg.autoLogin.user != null;
            msg = ''
              tuigreet auto-login requires that ${displayManagerOpts.autoLogin.user} is not null.
            '';
          }
        ];
        services.greetd.settings.initial_session.command = mkDefault cfg.command.settings.cmd;
        services.greetd.settings.initial_session.user = mkDefault displayManagerCfg.autoLogin.user;
      })
    ]))
  ];
  meta.maintainers = [ lib.maintainers.bb010g ];
}
