{ config, lib ? null, pkgs ? null, ... } @ args:
let
  trace = args.trace or (_: x: x);
  # trace = args.trace or builtins.trace;
  argPkgs = trace "home argPkgs"
    (if args.pkgs == null then
      trace "home argPkgs null" null
    else args.pkgs);
  argLib = trace "home argLib"
    (if args.lib == null then
      trace "home argLib pkgs.lib" pkgs.lib
    else args.lib);
in

let
  # > nix-channel --list
  # nixos-unstable https://nixos.org/channels/nixos-unstable
  #
  # might also have some personal patches?
  # if so, they'd be up at https://github.com/bb010g/nixpkgs, branch bb010g-*

  private = trace "home private" (if lib.pathExists ./private.nix then
    trace "home private imported" (import ./private.nix)
  else
    trace "home private default" {
      apis = { };
    });
  sources = trace "home sources" (import ./nix/sources.nix);

  pinned = trace "home pinned" (let p = if args ? "pinned" then
    trace "pinned args" args.pinned
  else
    trace "pinned default" false; in
  trace "pinned ${if p then "true" else "false"}" p);

  nur = trace "home nur" (import ./config-nur.nix {
    pkgs = trace "nur-bb010g pkgs null" null;
    nur-local = trace "nur nur-local null" null;
    nur-remote = trace "nur nur-remote sources.nur" sources.nur;
    inherit trace;
  });

  pkgs = trace "home pkgs" (if pinned || argPkgs == null then
    trace "pkgs sources.nixpkgs" sources.nixpkgs
  else
    trace "pkgs argPkgs" argPkgs);
  lib = trace "home lib pkgs.lib" pkgs.lib;
  pkgs-stable = trace "home pkgs-stable" (import (
    if !pinned && lib.pathExists <nixos-19.03> then
      trace "pkgs-stable <nixos-19.03>" <nixos-19.03> else
    if !pinned && lib.pathExists <nixos> then
      trace "pkgs-stable <nixos>" <nixos> else
    if !pinned && lib.pathExists <nixpkgs> then
      trace "pkgs-stable <nixpkgs>" <nixpkgs> else
    trace "pkgs-stable sources.nixpkgs-stable" sources.nixpkgs-stable
  ) { });
  lib-stable = trace "home lib-stable pkgs-stable.lib" pkgs-stable.lib;
  pkgs-unstable = trace "home pkgs-unstable" (import (
    if !pinned && lib.pathExists <nixos-unstable> then
      trace "pkgs-unstable <nixos-unstable>" <nixos-unstable> else
    trace "pkgs-stable sources.nixpkgs-unstable" sources.nixpkgs-unstable
  ) { });
  lib-unstable = trace "home lib-unstable pkgs-unstable.lib"
    pkgs-unstable.lib;
  pkgs-unstable-bb010g = trace "home pkgs-unstable-bb010g" (import (
    if !pinned && lib.pathExists <bb010g-nixos-unstable> then
      trace "pkgs-unstable-bb010g <bb010g-nixos-unstable>"
        <bb010g-nixos-unstable> else
    trace "pkgs-unstable-bb010g sources.nixpkgs-unstable-bb010g"
      sources.nixpkgs-unstable-bb010g
  ) { });
  lib-unstable-bb010g =
    trace "home lib-unstable-bb010g pkgs-unstable-bb010g.lib"
      pkgs-unstable-bb010g.lib;
