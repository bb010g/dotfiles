{ config, lib, pkgs, ... }:

let
  # > nix-channel --list
  # nixos-unstable https://nixos.org/channels/nixos-unstable
  #
  # might also have some personal patches?
  # if so, they'd be up at https://github.com/bb010g/nixpkgs, branch bb010g-*

  private = if lib.pathExists ./private.nix then import ./private.nix else {
    apis = { };
  };
  versions = builtins.fromJSON (lib.readFile ./versions.json);
  # pkgs-unstable = pkgs;
  pkgs-unstable = import <nixos-unstable> { };
  pkgs-bb010g-unstable = (
    if lib.pathExists <bb010g-nixos-unstable> then
      import <bb010g-nixos-unstable>
    else
      builtins.fetchTarball "https://github.com/bb010g/nixpkgs/archive/bb010g-nixos-unstable.tar.gz"
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
      pkgs.moreutils
      pkgs.nvi
      pkgs-unstable.ripgrep
      pkgs.tree
      pkgs.zsh-completions
    ];

    editors = [
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
      pkgs.font-droid
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
      pkgs-bb010g-unstable.bitwarden-cli
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
      pkgs.nix-prefetch-scripts
      pkgs.yarn2nix
      # TODO figure out how to build nixpkgs manual
    ];

    tex = [
      pkgs.biber
    ];

    tools = [
      pkgs.androidenv.platformTools
      pkgs.asciinema
      # pkgs.asciinema-edit
      pkgs.bind
      pkgs.binutils
      pkgs.colordiff
      pkgs.diffstat
      pkgs.git-lfs
      pkgs.gnumake
      pkgs.hecate
      pkgs.hyperfine
      pkgs.icdiff
      pkgs.ispell
      pkgs.lzip
      (pkgs.mosh.overrideAttrs (o: rec {
        name = "mosh";
        version = "1.3.2+${lib.substring 0 7 src.rev}";
        src = pkgs.fetchFromGitHub {
          owner = "mobile-shell";
          repo = "mosh";
          rev = "944fd6c796338235c4f3d8daf4959ff658f12760";
          sha256 = "0fwrdqizwnn0kmf8bvlz334va526mlbm1kas9fif0jmvl1q11ayv";
        };
      }))
      pkgs.nur.repos.bb010g.just
      pkgs.nur.repos.bb010g.dwdiff
      pkgs.nur.repos.bb010g.ydiff
      pkgs.nur.repos.mic92.inxi
      pkgs.p7zip
      pkgs.ponymix
      pkgs.rclone
      pkgs-unstable.rclone-browser
      pkgs.sbcl
      pkgs.tokei
      pkgs.unzip
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
      pkgs.hicolor-icon-theme
      pkgs.nur.repos.nexromancers.hacksaw
      pkgs.nur.repos.nexromancers.shotgun
      ((pkgs.st.overrideAttrs (o: rec {
        name = "st";
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
      pkgs-bb010g-unstable.grafx2
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
      pkgs-unstable.discord
      pkgs.google-chrome
      pkgs.keybase-gui
      ((pkgs.nur.repos.mozilla.lib.firefoxOverlay.firefoxVersion {
        name = "Firefox Nightly";
        # https://product-details.mozilla.org/1.0/firefox_versions.json
        #  : FIREFOX_NIGHTLY
        inherit (versions.firefox.nightly) version;
        # system: ? arch (if stdenv.system == "i686-linux" then "linux-i686" else "linux-x86_64")
        # https://download.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-${version}.en-US.${system}.buildhub.json
        #  : download -> url -> (parse)
        inherit (versions.firefox.nightly) timestamp;
        release = false;
      }).overrideAttrs (o: { buildCommand = lib.replaceStrings [ ''
        --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
      '' ] [ ''
        --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
        --set SNAP_NAME firefox \
      '' ] o.buildCommand; }))
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
      pkgs.notify-desktop
      pkgs.nur.repos.bb010g.ipscan
      pkgs.nur.repos.bb010g.xcolor
      pkgs.pavucontrol
      pkgs.pcmanfm
      pkgs.qdirstat
      pkgs.remmina
      pkgs.surf
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
    package = pkgs.nur.repos.bb010g.beets;
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
    userName = "Brayden Banks";
    userEmail = "me@bb010g.com";
    extraConfig = {
      diff = {
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
    zshAutoFunctions = [
      "zargs"
      "zcalc"
      "zed"
      "zmathfunc"
      "zmv"
    ];
    zshOptions = [
      "AUTO_PUSHD"
      "EXTENDED_GLOB"
      "HIST_IGNORE_SPACE"
      "HIST_REDUCE_BLANKS"
      "HIST_SUBST_PATTERN"
      "HIST_VERIFY"
      "LONG_LIST_JOBS"
      "NULL_GLOB"
      "PROMPT_SP"
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
      ignoreDups = true;
      share = true;
    };
    initExtra = ''
      setopt ${lib.concatStringsSep " " zshOptions}

      autoload -U ${lib.concatStringsSep " " zshAutoFunctions}

      zmathfunc
      zmodload zsh/mathfunc

      alias sudo='sudo '

      # for fast-syntax-highlighting
      zstyle :plugin:history-search-multi-word reset-prompt-protect 1
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
      rec {
        name = "zsh-nix-shell";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = name;
          rev = "dceed031a54e4420e33f22a6b8e642f45cc829e2";
          sha256 = "10g8m632s4ibbgs8ify8n4h9r4x48l95gvb57lhw4khxs6m8j30q";
        };
        file = "${name}.plugin.zsh";
      }
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
    daemons = let
      extraConfig = ''
        audio_output {
          type "pulse"
          name "PulseAudio"
        }
      '';
    in rec {
      default = {
        inherit extraConfig;
        musicDirectory = "${config.home.homeDirectory}/Music";
      };
      external = {
        inherit extraConfig;
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

            "${modifier}+r" = "mode resize";
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
