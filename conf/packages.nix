let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:
let
  inherit (srcs)
    sources
    sources-ext
    nixpkgs-stable
    lib-stable
    nixpkgs-unstable
    lib-unstable
    nixpkgs-unstable-bb010g
    lib-unstable-bb010g
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
      # pkgs.exfat-utils
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
      nixpkgs-unstable.noto-fonts-emoji
      nixpkgs-unstable.twitter-color-emoji
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
      nixpkgs-unstable.bitwarden-cli
      pkgs.nur.pkgs.bb010g.broca-unstable
      pkgs.cowsay
      nixpkgs-unstable.nur.pkgs.bb010g.edbrowse
      pkgs.elinks
      pkgs.fortune
      # nixpkgs-unstable.nur.pkgs.bb010g.html2json-unstable
      pkgs.lynx
      pkgs.megatools
      pkgs.ponysay
      pkgs.smbclient
      nixpkgs-unstable.synapse-bt
      pkgs.units
    ];

    nix = [
      pkgs.cabal2nix
      pkgs.cachix
      ((pkgs.diffoscope.override { enableBloat = true; }).overrideAttrs (o: {
        pythonPath = o.pythonPath ++ [ pkgs.zip ];
      }))
      pkgs.niv.niv
      # It's a Hackage package! (:
      (if nixpkgs-unstable.nix-diff.meta.broken or false
        then pkgs.nix-diff
        else nixpkgs-unstable.nix-diff)
      nixpkgs-unstable.nix-index
      nixpkgs-unstable.nix-prefetch-github
      nixpkgs-unstable.nix-prefetch-scripts
      nixpkgs-unstable.nix-top
      nixpkgs-unstable.nix-universal-prefetch
      nixpkgs-unstable.vulnix
      pkgs.yarn2nix-moretea.yarn2nix
      # TODO figure out how to build nixpkgs manual
    ];

    tex = [
      pkgs.biber
    ];

    tools = let
      # deal with buggy libredirect glibc linking (it shouldn't be linked)
      sublime-merge = let sublime-mergeRelPath =
        "/pkgs/applications/version-management/sublime-merge";
      in (pkgs.callPackage (nixpkgs-unstable.path + sublime-mergeRelPath) {
      }).sublime-merge.overrideAttrs (o: {
        installPhase =
          let regex = "(makeWrapper [^\n]*)"; in
          lib.concatStrings (lib.concatMap (matches:
            if !(lib.isList matches) then [ matches ] else
              matches ++ [ " --argv0 '$0'" ]
          ) (builtins.split regex o.installPhase));
      });
    in [
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
      pkgs.gitAndTools.git-crypt
      pkgs.gitAndTools.git-imerge
      pkgs.nur.pkgs.bb010g.gitAndTools.git-my
      pkgs.nur.pkgs.bb010g.gitAndTools.git-revise
      pkgs.gnumake
      pkgs.hecate
      pkgs.hyperfine
      pkgs.icdiff
      pkgs.inxi
      pkgs.ispell
      # nixpkgs-unstable.nur.pkgs.bb010g.just
      pkgs.lzip
      nixpkgs-unstable.nur.pkgs.bb010g.mosh-unstable
      pkgs.ngrok
      pkgs.p7zip
      pkgs.ponymix
      pkgs.rclone
      pkgs.sbcl
      sublime-merge
      (pkgs.writeShellScriptBin "smergetool"
        ''exec -a smerge ${lib.escapeShellArg sublime-merge}/bin/sublime_merge mergetool "$@"'')
      pkgs.tokei
      pkgs.nur.pkgs.bb010g.ttyd
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

    gui-core = [
      pkgs.arandr
      pkgs.breeze-icons
      pkgs.breeze-qt5
      pkgs.glxinfo
      pkgs.gnome3.adwaita-icon-theme
      nixpkgs-unstable.nur.pkgs.nexromancers.hacksaw
      pkgs.hicolor-icon-theme
      pkgs.nix-gl.nixGLIntel
      pkgs.nix-gl.nixVulkanIntel
      nixpkgs-unstable.nur.pkgs.nexromancers.shotgun
      nixpkgs-unstable.nur.pkgs.bb010g.st-bb010g-unstable
      pkgs.xsel
    ];

    gui-editors = [
      pkgs.nur.pkgs.bb010g._010-editor
      pkgs.libreoffice
      pkgs.standardnotes
      # on unstable until #73484 is merged to release-19.09
      # and #70511 is resolved
      nixpkgs-unstable.texstudio
      pkgs.wxhexeditor
    ];

    gui-games = [
      pkgs.scummvm
      pkgs.steam
    ];

    gui-media = [
      pkgs.aseprite-unfree
      pkgs.evince
      pkgs.geeqie
      pkgs.gimp
      # nixpkgs-unstable-bb010g.pkgs.grafx2
      nixpkgs-unstable.grafx2
      pkgs.inkscape
      pkgs.kdeApplications.kolourpaint
      pkgs.krita
      pkgs.mpv
      pkgs.mtpaint
      pkgs.pinta
      pkgs.sxiv
      pkgs.youtube-dl
    ];

    gui-misc = [
      nixpkgs-unstable.bitwarden
      pkgs.discord
      pkgs.google-chrome
      pkgs.gucharmap
      pkgs.keybase-gui
      pkgs.qutebrowser
      pkgs.element-desktop
      nixpkgs-unstable.tdesktop
      pkgs.wire-desktop
    ];

    gui-tools = [
      # pkgs.cantata -> pkgs/mpd.nix
      pkgs.cmst
      pkgs.dmenu
      pkgs.freerdp
      pkgs.gnome3.gnome-system-monitor
      pkgs.ksysguard
      # nixpkgs-unstable-bb010g.nur.pkgs.bb010g.ipscan
      pkgs.notify-desktop
      pkgs.pavucontrol
      pkgs.pcmanfm
      pkgs.qdirstat
      pkgs.remmina
      pkgs.sqlitebrowser
      pkgs.nur.pkgs.bb010g.surf-unstable
      pkgs.wireshark
      nixpkgs-unstable.nur.pkgs.bb010g.xcolor
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
