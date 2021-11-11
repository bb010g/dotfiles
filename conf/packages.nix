let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:
let
  inherit (srcs)
    sources
    sources-ext
  ;
in
{
  config.home.packages = let
    core = [
      pkgs.ed # ed is the STANDARD text editor
      pkgs.file
      pkgs.manpages
      pkgs.moreutils
      # pkgs.nvi
      pkgs.posix_man_pages
      (pkgs.ripgrep.override { withPCRE2 = true; })
      pkgs.tree
      pkgs.zsh-completions
    ];

    editors = [
      pkgs.hunspell
    ] ++ hunspellDicts ++ [
      pkgs.kakoune
      # emacs is at config.programs
      pkgs.emacs-all-the-icons-fonts
    ];

    filesystem = [
      # pkgs.bcachefs-tools
      pkgs.cifs-utils
      pkgs.dosfstools
      # pkgs.e2fsprogs
      pkgs.e2tools
      pkgs.exfatprogs
      pkgs.f2fs-tools
      pkgs.hfsprogs
      # pkgs.mtdutils
      pkgs.nfs-utils
      pkgs.squashfsTools
    ];

    fontconfig-emoji = pkgs.runCommand "fontconfig-emoji" {
      src = sources.fontconfig-emoji;
    } ''
      supportFolder=$out/etc/fonts/conf.d

      mkdir -p "$supportFolder"

      ln -st "$supportFolder" "$src"/69-emoji.conf
      ${lib.optionalString false ''
        ln -st "$supportFolder" "$src"/69-emoji-monospace.conf
      ''}ln -st "$supportFolder" "$src"/70-no-mozilla-emoji.conf
    '';

    fontconfig-user = pkgs.runCommand "fontconfig-user" {
      src = ../fontconfig;
    } ''
      mkdir -p "$out"/etc/fonts/conf.d
      cp -t "$out"/etc/fonts/conf.d/ \
        "$src"/49-zonk-sansserif.conf \
        "$src"/50-user.conf \
        "$src"/70-no-adobe-blank.conf
    '';

    fonts-base = [
      # ttf-courier-prime
      pkgs.dejavu_fonts
      # ttf-heuristica
      pkgs.liberation_ttf
      pkgs.noto-fonts
      pkgs.symbola
    ];
    xorg-fonts-misc = [
      pkgs.xorg.fontarabicmisc
      pkgs.xorg.fontcursormisc
      pkgs.xorg.fontdaewoomisc
      pkgs.xorg.fontdecmisc
      pkgs.xorg.fontisasmisc
      pkgs.xorg.fontjismisc
      pkgs.xorg.fontmicromisc
      pkgs.xorg.fontmiscethiopic
      pkgs.xorg.fontmiscmeltho
      pkgs.xorg.fontmiscmisc
      pkgs.xorg.fontmuttmisc
      pkgs.xorg.fontschumachermisc
      pkgs.xorg.fontsonymisc
      pkgs.xorg.fontsunmisc
    ];
    fonts-extended-lt = fonts-base ++ [
      pkgs.caladea
      pkgs.cantarell-fonts
      pkgs.carlito
      # pkgs.font-droid (dropped in favor of noto?)
      # ttf-gelasio ( http://sorkintype.com/ )
      pkgs.google-fonts
      # gsfonts ( https://github.com/ArtifexSoftware/urw-base35-fonts )
      pkgs.gyre-fonts
      # ttf-impallari-cantora
      # ttf-signika ( https://fonts.google.com/specimen/Signika )
      pkgs.ubuntu_font_family
    ]; # ++ xorg-fonts-misc;

    fonts-emoji = [
      # fontconfig-emoji # needs global installation
      pkgs.nur.pkgs.bb010g.mutant-standard
      pkgs.noto-fonts-emoji
      pkgs.twitter-color-emoji
    ];

    fonts = fonts-extended-lt ++ [
      pkgs.corefonts
      fontconfig-user
      pkgs.raleway
      pkgs.vistafonts
    ] ++ fonts-emoji;

    hunspellDicts = [
      pkgs.hunspellDicts.en-us
      pkgs.hunspellDicts.es-any
    ];

    media = [
      pkgs.ffmpeg
      # pkgs.mpc_cli -> conf/mpd.nix
    ];

    misc = [
      pkgs.bitwarden-cli
      pkgs.nur.pkgs.bb010g.broca-unstable
      pkgs.cowsay
      pkgs.nur.pkgs.bb010g.edbrowse
      pkgs.elinks
      pkgs.fortune
      # pkgs.nur.pkgs.bb010g.html2json-unstable
      pkgs.lynx
      pkgs.megatools
      pkgs.ponysay
      pkgs.smbclient
      pkgs.units
    ];

    nix = [
      pkgs.cabal2nix
      pkgs.cachix
      ((pkgs.diffoscope.override { enableBloat = true; }).overrideAttrs (o: {
        pythonPath = o.pythonPath ++ [ pkgs.zip ];
        # disabledTests = o.disabledTests or [ ] ++ [
        #   "test_ico_image"
        #   "test_jpeg_image"
        # ];
      }))
      pkgs.niv
      pkgs.nix-diff
      pkgs.nix-index
      pkgs.nix-prefetch-github
      pkgs.nix-prefetch-scripts
      pkgs.nix-top
      pkgs.nix-universal-prefetch
      pkgs.vulnix
      pkgs.yarn2nix-moretea.yarn2nix
      # TODO figure out how to build nixpkgs manual
    ];

    tools = [
      pkgs.acpi
      pkgs.androidenv.androidPkgs_9_0.platform-tools
      pkgs.asciinema
      # pkgs.asciinema-edit
      pkgs.bind
      pkgs.binutils
      pkgs.colordiff
      pkgs.cv
      pkgs.diffstat
      pkgs.nur.pkgs.bb010g.dwdiff
      # glib: Provides gio(1) & friends.
      (lib.getBin pkgs.glib)
      pkgs.gnumake
      pkgs.hecate
      pkgs.hyperfine
      pkgs.icdiff
      pkgs.inxi
      pkgs.ispell
      # pkgs.nur.pkgs.bb010g.just
      pkgs.lzip
      pkgs.nur.pkgs.bb010g.mosh-unstable
      pkgs.ngrok
      pkgs.p7zip
      pkgs.ponymix
      pkgs.rclone
      pkgs.sbcl
      pkgs.tokei
      # pkgs.nur.pkgs.bb010g.ttyd
      pkgs.unzip
      pkgs.nur.pkgs.bb010g.ydiff
    ];

    gui = lib.concatLists [
      gui-core
      gui-editors
      gui-games
      gui-media
      gui-misc
      gui-tools
    ];

    gui-x11 = true;
    gui-x11-only = gui-x11 && false;
    gui-wayland = true;
    # gui-wayland-only = gui-wayland && true;

    gui-core = [
      pkgs.breeze-icons
      pkgs.breeze-qt5
      pkgs.glxinfo
      pkgs.gnome3.adwaita-icon-theme
      pkgs.hicolor-icon-theme
      pkgs.nix-gl.nixGLIntel
      pkgs.nix-gl.nixVulkanIntel
      pkgs.qt5ct
    ] ++ gui-core-x11 ++ gui-core-x11-only ++ gui-core-wayland;
    gui-core-x11 = lib.optionals gui-x11 [
      # arandr: Still works with multiple Wayland displays.
      pkgs.arandr
      # hacksaw: Has graphical glitches.
      # pkgs.nur.pkgs.nexromancers.hacksaw
      pkgs.hacksaw
      # st-bb010g-unstable: foot is nicer.
      pkgs.nur.pkgs.bb010g.st-bb010g-unstable
    ];
    gui-core-x11-only = lib.optionals gui-x11-only [
      # shotgun: Requires X_GetImage.
      # pkgs.nur.pkgs.nexromancers.shotgun
      pkgs.shotgun
      # xsel: Requires XConvertSelection -> |event|(
      #     event.type == SelectionNotify &&
      #       event.xselection.property != None
      #   )
      pkgs.xsel
    ];
    gui-core-wayland = lib.optionals gui-wayland [
      # foot: Handled by programs.foot.
      # pkgs.foot
      pkgs.grim
      pkgs.qt5.qtwayland
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.wtype
      # pkgs.xdg-desktop-portal
      # pkgs.xdg-desktop-portal-wlr
    ];

    gui-editors = [
      pkgs.nur.pkgs.bb010g._010-editor
      pkgs.libreoffice
      pkgs.standardnotes
      pkgs.wxhexeditor
    ];

    gui-games = [
      pkgs.scummvm
      pkgs.steam
    ];

    gui-media = [
      # # TODO: ugh, aseprite-skia build times
      # pkgs.aseprite-unfree
      pkgs.audacity
      pkgs.evince
      pkgs.geeqie
      pkgs.gimp
      pkgs.grafx2
      pkgs.inkscape
      pkgs.plasma5Packages.kolourpaint
      pkgs.krita
      pkgs.mpv
      pkgs.mtpaint
      pkgs.pinta
      pkgs.sxiv
      pkgs.youtube-dl
    ];

    gui-misc = [
      pkgs.bitwarden
      pkgs.discord
      pkgs.google-chrome
      pkgs.gucharmap
      pkgs.keybase-gui
      pkgs.qutebrowser
      pkgs.element-desktop
      pkgs.tdesktop
      pkgs.wire-desktop
    ];

    gui-tools = [
      # pkgs.cantata -> pkgs/mpd.nix
      pkgs.captive-browser
      pkgs.carla
      pkgs.dmenu
      pkgs.freerdp
      pkgs.gnome3.gnome-system-monitor
      pkgs.plasma5Packages.ksystemstats
      # pkgs.nur.pkgs.bb010g.ipscan
      pkgs.notify-desktop
      pkgs.pavucontrol
      pkgs.pcmanfm
      pkgs.qdirstat
      pkgs.remmina
      pkgs.sqlitebrowser
      pkgs.nur.pkgs.bb010g.surf-unstable
      pkgs.wireshark
      # pkgs.nur.pkgs.bb010g.xcolor
      pkgs.xcolor
      pkgs.xorg.xbacklight
    ];
  in lib.concatLists [
    core
    editors
    filesystem
    fonts
    gui
    media
    misc
    nix
    tools
  ];
}
