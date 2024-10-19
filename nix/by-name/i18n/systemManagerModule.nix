{ systemManagerModules, ... }:
{ config, lib, pkgs, ... }:
let
  cfg = config.i18n;

  glibcLocaleArchivePath = "${cfg.glibcLocales}/lib/locale/locale-archive";

  # lookup the version of glibcLocales and set the appropriate environment vars
  LOCALE_ARCHIVE_VERSIONED =
    if lib.versionAtLeast cfg.glibcLocales.version "2.27" then
      "LOCALE_ARCHIVE_2_27"
    else if lib.versionAtLeast cfg.glibcLocales.version "2.11" then
      "LOCALE_ARCHIVE_2_11"
    else
      null;

  localeVars = if lib.versionAtLeast cfg.glibcLocales.version "2.27" then {
    LOCALE_ARCHIVE_2_27 = glibcLocaleArchivePath;
  } else if lib.versionAtLeast cfg.glibcLocales.version "2.11" then {
    LOCALE_ARCHIVE_2_11 = glibcLocaleArchivePath;
  } else
    { };
in
{
  imports = [
    systemManagerModules.environment
  ];

  options = {
    i18n = {
      glibcLocales = lib.mkOption {
        type = lib.types.path;
        default = pkgs.glibcLocales.override {
          allLocales = lib.any (x: x == "all") config.i18n.supportedLocales;
          locales = config.i18n.supportedLocales;
        };
        defaultText = lib.literalExpression ''
          pkgs.glibcLocales.override {
            allLocales = lib.any (x: x == "all") config.i18n.supportedLocales;
            locales = config.i18n.supportedLocales;
          }
        '';
        example = lib.literalExpression "pkgs.glibcLocales";
        description = ''
          Customized pkg.glibcLocales package.

          Changing this option can disable handling of i18n.defaultLocale
          and supportedLocale.
        '';
      };

      defaultLocale = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "en_US.UTF-8";
        description = ''
          The default locale.  It determines the language for program
          messages, the format for dates and times, sort order, and so on.
          It also determines the character set, such as UTF-8.
        '';
      };

      extraLocaleSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        example = { LC_MESSAGES = "en_US.UTF-8"; LC_TIME = "de_DE.UTF-8"; };
        description = ''
          A set of additional system-wide locale settings other than
          `LANG` which can be configured with
          {option}`i18n.defaultLocale`.
        '';
      };

      supportedLocales = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = if cfg.defaultLocale == null then [ "all" ] else lib.unique
          (builtins.map (l: (lib.replaceStrings [ "utf8" "utf-8" "UTF8" ] [ "UTF-8" "UTF-8" "UTF-8" ] l) + "/UTF-8") (
            [
              "C.UTF-8"
              "en_US.UTF-8"
              cfg.defaultLocale
            ] ++ (lib.attrValues (lib.filterAttrs (n: v: n != "LANGUAGE") config.i18n.extraLocaleSettings))
          ));
        defaultText = lib.literalExpression ''
          if config.i18n.defaultLocale == null then [ "all" ] else lib.unique
            (builtins.map (l: (lib.replaceStrings [ "utf8" "utf-8" "UTF8" ] [ "UTF-8" "UTF-8" "UTF-8" ] l) + "/UTF-8") (
              [
                "C.UTF-8"
                "en_US.UTF-8"
                config.i18n.defaultLocale
              ] ++ (lib.attrValues (lib.filterAttrs (n: v: n != "LANGUAGE") config.i18n.extraLocaleSettings))
            ))
        '';
        example = ["en_US.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" "nl_NL/ISO-8859-1"];
        description = ''
          List of locales that the system should support.  The value
          `"all"` means that all locales supported by
          Glibc will be installed.  A full list of supported locales
          can be found at <https://sourceware.org/git/?p=glibc.git;a=blob;f=localedata/SUPPORTED>.
        '';
      };
    };
  };

  config = {
    environment.systemPackages = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.i18n.supportedLocales != []) [
      # We increase the priority a little, so that plain glibc in systemPackages can't win.
      (lib.setPrio (-1) config.i18n.glibcLocales)
    ];

    environment.sessionVariables = lib.mkMerge [
      (lib.mkIf (cfg.defaultLocale != null) {
        LANG = cfg.defaultLocale;
      })
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux ({
        LOCALE_ARCHIVE = "/run/system-manager/sw/lib/locale/locale-archive";
      } // config.i18n.extraLocaleSettings))
    ];

    systemd.globalEnvironment = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.i18n.supportedLocales != []) {
      LOCALE_ARCHIVE = glibcLocaleArchivePath;
      ${LOCALE_ARCHIVE_VERSIONED} = glibcLocaleArchivePath;
    };

    # ‘/etc/locale.conf’ is used by systemd.
    environment.etc."locale.conf" = lib.mkIf (cfg.defaultLocale != null || config.i18n.extraLocaleSettings != { }) {
      text = ''
        ${if config.i18n.defaultLocale == null then "" else ''
          LANG=${config.i18n.defaultLocale}
        ''}${lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: "${n}=${v}") config.i18n.extraLocaleSettings)}
      '';
    };
  };
}
