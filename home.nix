{ config, lib, pkgs ? null, ... }:
let argPkgs = pkgs; in

let
  # > nix-channel --list
  # nixos-unstable https://nixos.org/channels/nixos-unstable
  #
  # might also have some personal patches?
  # if so, they'd be up at https://github.com/bb010g/nixpkgs, branch bb010g-*

  inherit (builtins) elemAt fetchTarball;
  private = if lib.pathExists ./private.nix then import ./private.nix else {
    apis = { };
  };
  versions = builtins.fromJSON (lib.readFile ./versions.json);
  ppkgs = lib.mapAttrs (n: v: fetchTarball {
    url = "${elemAt v.url 0}${v.rev}${elemAt v.url 1}";
    inherit (v) sha256;
  }) versions.pkgs;
  pinned = false;
  pkgs = if pinned || argPkgs == null then ppkgs.stable else argPkgs;
  pkgs-stable = import (
    if !pinned && lib.pathExists <nixos-19.03> then <nixos-19.03> else
    if !pinned && lib.pathExists <nixos> then <nixos> else
    if !pinned && lib.pathExists <nixpkgs> then <nixpkgs> else
    ppkgs.stable
  ) { };
  pkgs-unstable = import (
    if !pinned && lib.pathExists <nixos-unstable> then <nixos-unstable> else
    ppkgs.unstable
  ) { };
  pkgs-unstable-bb010g = import (
    if !pinned && lib.pathExists <bb010g-nixos-unstable> then
      <bb010g-nixos-unstable> else
    ppkgs.unstable-bb010g
  ) { };
