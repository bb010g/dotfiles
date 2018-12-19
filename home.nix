{ config, lib, pkgs, ... }:

let
  # > nix-channel --list
  # nixos-unstable https://nixos.org/channels/nixos-unstable

  private = if lib.pathExists ./private.nix then import ./private.nix else {};
  # pkgs-unstable = pkgs;
  pkgs-unstable = import <nixos-unstable> { };
in
{
  fonts.fontconfig.enableProfileFonts = true;
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
      pkgs.nvi
      pkgs.ripgrep
      pkgs.tree
    ];

    editors = [
      pkgs.kakoune
      # emacs is a service
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
      pkgs.raleway
    ];

    misc = [
      pkgs.cowsay
      # pkgs.edbrowse
      pkgs.fortune
      pkgs.ponysay
    ];

    nix = [
      pkgs.cabal2nix
      pkgs.nix-prefetch-scripts
      pkgs.yarn2nix
      # TODO figure out how to build nixpkgs manual
    ];

    tools = [
      pkgs.gnumake
      pkgs.hecate
      pkgs.hyperfine
      pkgs.jq
      pkgs.nur.repos.bb010g.just
      pkgs.ponymix
      pkgs.unzip
      pkgs.nur.repos.bb010g.dwdiff
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
        version = "0.8.1+${lib.substring 0 7 src.rev}";
        src = pkgs.fetchgit {
          url = "https://git.suckless.org/st";
          rev = "d7bf023b2f2d41cb6983bb3ce2c6d1bf049150b3";
          sha256 = "1vi1flpdp3y78ch1mz4vrnjlwwdif1hk3mm8kbxsg22m2sn9p895";
        };
      })).override {
        conf = lib.readFile st/config.h;
        patches = [ st/st-scrollback.diff st/st-vertcenter.diff ];
      })
      pkgs.xsel
    ];

    gui-games = [
      pkgs.scummvm
    ];

    gui-media = [
      pkgs.geeqie
      pkgs.gimp
      pkgs.grafx2
      pkgs.inkscape
      pkgs.kdeApplications.kolourpaint
      pkgs.krita
      pkgs.mpc_cli
      pkgs.mpv
      pkgs.mtpaint
      pkgs.pinta
      pkgs.sxiv
      pkgs.youtube-dl
    ];

    gui-misc = [
      pkgs.discord
      pkgs.nur.repos.mozilla.latest.firefox-nightly-bin
      pkgs.tdesktop
    ];

    gui-tools = [
      pkgs.cantata
      pkgs.cmst
      pkgs.gnome3.gnome-system-monitor
      pkgs.ksysguard
      pkgs.notify-desktop
      pkgs.nur.repos.bb010g.xcolor
      pkgs.pavucontrol
      pkgs.pcmanfm
      pkgs.qdirstat
      pkgs.surf
      pkgs.xorg.xbacklight
    ];
  in lib.concatLists [
    core
    editors
    fonts
    gui
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

  programs.mercurial = {
    enable = true;
    userName = "Brayden Banks";
    userEmail = "me@bb010g.com";
  };

  programs.neovim = {
    enable = true;
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

  # programs.texlive = {
  #   enable = true;
  #   extraPackages = tpkgs: { inherit (tpkgs) ; }
  # };

  programs.tmux = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra = "setopt promptsp";
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
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      audio_output {
        type "pulse"
	name "PulseAudio"
      }
    '';
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
