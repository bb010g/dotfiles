{ config, lib, pkgs, ... } @ args:
let
  srcs = import ./sources.nix;
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
  imports = [
    ./conf/autorandr.nix
    ./conf/beets.nix
    ./conf/input.nix
    ./conf/mpd.nix
    ./conf/neovim.nix
    ./conf/packages.nix
    # TODO: unbreak (possibly involves nur.modules.bb010g)
    # ./conf/pijul.nix
    ./conf/redshift.nix
    ./conf/session-variables.nix
  ];

  # dconf. 24-hour time

  # home.sessionVariables = you probably want systemd.user.sessionVariables

  home.stateVersion = "19.09";

  manual = {
    html.enable = true;
    manpages.enable = true;
  };

  programs.direnv = { enable = true; };

  programs.emacs = { enable = true; };

  programs.feh = { enable = true; };

  programs.firefox = {
    enable = true;
    package = ((pkgs.nur.lib.mozilla.firefoxOverlay.firefoxVersion {
      name = "Firefox Nightly";
      # https://product-details.mozilla.org/1.0/firefox_versions.json
      #  : FIREFOX_NIGHTLY
      inherit (sources-ext.firefox-nightly) version;
      # system: ? arch (if stdenv.system == "i686-linux" then "linux-i686" else "linux-x86_64")
      # https://download.cdn.mozilla.net/pub/firefox/nightly/latest-mozilla-central/firefox-${version}.en-US.${system}.buildhub.json
      #  : download -> url -> (parse)
      #  - https://archive.mozilla.org/pub/firefox/nightly/%Y/%m/%Y-%m-%d-%H-%m-%s-mozilla-central/firefox-${version}.en-US.${system}.tar.bz2
      #  : build -> date -> (parse) also works
      #  - %Y-%m-%dT%H:%m:%sZ
      #  need %Y-%m-%d-%H-%m-%s
      inherit (sources-ext.firefox-nightly) timestamp;
      release = false;
    }).overrideAttrs (o: {
      buildCommand = lib.replaceStrings [ ''
        --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
      '' ] [ ''
        --set MOZ_SYSTEM_DIR "$out/lib/mozilla" \
        --set SNAP_NAME firefox \
      '' ] o.buildCommand;
    }));
    # https://github.com/NixOS/nixpkgs/issues/59276
    # enableAdobeFlash = true;
  };

  programs.git = {
    enable = true;
    extraConfig = {
      core = {
        commentChar = "auto";
      };
      diff = {
        algorithm = "histogram";
        submodule = "log";
      };
      github = {
        user = "bb010g";
      };
      merge = {
        tool = "smerge";
      };
      mergetool = {
        smerge = {
          cmd = ''smerge mergetool "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'';
          trustExitCode = "true";
        };
      };
      push = {
        recurseSubmodules = "check";
      };
      status = {
        submoduleSummary = "true";
        showStash = "true";
      };
    };
    lfs = {
      enable = true;
    };
    package = pkgs.gitAndTools.gitFull;
    userEmail = "me@bb010g.com";
    userName = "Dusk Banks";
  };

  # Home Manager config
  programs.home-manager = {
    enable = true;
    path = if lib.pathExists ~/nix/home-manager then "$HOME/nix/home-manager" else <home-manager>;
  };

  programs.htop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
    # package = nixpkgs-unstable.jq;
    package = nixpkgs-unstable.nur.pkgs.bb010g.jq;
  };

  programs.mercurial = {
    enable = true;
    userEmail = "me@bb010g.com";
    userName = "Dusk Banks";
  };

  programs.obs-studio = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "aur.archlinux.org" = {
        identityFile = "~/.ssh/aur";
        user = "aur";
      };
      "wank" = {
        hostname = "wank.party";
      };
    };
  };

  programs.texlive = {
    enable = true;
    # for sane combine
    packageSet = pkgs.nur.pkgs.bb010g.texlive;
    extraPackages = tpkgs: {
      pkgFilter = let inherit (lib) any elem id; in p: any id [
        (p.tlType == "run" || p.tlType == "bin")
        (p.tlType == "doc" && !(elem p.pname [
          # avoid collisions with texlive-bin-YYYY-doc
          "aleph"
          "autosp"
          "latex-bin"
          "synctex"
        ]))
        (p.pname == "core")
      ];
      inherit (tpkgs)
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
        latexmk
        scheme-small
        scheme-tetex
      ;
    };
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

      nix-find-deriver() {
        local p=("''${@:P}");
        nix show-derivation "''${p[@]}" | \
          ${config.programs.jq.package}/bin/jq -r \
      '. as $drvs | $ARGS.positional[] | first((. as $p |
        $drvs | keys_unsorted[] | . as $k |
          select($p | startswith($drvs[$k].outputs[].path))
      ), "unknown-deriver")' --args "''${p[@]}"
      }

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
  };

  services.picom = {
    enable = true;
  };

  services.dunst = {
    enable = true;
    # settings = {
    #   global =
    # };
  };

  services.kbfs = { enable = true; };

  ${null/*services.kdeconnect*/} = {
    enable = true;
    indicator = true;
  };

  services.keybase = { enable = true; };

  services.lorri = { enable = true; };

  services.screen-locker = {
    enable = true;
    inactiveInterval = 10;
    lockCmd = "${pkgs.i3lock}/bin/i3lock -f -c 131736";
  };

  services.unclutter = {
    enable = true;
    timeout = 5;
  };

  systemd.user.services.broca = {
    Unit = {
      Description = "Bittorrent RPC proxy between Transmission clients and " +
        "Synapse servers";
      After = [ "synapse.service" ];
    };

    Service = {
      Type = "simple";
      Environment = [ "RUST_BACKTRACE=1" ];
      ExecStart = [
        "${pkgs.nur.pkgs.bb010g.broca-unstable}/bin/broca-daemon"
      ];
      WorkingDirectory = "%h";
      Restart = "always";
    };

    # Install = {
    #   WantedBy = [ "default.target" ];
    # };
  };

  systemd.user.services.synapse-bt = {
    Unit = {
      Description = "Flexible and fast BitTorrent daemon";
      After = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      Environment = [ "RUST_BACKTRACE=1" ];
      ExecStart = [
        "${nixpkgs-unstable.synapse-bt}/bin/synapse"
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
      "git/ignore".source = ./gitignore_global;

      # "fontconfig/conf.d".source =
      #   "${config.home.homeDirectory}/.nix-profile/etc/fonts/conf.d";

      "nix/nix.conf".text = /*conf*/''
auto-optimise-store = true
keep-derivations = true
keep-outputs = true
'';
    };
  };

  xresources.properties = let
    # https://github.com/dracula/xresources/blob/8de11976678054f19a9e0ec49a48ea8f9e881a05/Xresources
    dracula-xresources = prefix: {
      "${prefix}foreground" = "#F8F8F2";
      "${prefix}background" = "#282A36";
      "${prefix}color0" = "#000000";
      "${prefix}color8" = "#4D4D4D";
      "${prefix}color1" = "#FF5555";
      "${prefix}color9" = "#FF6E67";
      "${prefix}color2" = "#50FA7B";
      "${prefix}color10" = "#5AF78E";
      "${prefix}color3" = "#F1FA8C";
      "${prefix}color11" = "#F4F99D";
      "${prefix}color4" = "#BD93F9";
      "${prefix}color12" = "#CAA9FA";
      "${prefix}color5" = "#FF79C6";
      "${prefix}color13" = "#FF92D0";
      "${prefix}color6" = "#8BE9FD";
      "${prefix}color14" = "#9AEDFE";
      "${prefix}color7" = "#BFBFBF";
      "${prefix}color15" = "#E6E6E6";
    };
  in (dracula-xresources "URxvt*") // {
  };

  xsession = {
    enable = true;
    # pointerCursor = {
    #   package = pkgs.capitaine-cursors;
    #   name = "Capataine Cursors";
    # };
    windowManager.i3 = {
      enable = true;
      package = nixpkgs-unstable.i3;
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
        resizeActions = [ "shrink width" "shrink height" "grow height" "grow width" ];
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
      extraConfig = ''
        focus_wrapping workspace
      '';
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