in
{
  imports = let
    bb010g = nur.repos.bb010g.modules.home-manager;
  in trace "home imports" [
    bb010g.programs.pijul
  ];

  # dconf. 24-hour time

  home.keyboard = trace "home home.keyboard" {
    layout = "us,gr";
    options = [
      "compose:ralt"
      "ctrl:swap_lalt_lctl"
      "caps:swapescape"
      "grp:rctrl_rshift_toggle"
    ];
  };

  home.packages = trace "home home.packages" (let
    core = [
      pkgs.ed # ed is the STANDARD text editor
      pkgs.file
      pkgs.manpages
      pkgs.moreutils
      pkgs.nvi
      pkgs.posix_man_pages
      (pkgs-unstable.ripgrep.override { withPCRE2 = true; })
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
      pkgs.bcachefs-tools
      pkgs.cifs-utils
      pkgs.dosfstools
      # pkgs.e2fsprogs
      pkgs.e2tools
      pkgs.exfat-utils
      pkgs.f2fs-tools
      pkgs.hfsprogs
      pkgs.mtdutils
      pkgs.nfs-utils
      pkgs.squashfsTools
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

    hunspellDicts = [
      pkgs.hunspellDicts.en-us
      pkgs.hunspellDicts.es-any
    ];

    media = [
      pkgs.ffmpeg
      pkgs.mpc_cli
    ];

    misc = [
      pkgs-unstable.bitwarden-cli
      pkgs.nur.repos.bb010g.broca-unstable
      pkgs.cowsay
      pkgs-unstable.edbrowse
      pkgs.elinks
      pkgs.fortune
      # pkgs-unstable.nur.repos.bb010g.html2json-unstable
      pkgs.lynx
      pkgs.megatools
      pkgs.ponysay
      pkgs.smbclient
      pkgs-unstable.synapse-bt
      pkgs.units
    ];

    nix = [
      pkgs.cabal2nix
      pkgs.cachix
      ((pkgs.diffoscope.override { enableBloat = true; }).overrideAttrs (o: {
        pythonPath = o.pythonPath ++ [ pkgs.zip ];
      }))
      pkgs.lorri
      pkgs.niv.niv
      pkgs-unstable.nix-diff
      pkgs-unstable.nix-index
      pkgs-unstable.nix-prefetch-github
      pkgs-unstable.nix-prefetch-scripts
      pkgs-unstable.nix-top
      pkgs-unstable.nix-universal-prefetch
      pkgs-unstable.vulnix
      pkgs.yarn2nix
      # TODO figure out how to build nixpkgs manual
    ];

    tex = [
      pkgs.biber
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
      pkgs.nur.repos.bb010g.dwdiff
      pkgs.gitAndTools.git-imerge
      pkgs.nur.repos.bb010g.git-my
      pkgs.nur.repos.bb010g.git-revise
      pkgs.gnumake
      pkgs.hecate
      pkgs-unstable.hyperfine
      pkgs.icdiff
      pkgs.nur.repos.mic92.inxi
      pkgs.ispell
      pkgs-unstable.just
      pkgs.lzip
      pkgs-unstable.nur.repos.bb010g.mosh-unstable
      pkgs.ngrok
      pkgs.p7zip
      pkgs.ponymix
      pkgs.rclone
      pkgs.sbcl
      pkgs-unstable.sublime-merge
      pkgs.tokei
      pkgs.nur.repos.bb010g.ttyd
      pkgs.unzip
      pkgs.nur.repos.bb010g.ydiff
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
      pkgs-unstable.nur.repos.nexromancers.hacksaw
      pkgs.hicolor-icon-theme
      pkgs-unstable.nur.repos.nexromancers.shotgun
      pkgs.nur.repos.bb010g.st-bb010g-unstable
      pkgs.xsel
    ];

    gui-editors = [
      pkgs.texstudio
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
      pkgs-unstable-bb010g.grafx2
      pkgs.inkscape
      pkgs.kdeApplications.kolourpaint
      pkgs.krita
      (pkgs-unstable.mpv.override rec {
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
        inherit (sources.firefox-nightly) version;
        # system: ? arch (if stdenv.system == "i686-linux" then "linux-i686" else "linux-x86_64")
        # https://download.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-${version}.en-US.${system}.buildhub.json
        #  : download -> url -> (parse)
        #  - https://archive.mozilla.org/pub/firefox/nightly/%Y/%m/%Y-%m-%d-%H-%m-%s-mozilla-central/firefox-${version}.en-US.${system}.tar.bz2
        #  : build -> date -> (parse) also works
        #  - %Y-%m-%dT%H:%m:%sZ
        #  need %Y-%m-%d-%H-%m-%s
        inherit (sources.firefox-nightly) timestamp;
        release = false;
      }).overrideAttrs (o: {
        buildCommand = lib.replaceStrings [ ''
          --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
        '' ] [ ''
          --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
          --set SNAP_NAME firefox \
        '' ] o.buildCommand;
      }))
      pkgs.google-chrome
      pkgs.gucharmap
      pkgs.keybase-gui
      # for Firefox MozLz4a JSON files (.jsonlz4)
      pkgs-unstable.nur.repos.bb010g.mozlz4-tool
      (pkgs-unstable.qutebrowser.overrideAttrs (o: {
        buildInputs = o.buildInputs ++ hunspellDicts;
      }))
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
    filesystem
    fonts
    gui
    media
    misc
    nix
    tools
  ]);

  home.sessionVariables = {
    EDITOR = "ed";
    ${if lib.hasAttrByPath [ "apis" "github" "env-token" ] private
      then "GITHUB_TOKEN" else null} = private.apis.github.env-token;
    NIX_PATH = "${config.home.homeDirectory}/nix/channels:$NIX_PATH";
    PAGER = "less -RF";
    VISUAL = "nvim";
  };

  manual = trace "home manual" {
    html.enable = true;
    manpages.enable = true;
  };

  programs.autorandr = trace "home programs.autorandr" {
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

  programs.beets = trace "home programs.beets" {
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

  programs.direnv = trace "programs.direnv" { enable = true; };

  programs.emacs = trace "programs.emacs" { enable = true; };

  programs.feh = trace "home programs.feh" { enable = true; };

  # programs.firefox = trace "home programs.firefox" {
  #   enable = true;
  #   package = moz_nixpkgs.latest.firefox-nightly-bin;
  #   enableAdobeFlash = true;
  # };

  programs.git = trace "home programs.git" {
    enable = true;
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
    lfs = {
      enable = true;
    };
    package = pkgs.gitAndTools.gitFull;
    userEmail = "me@bb010g.com";
    userName = "bb010g";
  };

  # Home Manager config
  programs.home-manager = trace "home programs.home-manager" {
    enable = true;
    path = if lib.pathExists ~/nix/home-manager then "$HOME/nix/home-manager" else <home-manager>;
  };

  programs.htop = trace "home programs.htop" {
    enable = true;
  };

  programs.jq = trace "home programs.jq" {
    enable = true;
    package = pkgs-unstable.jq;
  };

  programs.mercurial = trace "home programs.mercurial" {
    enable = true;
    userName = "Brayden Banks";
    userEmail = "me@bb010g.com";
  };

  programs.neovim = trace "home programs.neovim" (let
    pkgsNvim = pkgs-unstable;
    nvimUnwrapped = pkgsNvim.neovim-unwrapped;
    nvim = pkgsNvim.wrapNeovim nvimUnwrapped {
      vimAlias = true;
    };
  in {
    enable = true;
    package = nvimUnwrapped;
    configure = {
      customRC = /*vim*/''
"" general mappings (set before other uses)
" <Leader> 
let mapleader = "\<Space>"

"" context_filetype
" language support
if !exists('g:context_filetype#filetypes')
  let g:context_filetype#filetypes = {}
endif
let g:context_filetype#filetypes.nix = [
\ {
\   'start': '/\*\(\h\w*\)\*/'."'"."'",
\   'end': "'"."'".'\%($\|[^$'."'".']\|.\@!$\)',
\   'filetype': '\1',
\ }
\]
let g:context_filetype#filetypes.sh = [
\ {
\   'start': '<<\s*\(['."'".'"]\)\(\h\w*\)\1\s*#\s*vim:\s*ft=\(\h\w*\)\n',
\   'end': '\n\2',
\   'filetype': '\3',
\ }
\]

"" diff output
" patience algorithm
if has("patch-8.1.0360")
  set diffopt+=internal,algorithm:patience
endif

"" swapfiles
" don't bother with unmodified, detached swapfiles
let g:RecoverPlugin_Delete_Unmodified_Swapfile = 1

"" window management
" don't unload buffers when abandoned (hid)
set hidden
" more natural new splits (sb spr)
set splitbelow splitright
" suckless.vim: mappings
" - divid[e]d (default): all windows share available vertical space in column
" - [s]tacked: in col, active window maximizes and others collapse to one row
" - [f]ullscreen: active window maximizes height & width and others collapse
let g:suckless_mappings = {
\ '<M-[esf]>' : 'SetTilingMode("[dsf]")',
\ '<M-[hjkl]>' : 'SelectWindow("[hjkl]")',
\ '<M-[HJKL]>' : 'MoveWindow("[hjkl]")',
\ '<C-M-[hjkl]>' : 'ResizeWindow("[hjkl]")',
\ '<M-[gv]>' : 'CreateWindow("[sv]")',
\ '<M-q>' : 'CloseWindow()',
\ '<Leader>[123456789]' : 'SelectTab([123456789])',
\ '<Leader>t[123456789]' : 'MoveWindowToTab([123456789])',
\ '<Leader>T[123456789]' : 'CopyWindowToTab([123456789])',
\}
" suckless.vim: use Alt (<M-) shortcuts in terminals
let g:suckless_tmap = 1
" termopen.vim: easy terminal splits
nmap <silent> <M-Return> :call TermOpen()<CR>

"" window viewport
" cursor line margin (so siso)
set scrolloff=5 sidescrolloff=4

      '';
      packages."plugins-bb010g" = let
        inherit (pkgsNvim.vimUtils.override { vim = nvim; }) buildVimPluginFrom2Nix;
        basicVimPlugin = pname: version: src:
          buildVimPluginFrom2Nix {
            pname = lib.removePrefix "vim-" pname;
            inherit version src;
          };
        sourcesVimPlugin = pname: let
            src = sources.${pname};
            date = lib.elemAt (builtins.split "T" src.date) 0;
          in basicVimPlugin pname date src;
      in {
        start = map sourcesVimPlugin [
          "vim-ale"
          "vim-caw"
          "vim-characterize"
          "vim-context-filetype"
          "vim-diffchar"
          "vim-dirdiff"
          "vim-dirvish"
          "vim-editorconfig"
          "vim-exchange"
          "vim-gina"
          "vim-linediff"
          "vim-lion"
          "vim-magnum"
          "vim-operator-user"
          "vim-polyglot"
          "vim-precious"
          "vim-radical"
          "vim-recover"
          "vim-remote-viewer"
          "vim-repeat"
          "vim-sandwich"
          "vim-startuptime"
          "vim-suckless"
          "vim-suda"
          "vim-table-mode"
          "vim-targets"
          "vim-termopen"
          "vim-undotree"
          "vim-visualrepeat"
        ];
        opt = map sourcesVimPlugin [
        ];
      };
    };
  });

  programs.obs-studio = trace "home programs.obs-studio" {
    enable = true;
  };

  #programs.pijul = trace "home programs.pijul" {
  #  enable = true;
  #  # configDir = "${config.xdg.configHome}/pijul";
  #  package = pkgs-unstable.pijul;
  #  global = {
  #    author = "bb010g <me@bb010g.com>";
  #    signing_key = "/home/bb010g/.config/pijul/config/signing_secret_key";
  #  };
  #};

  programs.ssh = trace "home programs.ssh" {
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

  programs.texlive = trace "home programs.texlive" {
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

  programs.tmux = trace "home programs.tmux" {
    enable = true;
  };

  programs.zsh = trace "home programs.zsh" (let
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
      "zsh/files" = ["-Fm" "b:zf_\\*"];
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
    completionInit = /*zsh*/''
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
    initExtra = /*zsh*/''
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
        src = sources.zsh-history-search-multi-word;
        file = "${name}.plugin.zsh";
      }
      rec {
        name = "autosuggestions";
        src = sources.zsh-autosuggestions;
        file = "zsh-${name}.plugin.zsh";
      }
      # unordered
      rec {
        name = "autoenv";
        src = builtins.toPath "${config.home.homeDirectory}/Documents/zsh-${name}";
        # src = sources.zsh-autoenv;
        file = "${name}.plugin.zsh";
      }
      rec {
        name = "nix-shell";
        src = sources.zsh-nix-shell;
        file = "${name}.plugin.zsh";
      }
      # rec {
      #   name = "completion-generator";
      #   src = sources.zsh-completion-generator;
      #   file = "zsh-${name}.plugin.zsh";
      # }
      # ordered
      rec {
        name = "fast-syntax-highlighting";
        src = sources.zsh-fast-syntax-highlighting;
        file = "${name}.plugin.zsh";
      }
      rec {
        name = "agkozak-zsh-prompt";
        src = sources.zsh-agkozak-zsh-prompt;
        file = "${name}.plugin.zsh";
      }
    ];
  });

  services.compton = trace "home services.compton" {
    enable = true;
    package = pkgs.compton-git;
  };

  services.dunst = trace "home services.dunst" {
    enable = true;
    # settings = {
    #   global =
    # };
  };

  services.kbfs = trace "home services.kbfs" { enable = true; };

  services.kdeconnect = trace "home services.kdeconnect" {
    enable = true;
    indicator = true;
  };

  services.keybase = trace "home services.keybase" { enable = true; };

  services.mpd = trace "home services.mpd" {
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

  services.redshift = trace "home services.redshift"
    (if private ? redshift then trace "redshift private"
      (with private.redshift; {
        enable = true;
        tray = true;
        inherit latitude;
        inherit longitude;
        temperature = {
          day = 6500;
          night = 3700;
        };
      })
    else "redshift default" { });

  services.screen-locker = trace "home services.screen-locker" {
    enable = true;
    inactiveInterval = 10;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -f -c 131736";
  };

  services.unclutter = trace "home services.unclutter" {
    enable = true;
    timeout = 5;
  };

  systemd.user.services.broca = trace "home systemd.user.services.broca" {
    Unit = {
      Description = "Bittorrent RPC proxy between Transmission clients and " +
        "Synapse servers";
      After = [ "synapse.service" ];
    };

    Service = {
      Type = "simple";
      Environment = [ "RUST_BACKTRACE=1" ];
      ExecStart = [
        "${pkgs.nur.repos.bb010g.broca-unstable}/bin/broca-daemon"
      ];
      WorkingDirectory = "%h";
      Restart = "always";
    };

    # Install = {
    #   WantedBy = [ "default.target" ];
    # };
  };

  systemd.user.services.synapse-bt = trace "home systemd.user.services.synapse-bt" {
    Unit = {
      Description = "Flexible and fast BitTorrent daemon";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      Environment = [ "RUST_BACKTRACE=1" ];
      ExecStart = [
        "${pkgs-unstable.synapse-bt}/bin/synapse"
      ];
      WorkingDirectory = "%h";
      Restart = "always";
    };

    # Install = {
    #   WantedBy = [ "default.target" ];
    # };
  };

  xdg = {
    enable = true;

    configFile = {
      "fontconfig/fonts.conf".text = /*xml*/''
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

      "nix/nix.conf".text = /*conf*/''
auto-optimise-store = true
keep-derivations = true
keep-outputs = true
'';
    };
  };

  xdg.configFile."git/ignore".text = lib.readFile ./gitignore_global;

  xsession = trace "home xsession" {
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
}

# vim:et:sw=2:tw=78