in
{
  home.sessionVariables.NIX_PATH = "${config.home.homeDirectory}/nix/channels:$NIX_PATH";

  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <alias>
        <family>monospace</family>
        <prefer>
          <family>Ubuntu Mono</family>
        </prefer>
      </alias>
    </fontconfig>
  '';

  home.keyboard = {
    layout = "us,gr";
    options = [
      "compose:ralt"
      "ctrl:swap_lalt_lctl"
      "caps:swapescape"
      "grp:rctrl_rshift_toggle"
    ];
  };

  home.packages = let
    core = [
      pkgs.ed # ed is the STANDARD text editor
      pkgs.file
      pkgs.manpages
      pkgs.moreutils
      pkgs.nvi
      (pkgs-unstable.ripgrep.override { withPCRE2 = true; })
      pkgs.tree
      pkgs.zsh-completions
    ];

    editors = [
      pkgs.hunspell
      pkgs.hunspellDicts.en-us
      pkgs.hunspellDicts.es-any
      pkgs.kakoune
      # emacs is at config.programs
      pkgs.emacs-all-the-icons-fonts
    ];

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
    fonts = fonts-extended-lt ++ [
      pkgs.corefonts
      pkgs.raleway
      pkgs.vistafonts
    ];

    media = [
      pkgs.ffmpeg
      pkgs.mpc_cli
    ];

    misc = [
      pkgs-unstable.bitwarden-cli
      pkgs.cowsay
      pkgs-unstable.edbrowse
      pkgs.elinks
      pkgs.fortune
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
      }))
      pkgs-unstable.nur.repos.bb010g.lorri
      pkgs.nix-prefetch-github
      pkgs.nix-prefetch-scripts
      pkgs.yarn2nix
      # TODO figure out how to build nixpkgs manual
    ];

    tex = [
      pkgs.biber
    ];

    tools = [
      pkgs.androidenv.androidPkgs_9_0.platform-tools
      pkgs.asciinema
      # pkgs.asciinema-edit
      pkgs.bind
      pkgs.binutils
      pkgs.colordiff
      pkgs.diffstat
      pkgs.nur.repos.bb010g.dwdiff
      pkgs.git-lfs
      pkgs.gnumake
      pkgs.hecate
      pkgs-unstable.hyperfine
      pkgs.icdiff
      pkgs.nur.repos.mic92.inxi
      pkgs.ispell
      pkgs-unstable.nur.repos.bb010g.just
      pkgs.lzip
      (pkgs-unstable.mosh.overrideAttrs (o: rec {
        name = "mosh";
        version = "1.3.2+${lib.substring 0 7 src.rev}";
        src = pkgs.fetchFromGitHub {
          owner = "mobile-shell";
          repo = "mosh";
          rev = "c3a2756065a0fb04cfd2681280123b362d862a5e";
          sha256 = "1g4ncphw0hkvswy4jw546prqg3kifc600zjzdlpxdbafa2yyq34v";
        };
      }))
      pkgs.p7zip
      pkgs.ponymix
      pkgs.rclone
      pkgs.sbcl
      pkgs.tokei
      pkgs.unzip
      pkgs.nur.repos.bb010g.ydiff
    ];

    gui = lib.concatLists [
      gui-core
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
      pkgs.nur.repos.nexromancers.hacksaw
      pkgs.hicolor-icon-theme
      pkgs.nur.repos.nexromancers.shotgun
      ((pkgs.st.overrideAttrs (o: rec {
        name = "st-${version}";
        version = "0.8.2+${lib.substring 0 7 src.rev}";
        src = pkgs.fetchgit {
          url = "https://git.suckless.org/st";
          rev = "21367a040f056f6a207fafa066bd1cb2d9cae586";
          sha256 = "11w5zcxn2gsd0x6a7maff7bwyl71wb3ydgvs7msifmwn1d3cmqby";
        };
      })).override {
        conf = lib.readFile st/config.h;
        patches = [
          st/bold-is-not-bright.diff
          st/scrollback.diff
          st/vertcenter.diff
        ];
      })
      pkgs.xsel
    ];

    gui-games = [
      pkgs.scummvm
      pkgs.steam
    ];

    gui-media = [
      pkgs.evince
      pkgs.geeqie
      pkgs.gimp
      pkgs-unstable-bb010g.grafx2
      pkgs.inkscape
      pkgs.kdeApplications.kolourpaint
      pkgs.krita
      (pkgs-unstable-bb010g.mpv.override rec {
        archiveSupport = true;
        openalSupport = true;
      })
      pkgs.mtpaint
      pkgs.pinta
      pkgs.sxiv
      pkgs.youtube-dl
    ];

    gui-misc = [
      pkgs-unstable.discord
      ((pkgs.nur.repos.mozilla.lib.firefoxOverlay.firefoxVersion {
        name = "Firefox Nightly";
        # https://product-details.mozilla.org/1.0/firefox_versions.json
        #  : FIREFOX_NIGHTLY
        inherit (versions.firefox.nightly) version;
        # system: ? arch (if stdenv.system == "i686-linux" then "linux-i686" else "linux-x86_64")
        # https://download.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-${version}.en-US.${system}.buildhub.json
        #  : download -> url -> (parse)
        #  - https://archive.mozilla.org/pub/firefox/nightly/%Y/%m/%Y-%m-%d-%H-%m-%s-mozilla-central/firefox-${version}.en-US.${system}.tar.bz2
        #  : build -> date -> (parse) also works
        #  - %Y-%m-%dT%H:%m:%sZ
        #  need %Y-%m-%d-%H-%m-%s
        inherit (versions.firefox.nightly) timestamp;
        release = false;
      }).overrideAttrs (o: { buildCommand = lib.replaceStrings [ ''
        --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
      '' ] [ ''
        --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
        --set SNAP_NAME firefox \
      '' ] o.buildCommand; }))
      pkgs.google-chrome
      pkgs.keybase-gui
      # for Firefox MozLz4a JSON files (.jsonlz4)
      pkgs-unstable.nur.repos.bb010g.mozlz4-tool
      pkgs-unstable.riot-desktop
      pkgs-unstable.tdesktop
      pkgs-unstable.wire-desktop
    ];

    gui-tools = [
      pkgs.cantata
      pkgs.cmst
      pkgs.dmenu
      pkgs.freerdp
      pkgs.gnome3.gnome-system-monitor
      pkgs.ksysguard
      pkgs-unstable-bb010g.nur.repos.bb010g.ipscan
      pkgs.notify-desktop
      pkgs.pavucontrol
      pkgs.pcmanfm
      pkgs.qdirstat
      pkgs.remmina
      pkgs.sqlitebrowser
      pkgs.surf
      pkgs.wireshark
      pkgs-unstable.nur.repos.bb010g.xcolor
      pkgs.xorg.xbacklight
    ];
  in lib.concatLists [
    core
    editors
    fonts
    gui
    media
    misc
    nix
    tools
  ];

  home.sessionVariables.EDITOR = "ed";
  home.sessionVariables.PAGER = "less -RF";
  home.sessionVariables.VISUAL = "nvim";

  programs.autorandr = {
    enable = true;
    profiles = let
      genProfiles = displays: lib.mapAttrs (name: value: value // {
        fingerprint = lib.mapAttrs' (n: _: {
          name = displays.${n}.output; value = displays.${n}.fingerprint;
        }) value.config;
        config = lib.mapAttrs' (n: v: {
          name = displays.${n}.output; value = displays.${n}.config // v;
        }) value.config;
      });
      # { <profile> = { output = "<name>"; fingerprint = "…"; config = {…}; … }; … }
      displays = import ./displays.nix;
    in genProfiles displays {
      mobile.config = {
        laptop = {};
      };
      home-docked.config = {
        laptop = { enable = false; };
        home = {};
      };
    };
  };

  programs.beets = {
    enable = true;
    package = pkgs-unstable.beets;
    settings = let
      optionalPlugin = p: let cond = private.apis ? ${p}; in {
        plugin = lib.optional cond p;
        name = if cond then p else null;
        value = private.apis.${p} or null;
      };

      acoustid = optionalPlugin "acoustid";
      discogs = optionalPlugin "discogs";

      hasPrivatePath = p: lib.hasAttrByPath p private;
      googlePath = [ "google" "personal" "beetsKey" ];
    in {
      plugins = [
        # autotagger
        "chroma"
        "fromfilename"
        # metadata
        # "absubmit" (needs streaming_music_extractor)
        "acousticbrainz"
        "fetchart"
        "ftintitle"
        "lastgenre"
        "lyrics"
        "mbsync"
        "replaygain"
        "scrub"
        # path formats
        "rewrite"
        "the"
        # interoperability
        "badfiles"
        "mpdupdate"
        # miscellaneous
        "convert"
        "duplicates"
        "export"
        "fuzzy"
        "info"
        "mbsubmit"
        "missing"
      ] ++ lib.concatLists [
        # autotagger
        discogs.plugin
      ];

      ${acoustid.name} = {
        apikey = acoustid.value;
      };
      badfiles = {
        commands = {
        };
      };
      convert = {
        embed = "no";
        format = "opus";
        formats = {
          opus = {
            command = "ffmpeg -i $source -y -map_metadata 0 -c:a libopus -b:a 256k $dest";
          };
        };
      };
      ${discogs.name} = {
        user_token = discogs.value;
      };
      lyrics = {
        ${if hasPrivatePath googlePath then "google_API_key" else null} =
          lib.getAttrByPath googlePath private;
      };
      paths = {
        "default" = "%the{$albumartist}/%the{$album}%aunique{}/$track $title";
        "singleton" = "Non-Album/%the{$artist}/$title";
        "comp" = "Compilations/%the{$album}%aunique{}/$track $title";
      };
      replaygain = {
        backend = "bs1770gain";
      };
      mpd = {
        port = 6600;
      };
    };
  };

  programs.direnv.enable = true;

  programs.emacs.enable = true;
  # home.file.".emacs.d".source = pkgs.fetchFromGitHub {
  #   owner = "hlissner";
  #   repo = "doom-emacs";
  #   rev = "abc7ca84d8719487113581111079a60ef6588c43"; # develop
  #   sha256 = "1vf3c83my7dm4yxdjkk6y42z8rwdn55v5hqymfgqcggxg0l2wrqv";
  # };

  programs.feh.enable = true;

  # programs.firefox = {
  #   enable = true;
  #   package = moz_nixpkgs.latest.firefox-nightly-bin;
  #   enableAdobeFlash = true;
  # };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "bb010g";
    userEmail = "me@bb010g.com";
    extraConfig = {
      core = {
        commentChar = "auto";
      };
      diff = {
        algorithm = "histogram";
        submodule = "log";
      };
      status = {
        submoduleSummary = "true";
        showStash = "true";
      };
      push = {
        recurseSubmodules = "check";
      };
      github = {
        user = "bb010g";
      };
    };
  };

  xdg.configFile."git/ignore".text = lib.readFile ./gitignore_global;

  manual = {
    html.enable = true;
    manpages.enable = true;
  };

  programs.htop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
    package = pkgs-unstable.jq;
  };

  programs.mercurial = {
    enable = true;
    userName = "Brayden Banks";
    userEmail = "me@bb010g.com";
  };

  programs.neovim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;
    configure = {
      customRC = ''
"" window management
" don't unload buffers when abandoned (hid)
set hidden
" more natural new splits (sb spr)
set splitbelow splitright

"" window viewport
" cursor line margin (so siso)
set scrolloff=5 sidescrolloff=4
      '';
    };
  };

  programs.obs-studio = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = [
      { host = "aur.archlinux.org";
        identityFile = "~/.ssh/aur";
        user = "aur";
      }
      { host = "wank";
        hostname = "wank.party";
      }
    ];
  };

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs)
      collection-bibtexextra
      collection-context
      collection-fontsextra
      collection-formatsextra
      collection-games
      collection-humanities
      collection-latexextra
      collection-luatex
      collection-mathscience
      collection-music
      collection-pictures
      collection-pstricks
      collection-publishers
      scheme-small
      scheme-tetex
    ; };
  };

  programs.tmux = {
    enable = true;
  };

  programs.zsh = let
    inherit (lib) concatStringsSep;
    filterAttrs = f: e: lib.filter (n: f n e.${n}) (lib.attrNames e);
    trueAttrs = filterAttrs (n: v: v == true);
    zshAutoFunctions = {
      run-help = true;
      zargs = true;
      zcalc = true;
      zed = true;
      zmathfunc = true;
      zmv = true;
    };
    zshModules = {
      "zsh/complist" = true;
      "zsh/files" = ["-Fm" "b:zf_\*"];
      "zsh/mathfunc" = true;
      "zsh/termcap" = true;
      "zsh/terminfo" = true;
    };
    zshOptions = [
      "APPEND_HISTORY"
      "AUTO_PUSHD"
      "COMPLETE_IN_WORD"
      "NO_BEEP"
      "EXTENDED_GLOB"
      "GLOB_COMPLETE"
      "GLOB_STAR_SHORT"
      "HIST_IGNORE_SPACE"
      "HIST_REDUCE_BLANKS"
      "HIST_SUBST_PATTERN"
      "HIST_VERIFY"
      "INTERACTIVE_COMMENTS"
      "KSH_GLOB"
      "LONG_LIST_JOBS"
      "NULL_GLOB"
      "PIPE_FAIL"
      "PROMPT_CR"
      "PROMPT_SP"
      "NO_RM_STAR_SILENT"
      "RM_STAR_WAIT"
    ];
  in {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    completionInit = ''
      setopt EXTENDED_GLOB
      autoload -U compinit
      for dump in ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+1); do
        compinit
        if [[ -s "$dump" && (! -s "$dump.zwc" || "$dump" -nt "$dump.zwc") ]]; then
          touch "$dump"
          zcompile "$dump"
        else
          touch "$dump"
          touch "$dump.zwc"
        fi
      done
      compinit -C
    '';
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
      size = 100000;
    };
    initExtra = ''
      setopt ${concatStringsSep " " zshOptions}

      unalias run-help
      zmodload ${concatStringsSep " " (trueAttrs zshModules)}${
      concatStringsSep "\n" ([""] ++ (map
        (n: "zmodload ${lib.head zshModules.${n}} ${n} ${concatStringsSep " " (lib.tail zshModules.${n})}")
        (filterAttrs (n: v: lib.isList v) zshModules)
      ))}
      autoload -Uz ${concatStringsSep " " (trueAttrs zshAutoFunctions)}

      zmathfunc

      alias sudo='sudo '
      eval "$(dircolors -b)"
      alias ls='ls --color=auto -F '
      alias tree='tree -F '

      # for fast-syntax-highlighting
      zstyle :plugin:history-search-multi-word reset-prompt-protect 1

      zstyle ':completion:*' menu yes select

      # keyboard bindings
      #
      # if Zsh isn't working with your keyboard properly, try the following:
      #   autoload -Uz zkbd; zkbd
      # follow the prompts, and restart if necessary.
      # the file name printed at the end should match the output of:
      #   echo - "''${ZDOTDIR:-$HOME}/.zkbd/$TERM-$VENDOR-$OSTYPE"
      # move the file if necessary.
      typeset -g -A key
      load-bindkeys() {
        local zkbd_file="''${ZDOTDIR:-$HOME}/.zkbd/''${1:-$TERM-$VENDOR-$OSTYPE}"
        if [[ -e "$zkbd_file" ]]; then source "$zkbd_file"; fi

        _key-set() {
          local k="$1"; shift
          if (( ''${+key[$k]} )); then return; fi
          while (( ''${+1} )); do
            1="$(cat -v <<< "$1")"
            # print -r "key: changing $k from ''${(q+)key[$k]} to ''${(q+)1}"
            key[$k]="$1"
            if [[ -n "$1" ]]; then break; else shift; fi
          done
        }

        _key-set F1 "''${terminfo[kf1]}" "''${termcap[k1]}"
        _key-set F2 "''${terminfo[kf2]}" "''${termcap[k2]}"
        _key-set F3 "''${terminfo[kf3]}" "''${termcap[k3]}"
        _key-set F4 "''${terminfo[kf4]}" "''${termcap[k4]}"
        _key-set F5 "''${terminfo[kf5]}" "''${termcap[k5]}"
        _key-set F6 "''${terminfo[kf6]}" "''${termcap[k6]}"
        _key-set F7 "''${terminfo[kf7]}" "''${termcap[k7]}"
        _key-set F8 "''${terminfo[kf8]}" "''${termcap[k8]}"
        _key-set F9 "''${terminfo[kf9]}" "''${termcap[k9]}"
        _key-set F10 "''${terminfo[kf10]}" "''${termcap[F1]}"
        _key-set F11 "''${terminfo[kf11]}" "''${termcap[F2]}"
        _key-set F12 "''${terminfo[kf12]}" "''${termcap[F3]}"
        _key-set Backspace "''${terminfo[kbs]}" "''${termcap[kb]}"
        _key-set Insert "''${terminfo[kich1]}" "''${termcap[kI]}"
        _key-set Home "''${terminfo[khome]}" "''${termcap[kh]}"
        _key-set PageUp "''${terminfo[kpp]}" "''${termcap[kP]}"
        _key-set Delete "''${terminfo[kdch1]}" "''${termcap[kD]}"
        _key-set End "''${terminfo[kend]}" "''${termcap[@7]}"
        _key-set PageDown "''${terminfo[knp]}" "''${termcap[kN]}"
        _key-set BackTab "''${terminfo[cbt]}" "''${termcap[bt]}"
        _key-set Tab "''${terminfo[ht]}" "''${termcap[ta]}"
        _key-set Up "''${terminfo[kcuu1]}" "''${termcap[ku]}"
        _key-set Left "''${terminfo[kcub1]}" "''${termcap[kl]}"
        _key-set Down "''${terminfo[kcud1]}" "''${termcap[kd]}"
        _key-set Right "''${terminfo[kcuf1]}" "''${termcap[kr]}"

        bindkey -M menuselect '/' history-incremental-search-backward
        bindkey -M menuselect '?' history-incremental-search-forward
        [[ -n "''${key[BackTab]}" ]] && bindkey -M menuselect "''${key[BackTab]}" reverse-menu-complete

        unset -f _key-set
      }
      load-bindkeys

      # make sure term is in application mode when zle is active (for terminfo)
      # (thanks http://zshwiki.org/home/zle/bindkeys )
      if (( ''${+terminfo[smkx]} )) && (( ''${+terminfo[rmkx]} )); then
        zle-line-init() { echoti smkx }; zle -N zle-line-init
        zle-line-finish() { echoti rmkx }; zle -N zle-line-finish
      fi
    '';
    localVariables = {
      AGKOZAK_MULTILINE = "0";
      GENCOMPL_FPATH = "${config.xdg.cacheHome}/zsh-completion-generator";
      GENCOMPL_PY = "${pkgs.python3}/bin/python";
      TIMEFMT = ''
        %J   %U  user %S system %P cpu %*E total
        avg shared (code):         %X KB
        avg unshared (data/stack): %D KB
        total (sum):               %K KB
        max memory:                %M MB
        page faults from disk:     %F
        other page faults:         %R'';
    };
    plugins = [
      # ordered
      rec {
        name = "history-search-multi-word";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma";
          repo = name;
          rev = "159aaa5e723ab05b4fe930bb232835d98a0e745d";
          sha256 = "007h248zvw6vnwg2kcybxcr49y7xxxysdxhpw9hja8zp2yk45vr3";
        };
        file = "${name}.plugin.zsh";
      }
      rec {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = name;
          rev = "70f36c007db30a5fe1edf2b63664088b502a729c";
          sha256 = "1j8pnd19f0cr91hxwj3cc8vzysc4hzbiwgv5sqbd5gw160mfg3g3";
        };
        file = "${name}.plugin.zsh";
      }
      # unordered
      rec {
        name = "autoenv";
        src = builtins.toPath "${config.home.homeDirectory}/Documents/zsh-${name}";
        # src = pkgs.fetchFromGitHub {
        #   owner = "Tarrasch";
        #   repo = "zsh-${name}";
        #   rev = "e9809c1bd28496e025ca05576f574e08e93e12e8";
        #   sha256 = "1vcfk9g26zqn6l7pxjqidw8ay3yijx95ij0d7mns8ypxvaax242b";
        # };
        file = "${name}.plugin.zsh";
      }
      rec {
        name = "nix-shell";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-${name}";
          rev = "dceed031a54e4420e33f22a6b8e642f45cc829e2";
          sha256 = "10g8m632s4ibbgs8ify8n4h9r4x48l95gvb57lhw4khxs6m8j30q";
        };
        file = "${name}.plugin.zsh";
      }
      # rec {
      #   name = "zsh-completion-generator";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "RobSis";
      #     repo = name;
      #     rev = "6eb6392026f3f4b9c2d3d34a05be288246144d2c";
      #     sha256 = "1lmy3fqy3dj0b1nysrcr8y1v9sb8kmdqmxf7cj6yp82pn3cz8b3q";
      #   };
      #   file = "${name}.plugin.zsh";
      # }
      # ordered
      rec {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma";
          repo = name;
          rev = "ee4f7c76362f40d905f9c45a59b365abebb213ae";
          sha256 = "115y77m8xab7cap75hb1yagdb6b4fld0nhxqszrj38hnr7hxbsbn";
        };
        file = "${name}.plugin.zsh";
      }
      rec {
        name = "agkozak-zsh-prompt";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = name;
          rev = "13014b7fbf54b9f6214bff44ba4d522da4fd1ec3";
          sha256 = "1cgza63pm9vhkak98lcysg357xrxzcn7pwdsm9lkblq36sqgqpr4";
        };
        file = "${name}.plugin.zsh";
      }
    ];
  };

  services.compton.enable = true;

  services.dunst = {
    enable = true;
    # settings = {
    #   global =
    # };
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  services.keybase.enable = true;
  services.kbfs.enable = true;

  services.mpd = {
    enable = true;
    daemons = rec {
      default = {
        extraConfig = ''
          audio_output {
            type "pulse"
            name "PulseAudio"
          }
        '';
        package = pkgs-unstable.mpd;
        musicDirectory = "${config.home.homeDirectory}/Music";
      };
      external = default // {
        autoStart = false;
        musicDirectory = "/run/media/${config.home.username}/music";
        network.port = 6601;
      };
      external-beets = external // {
        musicDirectory = "${external.musicDirectory}/beets";
        network.port = 6602;
      };
    };
  };

  services.redshift = if private ? redshift then with private.redshift; {
    enable = true;
    tray = true;
    inherit latitude;
    inherit longitude;
    temperature = {
      day = 6500;
      night = 3700;
    };
  } else { };

  services.screen-locker = {
    enable = true;
    inactiveInterval = 10;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -f -c 131736";
  };

  services.unclutter = {
    enable = true;
    timeout = 5;
  };

  xsession = {
    enable = true;
    # pointerCursor = {
    #   package = pkgs.capitaine-cursors;
    #   name = "Capataine Cursors";
    # };
    windowManager.i3 = {
      enable = true;
      config = let
        zipToAttrs = lib.zipListsWith (n: v: { ${n} = v; });
        mergeAttrList = lib.foldr lib.mergeAttrs {};
        mergeAttrMap = f: l: mergeAttrList (lib.concatMap f l);

        modifier = "Mod4";
        arrowKeys = [ "Left" "Down" "Up" "Right" ];
        viKeys = [ "h" "j" "k" "l" ];
        workspaceNames = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ];
        workspaceKeys = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ];

        fonts = [ "monospace 10" ];

        dirNames = [ "left" "down" "up" "right" ];
        resizeActions = [ "shrink width" "grow height" "shrink height" "grow width" ];
      in {
        bars = [ { inherit fonts; position = "top"; } ];
        inherit fonts;
        keybindings = mergeAttrList [
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+${k}") ks) (map (d: "focus ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Shift+${k}") ks) (map (d: "move ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Ctrl+${k}") ks) (map (d: "move container to output ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+${k}") workspaceKeys) (map (d: "workspace ${d}") workspaceNames)))
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+Shift+${k}") workspaceKeys) (map (d: "move workspace ${d}") workspaceNames)))
          {
            "${modifier}+Return" = "exec st";
            "${modifier}+Shift+q" = "kill";
            "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

            "${modifier}+a" = "focus parent";

            "${modifier}+r" = "mode resize";

            "${modifier}+g" = "split h";
            "${modifier}+v" = "split v";
            "${modifier}+f" = "fullscreen toggle";

            "${modifier}+s" = "layout stacking";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+e" = "layout toggle split";

            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";

            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";
            "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
          }
        ];
        modes = {
          resize = mergeAttrList [
            (mergeAttrMap (ks: zipToAttrs ks (map (a: "resize ${a}") resizeActions)) [ viKeys arrowKeys ])
            {
              "Escape" = "mode default";
              "Return" = "mode default";
            }
          ];
        };
        inherit modifier;
      };
    };
  };

  # Home Manager config

  programs.home-manager = {
    enable = true;
    path = if lib.pathExists ~/nix/home-manager then "$HOME/nix/home-manager" else <home-manager>;
  };
}

# vim:et:sw=2