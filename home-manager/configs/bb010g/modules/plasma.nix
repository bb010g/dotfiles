{ config, lib, pkgs, ... }:

let
  defaultActivity = "c7f489a1-5c20-4e1c-8e8d-d0e24db7f92c";
  enablePolonium = false;
in
{
  config = {
    programs.plasma.enable = true;
    programs.plasma.shortcuts = lib.mkMerge [
      {
        "ActivityManager"."switch-to-activity-${defaultActivity}" = [ ];
        "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = [ /*"Meta+Alt+L"*/ ];
        "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = [ /*"Meta+Alt+K"*/ ];
        "kaccess"."Toggle Screen Reader On and Off" = [ "Meta+Alt+S" ];
        "kcm_touchpad"."Disable Touchpad" = [ "Touchpad Off" ];
        "kcm_touchpad"."Enable Touchpad" = [ "Touchpad On" ];
        "kcm_touchpad"."Toggle Touchpad" = [ "Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku" ];
        "kmix"."decrease_microphone_volume" = [ "Microphone Volume Down" ];
        "kmix"."decrease_volume" = [ "Volume Down" ];
        "kmix"."decrease_volume_small" = [ "Shift+Volume Down" ];
        "kmix"."increase_microphone_volume" = [ "Microphone Volume Up" ];
        "kmix"."increase_volume" = [ "Volume Up" ];
        "kmix"."increase_volume_small" = [ "Shift+Volume Up" ];
        "kmix"."mic_mute" = [ "Microphone Mute" "Meta+Volume Mute" ];
        "kmix"."mute" = [ "Volume Mute" ];
        "ksmserver"."Halt Without Confirmation" = [ ];
        "ksmserver"."Lock Session" = [ "Screensaver" "Meta+Shift+E" ];
        "ksmserver"."Log Out" = [ "Ctrl+Alt+Del" ];
        "ksmserver"."Log Out Without Confirmation" = [ ];
        "ksmserver"."Reboot" = [ ];
        "ksmserver"."Reboot Without Confirmation" = [ ];
        "ksmserver"."Shut Down" = [ ];
        "kwin"."Activate Window Demanding Attention" = [ "Meta+Ctrl+A" ];
        "kwin"."Cube" = [ ];
        "kwin"."Cycle Overview" = [ ];
        "kwin"."Cycle Overview Opposite" = [ ];
        "kwin"."Decrease Opacity" = [ ];
        "kwin"."Edit Tiles" = [ "Meta+T" ];
        "kwin"."Expose" = [ ];
        "kwin"."ExposeAll" = [ ];
        "kwin"."ExposeClass" = [ ];
        "kwin"."ExposeClassCurrentDesktop" = [ ];
        "kwin"."Grid View" = [ ];
        "kwin"."Increase Opacity" = [ ];
        "kwin"."Kill Window" = [ "Meta+Ctrl+Esc" ];
        "kwin"."Move Tablet to Next Output" = [ ];
        "kwin"."MoveMouseToCenter" = [ "Meta+F6" ];
        "kwin"."MoveMouseToFocus" = [ "Meta+F5" ];
        "kwin"."MoveZoomDown" = [ ];
        "kwin"."MoveZoomLeft" = [ ];
        "kwin"."MoveZoomRight" = [ ];
        "kwin"."MoveZoomUp" = [ ];
        "kwin"."Overview" = [ "Meta+W" ];
        "kwin"."Setup Window Shortcut" = [ ];
        "kwin"."Show Desktop" = [ ];
        "kwin"."Switch One Desktop Down" = [ ];
        "kwin"."Switch One Desktop Up" = [ ];
        "kwin"."Switch One Desktop to the Left" = [ ];
        "kwin"."Switch One Desktop to the Right" = [ ];
        "kwin"."Switch Window Down" = [ "Meta+Alt+Down" ];
        "kwin"."Switch Window Left" = [ "Meta+Alt+Left" ];
        "kwin"."Switch Window Right" = [ "Meta+Alt+Right" ];
        "kwin"."Switch Window Up" = [ "Meta+Alt+Up" ];
        "kwin"."Switch to Desktop 1" = [ "Meta+1" ];
        "kwin"."Switch to Desktop 2" = [ "Meta+2" ];
        "kwin"."Switch to Desktop 3" = [ "Meta+3" ];
        "kwin"."Switch to Desktop 4" = [ "Meta+4" ];
        "kwin"."Switch to Desktop 5" = [ "Meta+5" ];
        "kwin"."Switch to Desktop 6" = [ "Meta+6" ];
        "kwin"."Switch to Desktop 7" = [ "Meta+7" ];
        "kwin"."Switch to Desktop 8" = [ "Meta+8" ];
        "kwin"."Switch to Desktop 9" = [ "Meta+9" ];
        "kwin"."Switch to Desktop 10" = [ "Meta+0" ];
        "kwin"."Switch to Desktop 11" = [ ];
        "kwin"."Switch to Desktop 12" = [ ];
        "kwin"."Switch to Desktop 13" = [ ];
        "kwin"."Switch to Desktop 14" = [ ];
        "kwin"."Switch to Desktop 15" = [ ];
        "kwin"."Switch to Desktop 16" = [ ];
        "kwin"."Switch to Desktop 17" = [ ];
        "kwin"."Switch to Desktop 18" = [ ];
        "kwin"."Switch to Desktop 19" = [ ];
        "kwin"."Switch to Desktop 20" = [ ];
        "kwin"."Switch to Next Desktop" = [ ];
        "kwin"."Switch to Next Screen" = [ ];
        "kwin"."Switch to Previous Desktop" = [ ];
        "kwin"."Switch to Previous Screen" = [ ];
        "kwin"."Switch to Screen 0" = [ ];
        "kwin"."Switch to Screen 1" = [ ];
        "kwin"."Switch to Screen 2" = [ ];
        "kwin"."Switch to Screen 3" = [ ];
        "kwin"."Switch to Screen 4" = [ ];
        "kwin"."Switch to Screen 5" = [ ];
        "kwin"."Switch to Screen 6" = [ ];
        "kwin"."Switch to Screen 7" = [ ];
        "kwin"."Switch to Screen Above" = [ ];
        "kwin"."Switch to Screen Below" = [ ];
        "kwin"."Switch to Screen to the Left" = [ ];
        "kwin"."Switch to Screen to the Right" = [ ];
        "kwin"."Toggle" = [ ]; # Toggle Show Paint
        "kwin"."Toggle Night Color" = [ ]; # Toggle Night Light
        "kwin"."Toggle Window Raise/Lower" = [ ];
        "kwin"."Walk Through Windows" = [ "Meta+Tab" ];
        "kwin"."Walk Through Windows (Reverse)" = [ "Meta+Shift+Tab" ];
        "kwin"."Walk Through Windows Alternative" = [ ];
        "kwin"."Walk Through Windows Alternative (Reverse)" = [ ];
        "kwin"."Walk Through Windows of Current Application" = [ ];
        "kwin"."Walk Through Windows of Current Application (Reverse)" = [ ];
        "kwin"."Walk Through Windows of Current Application Alternative" = [ ];
        "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
        "kwin"."Window Above Other Windows" = [ ];
        "kwin"."Window Below Other Windows" = [ ];
        "kwin"."Window Close" = [ "Meta+Shift+Q" ];
        "kwin"."Window Fullscreen" = [ "Meta+F" ];
        "kwin"."Window Grow Horizontal" = [ ];
        "kwin"."Window Grow Vertical" = [ ];
        "kwin"."Window Lower" = [ ];
        "kwin"."Window Maximize" = [ "Meta+PgUp" ];
        "kwin"."Window Maximize Horizontal" = [ ];
        "kwin"."Window Maximize Vertical" = [ ];
        "kwin"."Window Minimize" = [ "Meta+PgDown" ];
        "kwin"."Window Move" = [ ];
        "kwin"."Window Move Center" = [ ];
        "kwin"."Window No Border" = [ ];
        "kwin"."Window On All Desktops" = [ ];
        "kwin"."Window One Desktop Down" = [ ];
        "kwin"."Window One Desktop Up" = [ ];
        "kwin"."Window One Desktop to the Left" = [ ];
        "kwin"."Window One Desktop to the Right" = [ ];
        "kwin"."Window One Screen Down" = [ ];
        "kwin"."Window One Screen Up" = [ ];
        "kwin"."Window One Screen to the Left" = [ ];
        "kwin"."Window One Screen to the Right" = [ ];
        "kwin"."Window Operations Menu" = [ "Meta+Q" ];
        "kwin"."Window Pack Down" = [ ];
        "kwin"."Window Pack Left" = [ ];
        "kwin"."Window Pack Right" = [ ];
        "kwin"."Window Pack Up" = [ ];
        "kwin"."Window Quick Tile Bottom" = [ ];
        "kwin"."Window Quick Tile Bottom Left" = [ ];
        "kwin"."Window Quick Tile Bottom Right" = [ ];
        "kwin"."Window Quick Tile Left" = [ ];
        "kwin"."Window Quick Tile Right" = [ ];
        "kwin"."Window Quick Tile Top" = [ ];
        "kwin"."Window Quick Tile Top Left" = [ ];
        "kwin"."Window Quick Tile Top Right" = [ ];
        "kwin"."Window Raise" = [ ];
        "kwin"."Window Resize" = [ ];
        "kwin"."Window Shade" = [ ];
        "kwin"."Window Shrink Horizontal" = [ ];
        "kwin"."Window Shrink Vertical" = [ ];
        "kwin"."Window to Desktop 1" = [ "Meta+Shift+1" "Meta+!" ];
        "kwin"."Window to Desktop 2" = [ "Meta+Shift+2" "Meta+@" ];
        "kwin"."Window to Desktop 3" = [ "Meta+Shift+3" "Meta+#" ];
        "kwin"."Window to Desktop 4" = [ "Meta+Shift+4" "Meta+$" ];
        "kwin"."Window to Desktop 5" = [ "Meta+Shift+5" "Meta+%" ];
        "kwin"."Window to Desktop 6" = [ "Meta+Shift+6" "Meta+^" ];
        "kwin"."Window to Desktop 7" = [ "Meta+Shift+7" "Meta+&" ];
        "kwin"."Window to Desktop 8" = [ "Meta+Shift+8" "Meta+*" ];
        "kwin"."Window to Desktop 9" = [ "Meta+Shift+9" "Meta+(" ];
        "kwin"."Window to Desktop 10" = [ "Meta+Shift+0" "Meta+)" ];
        "kwin"."Window to Desktop 11" = [ ];
        "kwin"."Window to Desktop 12" = [ ];
        "kwin"."Window to Desktop 13" = [ ];
        "kwin"."Window to Desktop 14" = [ ];
        "kwin"."Window to Desktop 15" = [ ];
        "kwin"."Window to Desktop 16" = [ ];
        "kwin"."Window to Desktop 17" = [ ];
        "kwin"."Window to Desktop 18" = [ ];
        "kwin"."Window to Desktop 19" = [ ];
        "kwin"."Window to Desktop 20" = [ ];
        "kwin"."Window to Next Desktop" = [ ];
        "kwin"."Window to Next Screen" = [ ];
        "kwin"."Window to Previous Desktop" = [ ];
        "kwin"."Window to Previous Screen" = [ ];
        "kwin"."Window to Screen 0" = [ ];
        "kwin"."Window to Screen 1" = [ ];
        "kwin"."Window to Screen 2" = [ ];
        "kwin"."Window to Screen 3" = [ ];
        "kwin"."Window to Screen 4" = [ ];
        "kwin"."Window to Screen 5" = [ ];
        "kwin"."Window to Screen 6" = [ ];
        "kwin"."Window to Screen 7" = [ ];
        "kwin"."view_actual_size" = [ "Meta+=" ];
        "kwin"."view_zoom_in" = [ "Meta++" ];
        "kwin"."view_zoom_out" = [ "Meta+-" ];
        "mediacontrol"."mediavolumedown" = [ ];
        "mediacontrol"."mediavolumeup" = [ ];
        "mediacontrol"."nextmedia" = [ "Media Next" ];
        "mediacontrol"."pausemedia" = [ "Media Pause" ];
        "mediacontrol"."playmedia" = [ ];
        "mediacontrol"."playpausemedia" = [ "Media Play" ];
        "mediacontrol"."previousmedia" = [ "Media Previous" ];
        "mediacontrol"."stopmedia" = [ "Media Stop" ];
        "org_kde_powerdevil"."Decrease Keyboard Brightness" = [ "Keyboard Brightness Down" ];
        "org_kde_powerdevil"."Decrease Screen Brightness" = [ "Monitor Brightness Down" ];
        "org_kde_powerdevil"."Decrease Screen Brightness Small" = [ "Shift+Monitor Brightness Down" ];
        "org_kde_powerdevil"."Hibernate" = [ "Hibernate" ];
        "org_kde_powerdevil"."Increase Keyboard Brightness" = [ "Keyboard Brightness Up" ];
        "org_kde_powerdevil"."Increase Screen Brightness" = [ "Monitor Brightness Up" ];
        "org_kde_powerdevil"."Increase Screen Brightness Small" = [ "Shift+Monitor Brightness Up" ];
        "org_kde_powerdevil"."PowerDown" = [ "Power Down" ];
        "org_kde_powerdevil"."PowerOff" = [ "Power Off" ];
        "org_kde_powerdevil"."Sleep" = [ "Sleep" ];
        "org_kde_powerdevil"."Toggle Keyboard Backlight" = [ "Keyboard Light On/Off" ];
        "org_kde_powerdevil"."Turn Off Screen" = [ ];
        "org_kde_powerdevil"."powerProfile" = [ "Battery" "Meta+B" ];
        "plasmashell"."activate task manager entry 1" = [ ];
        "plasmashell"."activate task manager entry 2" = [ ];
        "plasmashell"."activate task manager entry 3" = [ ];
        "plasmashell"."activate task manager entry 4" = [ ];
        "plasmashell"."activate task manager entry 5" = [ ];
        "plasmashell"."activate task manager entry 6" = [ ];
        "plasmashell"."activate task manager entry 7" = [ ];
        "plasmashell"."activate task manager entry 8" = [ ];
        "plasmashell"."activate task manager entry 9" = [ ];
        "plasmashell"."activate task manager entry 10" = [ ];
        "plasmashell"."clear-history" = [ ];
        "plasmashell"."clipboard_action" = [ "Meta+Ctrl+X" ];
        "plasmashell"."cycle-panels" = [ "Meta+Alt+P" ];
        "plasmashell"."cycleNextAction" = [ ];
        "plasmashell"."cyclePrevAction" = [ ];
        "plasmashell"."manage activities" = [ "Meta+A" ];
        "plasmashell"."next activity" = [ ];
        "plasmashell"."previous activity" = [ ];
        "plasmashell"."repeat_action" = [ ];
        "plasmashell"."show dashboard" = [ ];
        "plasmashell"."show-barcode" = [ ];
        "plasmashell"."show-on-mouse-pos" = [ "Meta+V" ];
        "plasmashell"."stop current activity" = [ "Meta+Shift+A" ];
        "plasmashell"."switch to next activity" = [ ];
        "plasmashell"."switch to previous activity" = [ ];
        "plasmashell"."toggle do not disturb" = [ ];
        "services/org.kde.dolphin.desktop"."_launch" = [ ];
        "services/org.kde.krunner.desktop"."RunClipboard" = [ "Meta+Shift+D" "Meta+Shift+F2" ];
        "services/org.kde.krunner.desktop"."_launch" = [ "Meta+F2" "Meta+D" ];
      }
      (lib.mkIf (!config.programs.foot.enable) {
        "services/org.kde.konsole.desktop"."_launch" = [ "Meta+Return" ];
      })
      (lib.mkIf config.programs.foot.enable {
        "services/org.codeberg.dnkl.foot.desktop"."_launch" = [ "Meta+Return" ];
      })
      (lib.mkIf (!enablePolonium) {
        "kwin"."PoloniumFocusAbove" = [ ];
        "kwin"."PoloniumFocusBelow" = [ ];
        "kwin"."PoloniumFocusLeft" = [ ];
        "kwin"."PoloniumFocusRight" = [ ];
        "kwin"."PoloniumInsertAbove" = [ ];
        "kwin"."PoloniumInsertBelow" = [ ];
        "kwin"."PoloniumInsertLeft" = [ ];
        "kwin"."PoloniumInsertRight" = [ ];
        "kwin"."PoloniumOpenSettings" = [ ];
        "kwin"."PoloniumResizeAbove" = [ ];
        "kwin"."PoloniumResizeBelow" = [ ];
        "kwin"."PoloniumResizeLeft" = [ ];
        "kwin"."PoloniumResizeRight" = [ ];
        "kwin"."PoloniumRetileWindow" = [ ];
      })
      (lib.mkIf enablePolonium {
        "kwin"."PoloniumFocusAbove" = [ "Meta+K" ];
        "kwin"."PoloniumFocusBelow" = [ "Meta+J" ];
        "kwin"."PoloniumFocusLeft" = [ "Meta+H" ];
        "kwin"."PoloniumFocusRight" = [ "Meta+L" ];
        "kwin"."PoloniumInsertAbove" = [ "Meta+Shift+K" ];
        "kwin"."PoloniumInsertBelow" = [ "Meta+Shift+J" ];
        "kwin"."PoloniumInsertLeft" = [ "Meta+Shift+H" ];
        "kwin"."PoloniumInsertRight" = [ "Meta+Shift+L" ];
        "kwin"."PoloniumOpenSettings" = [ ];
        "kwin"."PoloniumResizeAbove" = [ "Meta+Alt+K" ];
        "kwin"."PoloniumResizeBelow" = [ "Meta+Alt+J" ];
        "kwin"."PoloniumResizeLeft" = [ "Meta+Alt+H" ];
        "kwin"."PoloniumResizeRight" = [ "Meta+Alt+L" ];
        "kwin"."PoloniumRetileWindow" = [ "Meta+Shift+Space" ];
      })
    ];
    programs.plasma.configFile = lib.mkMerge [
      {
        # # TODO(Dusk): Should this be in the config? It feels like state.
        # "baloofilerc"."General"."dbVersion".value = 2;
        "baloofilerc"."General"."exclude filters".value = builtins.concatStringsSep "," [
          "*.a"
          "*.aux"
          "*.class"
          "*.csproj"
          "*.db"
          "*.elc"
          "*.faa"
          "*.fasta"
          "*.fastq"
          "*.fna"
          "*.fq"
          "*.gb"
          "*.gbff"
          "*.gcode"
          "*.gmo"
          "*.img"
          "*.ini"
          "*.init"
          "*.jsc"
          "*.la"
          "*.lo"
          "*.loT"
          "*.m4"
          "*.map"
          "*.moc"
          "*.nvram"
          "*.o"
          "*.omf"
          "*.orig"
          "*.part"
          "*.pc"
          "*.po"
          "*.pyc"
          "*.pyo"
          "*.qcow2"
          "*.qmlc"
          "*.qrc"
          "*.rcore"
          "*.rej"
          "*.so"
          "*.sql"
          "*.sql.gz"
          "*.swap"
          "*.swp"
          "*.tfstate*"
          "*.tmp"
          "*.vbox*"
          "*.vdi"
          "*.vhd"
          "*.vhdx"
          "*.vm*"
          "*.vmdk"
          "*.ytdl"
          "*~"
          ".bzr"
          ".git"
          ".hg"
          ".histfile.*"
          ".moc"
          ".ninja_deps"
          ".ninja_log"
          ".npm"
          ".obj"
          ".pch"
          ".svn"
          ".terraform"
          ".uic"
          ".venv"
          ".xsession-errors*"
          ".yarn"
          ".yarn-cache"
          "CMakeCache.txt"
          "CMakeFiles"
          "CMakeTmp"
          "CMakeTmpQmake"
          "CTestTestfile.cmake"
          "CVS"
          "Makefile.am"
          "__pycache__"
          "_darcs"
          "autom4te"
          "build.ninja"
          "cmake_install.cmake"
          "confdefs.h"
          "config.status"
          "confstat"
          "conftest"
          "core-dumps"
          "libtool"
          "litmain.sh"
          "lost+found"
          "lzo"
          "moc_*.cpp"
          "nbproject"
          "node_modules"
          "node_packages"
          "po"
          "qrc_*.cpp"
          "ui_*.h"
          "vbox.log"
          "venv"
        ];
        "baloofilerc"."General"."exclude filters version".value = 9;
        "dolphinrc"."General"."FilterBar".value = true;
        "dolphinrc"."General"."ShowFullPath".value = true;
        "dolphinrc"."General"."ShowToolTips".value = false;
        "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize".value = false;
        "dolphinrc"."KFileDialog Settings"."Places Icons Static Size".value = 22;
        "kactivitymanagerdrc"."activities"."${defaultActivity}".value = "Default";
        "kactivitymanagerdrc"."main"."currentActivity".value = "${defaultActivity}";
        "kdeglobals"."KDE"."AnimationDurationFactor".value = 0.35;
        "kdeglobals"."KFileDialog Settings"."Allow Expansion".value = true;
        "kdeglobals"."KFileDialog Settings"."Automatically select filename extension".value = true;
        "kdeglobals"."KFileDialog Settings"."Breadcrumb Navigation".value = true;
        "kdeglobals"."KFileDialog Settings"."Decoration position".value = 2;
        "kdeglobals"."KFileDialog Settings"."LocationCombo Completionmode".value = 5;
        "kdeglobals"."KFileDialog Settings"."PathCombo Completionmode".value = 5;
        "kdeglobals"."KFileDialog Settings"."Show Bookmarks".value = false;
        "kdeglobals"."KFileDialog Settings"."Show Full Path".value = true;
        "kdeglobals"."KFileDialog Settings"."Show Inline Previews".value = true;
        "kdeglobals"."KFileDialog Settings"."Show Preview".value = true;
        "kdeglobals"."KFileDialog Settings"."Show Speedbar".value = true;
        "kdeglobals"."KFileDialog Settings"."Show hidden files".value = true;
        "kdeglobals"."KFileDialog Settings"."Sort by".value = "Name";
        "kdeglobals"."KFileDialog Settings"."Sort directories first".value = true;
        "kdeglobals"."KFileDialog Settings"."Sort hidden files last".value = true;
        "kdeglobals"."KFileDialog Settings"."Sort reversed".value = false;
        "kdeglobals"."KFileDialog Settings"."View Style".value = "DetailTree";
        # "kdeglobals"."PreviewSettings"."MaximumRemoteSize".value = 0;
        "kdeglobals"."Shortcuts"."ActualSize".value = "Ctrl+=";
        "kdeglobals"."Shortcuts"."ZoomIn".value = "Ctrl++";
        "kdeglobals"."Shortcuts"."ZoomOut".value = "Ctrl+-";
        # "kglobalshortcutsrc"."ActivityManager"."_k_friendly_name".value = "Activity Manager";
        # "kglobalshortcutsrc"."KDE Keyboard Layout Switcher"."_k_friendly_name".value = "Keyboard Layout Switcher";
        # "kglobalshortcutsrc"."kaccess"."_k_friendly_name".value = "Accessibility";
        # "kglobalshortcutsrc"."kcm_touchpad"."_k_friendly_name".value = "Touchpad";
        # "kglobalshortcutsrc"."kmix"."_k_friendly_name".value = "Audio Volume";
        # "kglobalshortcutsrc"."ksmserver"."_k_friendly_name".value = "Session Management";
        # "kglobalshortcutsrc"."kwin"."_k_friendly_name".value = "KWin";
        # "kglobalshortcutsrc"."mediacontrol"."_k_friendly_name".value = "Media Controller";
        # "kglobalshortcutsrc"."org_kde_powerdevil"."_k_friendly_name".value = "KDE Power Management System";
        # "kglobalshortcutsrc"."plasmashell"."_k_friendly_name".value = "plasmashell";
        # "kwalletrc"."Wallet"."First Use".value = false;
        "kwinrc"."Desktops"."Id_1".value = "7d2e35b4-7776-4263-9ae6-ae2219c0bcdf";
        "kwinrc"."Desktops"."Id_2".value = "fb04f8f2-a8ac-4b7c-93fc-d87341ee5e32";
        "kwinrc"."Desktops"."Id_3".value = "f56d3644-240e-4fc3-a60e-b46f031520a3";
        "kwinrc"."Desktops"."Id_4".value = "fc3c1b46-4af4-4ccc-bd53-a3d987ccfd72";
        "kwinrc"."Desktops"."Id_5".value = "c56f7cad-aad8-4ed9-962a-10086f31a8af";
        "kwinrc"."Desktops"."Id_6".value = "40b8e8a5-9b13-4059-b844-98f39deec8fa";
        "kwinrc"."Desktops"."Id_7".value = "5dfc4ede-ad3d-4e74-a16f-dc7cb97bf1f6";
        "kwinrc"."Desktops"."Id_8".value = "65fbac53-d8d6-46c0-bcfd-de520825147f";
        "kwinrc"."Desktops"."Id_9".value = "5c041aa8-59c2-41ca-8ff0-900b990f1d4e";
        "kwinrc"."Desktops"."Id_10".value = "090214fc-5775-45e1-82e2-a3f62f8b077f";
        "kwinrc"."Desktops"."Number".value = 10;
        "kwinrc"."Desktops"."Rows".value = 1;
        "kwinrc"."Effect-magiclamp"."AnimationDuration".value = 1000;
        "kwinrc"."Effect-overview"."BorderActivate".value = 1;
        "kwinrc"."ElectricBorders"."TopLeft".value = "ApplicationLauncher";
        "kwinrc"."ModifierOnlyShortcuts"."Meta".value = "";
        "kwinrc"."Plugins"."poloniumEnabled".value = enablePolonium;
        "kwinrc"."Plugins"."slideEnabled".value = false;
        "kwinrc"."Script-polonium"."Borders".value = 3;
        "kwinrc"."Script-polonium"."EngineType".value = 0; # Binary tree
        "kwinrc"."Script-polonium"."InsertionPoint".value = 2;
        "kwinrc"."Script-polonium"."FilterProcess".value = builtins.concatStringsSep "," [
          "goldwarden"
          "kded"
          "krunner"
          "plasmashell"
          "polkit"
          "yakuake"
        ];
        "kwinrc"."Tiling"."padding".value = 4;
        "kwinrc"."Windows"."ElectricBorderDelay".value = 50;
        "kwinrc"."Windows"."ElectricBorders".value = 1;
        "kwinrc"."Windows"."RollOverDesktops".value = true;
        # "kwinrc"."Xwayland"."Scale".value = 1;
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft".value = "MNH";
        "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight".value = "SILAX";
        "kxkbrc"."Layout"."Options".value = "caps:swapescape,ctrl:swap_lalt_lctl,compose:ralt";
        "kxkbrc"."Layout"."ResetOldOptions".value = true;
        # "plasma-localerc"."Formats"."LANG".value = "en_US.UTF-8";
        "plasma-localerc"."Formats"."LC_MEASUREMENT".value = "C";
        "systemsettingsrc"."systemsettings_sidebar_mode"."HighlightNonDefaultSettings".value = true;
      }
      (lib.mkIf (!enablePolonium) {
        "kwinrc"."Windows"."FocusPolicy".value = "FocusFollowsMouse";
      })
      (lib.mkIf enablePolonium {
        "kwinrc"."Windows"."FocusPolicy".value = "ClickToFocus";
      })
    ];
    programs.plasma.overrideConfig = true;
    programs.plasma.overrideConfigFiles = [
      "baloofilerc"
      # "dolphinrc"
      # "ffmpegthumbsrc"
      # "kactivitymanagerdrc"
      # "katerc"
      # "kcminputrc"
      # "kded5rc"
      # "kdeglobals"
      # "kgammarc"
      "kglobalshortcutsrc"
      # "khotkeysrc"
      # "kiorc"
      # "klaunchrc"
      # "klipperrc"
      # "kmixrc"
      # "krunnerrc"
      # "kscreenlockerrc"
      # "kservicemenurc"
      # "ksmserverrc"
      # "ksplashrc"
      # "kwalletrc"
      # "kwin_rules_dialogrc"
      # "kwinrc"
      # "kwinrulesrc"
      "kxkbrc"
      # "plasma-localerc"
      # "plasmanotifyrc"
      # "plasmarc"
      # "plasmashellrc"
      "systemsettingsrc"
    ];
    programs.plasma.overrideConfigExclude = [
      "baloofilerc"
    ];
    # programs.plasma.globalAppletConfigs = {
    #   "org.kde.panel" = { };
    #   "org.kde.plasma.digitalclock" = { };
    #   "org.kde.plasma.kickoff" = { };
    #   "org.kde.plasma.marginsseparator" = { };
    #   "org.kde.plasma.pager" = { };
    #   "org.kde.plasma.showdesktop" = { };
    #   "org.kde.plasma.systemtray" = { };
    #   "org.kde.plasma.taskmanager" = { };
    # };
    # programs.plasma.panels = [
    #   {
    #     location = "top";
    #     height = 44;
    #     floating = false;
    #     offset = 0;
    #     alignment = "center";
    #     hiding = "none";
    #     widgets = [
    #       {
    #         name = "org.kde.plasma.pager";
    #         config = { };
    #       }
    #     ];
    #   }
    # ];
    # programs.plasma.panels = [
    #   {
    #     alignment = "center";
    #     config = {
    #       Applets = {
    #         "6" = {
    #           immutability = "1";
    #           plugin = "org.kde.plasma.marginsseparator";
    #         };
    #       };
    #       activityId = "";
    #       formfactor = "2";
    #       immutability = "1";
    #       lastScreen = "0";
    #       location = "3";
    #       plugin = "org.kde.panel";
    #       wallpaperplugin = "org.kde.image";
    #     };
    #     floating = false;
    #     formFactor = "horizontal";
    #     height = 44;
    #     hiding = "none";
    #     id = 2;
    #     length = 2288;
    #     lengthMode = "fill";
    #     location = "top";
    #     locked = false;
    #     maximumLength = 1920;
    #     minimumLength = 1920;
    #     objectName = "";
    #     offset = 0;
    #     screen = 0;
    #     type = "org.kde.panel";
    #     version = "";
    #     wallpaperMode = "";
    #     wallpaperPlugin = "org.kde.image";
    #     widgets = [
    #       {
    #         # id = 26;
    #         name = "org.kde.plasma.kickoff";
    #         # config.ConfigDialog.DialogHeight = "540";
    #         # config.ConfigDialog.DialogWidth = "720";
    #         config.PreloadWeight = "100";
    #         config.popupHeight = "510";
    #         config.popupWidth = "647";
    #       }
    #       {
    #         # id = 4;
    #         name = "org.kde.plasma.pager";
    #         # config.ConfigDialog.DialogHeight = "540";
    #         # config.ConfigDialog.DialogWidth = "720";
    #       }
    #       {
    #         # id = 31;
    #         name = "org.kde.plasma.taskmanager";
    #         # config.ConfigDialog.DialogHeight = "540";
    #         # config.ConfigDialog.DialogWidth = "720";
    #       }
    #       {
    #         # id = 6;
    #         name = "org.kde.plasma.marginsseparator";
    #         config = { };
    #       }
    #       {
    #         # id = 7;
    #         name = "org.kde.plasma.systemtray";
    #         config.PreloadWeight = "80";
    #         config.SystrayContainmentId = "8";
    #       }
    #       {
    #         # id = 19;
    #         name = "org.kde.plasma.digitalclock";
    #         config.Appearance.fontWeight = "400";
    #         config.PreloadWeight = "60";
    #         config.popupHeight = "450";
    #         config.popupWidth = "560";
    #       }
    #       {
    #         # id = 20;
    #         name = "org.kde.plasma.showdesktop";
    #         config = { };
    #       }
    #     ];
    #   }
    # ];
    services.kdeconnect.indicator = lib.mkIf config.services.kdeconnect.enable false;
    # systemd.user.services.plasma-plasmashell = {
    #   Unit = {
    #     Before = [ "tray.target" ];
    #     PropagatesReloadTo = [ "tray.target" ];
    #     PropagatesStopTo = [ "tray.target" ];
    #     ReloadPropagatedFrom = [ "tray.target" ];
    #     Wants = [ "tray.target" ];
    #   };
    # };
  };
}
