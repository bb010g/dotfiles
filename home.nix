{ config, lib, pkgs, ... } @ args:
let
  srcs = import ./sources.nix;
  inherit (srcs)
    sources
    sources-ext
  ;
in
{
  imports = [
    ./conf/autorandr.nix
    ./conf/beets.nix
    ./conf/firefox.nix
    ./conf/git.nix
    ./conf/input.nix
    ./conf/mpd.nix
    ./conf/neovim.nix
    ./conf/packages.nix
    # TODO: unbreak (possibly involves nur.modules.bb010g)
    # ./conf/pijul.nix
    ./conf/redshift.nix
    ./conf/session-variables.nix
    # ./conf/tex.nix
  ];

  # dconf. 24-hour time

  # home.sessionVariables = you probably want systemd.user.sessionVariables

  home.stateVersion = "22.05";
  home.username = "bb010g";
  home.homeDirectory = "/home/bb010g";

  manual = {
    html.enable = true;
    man-pages.enable = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    # nix-direnv.enable = true;
    # nix-direnv.enableFlakes = true;
  };

  programs.emacs = { enable = true; };

  programs.feh = { enable = true; };

  # Home Manager config
  programs.home-manager = {
    enable = true;
    path = let p = "${config.home.homeDirectory}/nix/home-manager"; in
      if lib.pathExists p then p else <home-manager>;
  };

  programs.htop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
    # package = pkgs.jq;
    # package = pkgs.nur.pkgs.bb010g.jq;
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
    enable = false; # TODO: reenable
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

  services.network-manager-applet = { enable = true; };

  # services.screen-locker = {
  #   enable = true;
  #   inactiveInterval = 10;
  #   lockCmd = "${pkgs.i3lock}/bin/i3lock -f -c 131736";
  # };

  # services.unclutter = {
  #   enable = true;
  #   timeout = 5;
  # };

  xdg = {
    enable = true;

    configFile = {
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

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main.dpi-aware = "no";
      main.font = "monospace-14:pixelsize=14"; # :antialias=true:autohint=true
      mouse.hide-when-typing = "yes";
      colors = {
        foreground = "f8f8f2";
        background = "282a36";

        regular0   = "000000"; # black
        regular1   = "ff5555"; # red
        regular2   = "50fa7b"; # green
        regular3   = "f1fa8c"; # yellow
        regular4   = "bd93f9"; # blue
        regular5   = "ff79c6"; # magenta
        regular6   = "8be9fd"; # cyan
        regular7   = "bfbfbf"; # white

        bright0    = "4d4d4d"; # black
        bright1    = "ff6e67"; # red
        bright2    = "5af78e"; # green
        bright3    = "f4f99d"; # yellow
        bright4    = "caa9fa"; # blue
        bright5    = "ff92d0"; # magenta
        bright6    = "9aedfe"; # cyan
        bright7    = "e6e6e6"; # white
      };
    };
  };

  programs.i3status = {
    enable = true;
    enableDefault = true;
  };

  xsession.enable = false;
  graphical-session.preferStatusNotifierItems = true;
  services.xembed-sni-proxy.enable = true;
  wayland = {
    # enable = true;
    # pointerCursor = {
    #   package = pkgs.capitaine-cursors;
    #   name = "Capataine Cursors";
    # };
    windowManager.sway = let cfg = config.wayland.windowManager.sway; in {
      enable = true;
      # package = pkgs.sway;
      config = let
        zipToAttrs = lib.zipListsWith (n: v: { ${n} = v; });
        mergeAttrList = lib.foldr lib.mergeAttrs {};
        mergeAttrMap = f: l: mergeAttrList (lib.concatMap f l);

        escapeSwayArg = arg:
          if builtins.match "[^\\ \"]*" arg != null then arg else
            "\"${lib.escape [ "\\" "\"" ] arg}\"";

        inherit (cfg.config) modifier;
        arrowKeys = [ "Left" "Down" "Up" "Right" ];
        viKeys = [ "h" "j" "k" "l" ];
        workspaceNames = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ];
        workspaceKeys = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" ];

        fonts = { names = [ "monospace" ]; size = 10.0; };

        dirNames = [ "left" "down" "up" "right" ];
        resizeActions = [ "shrink width" "shrink height" "grow height" "grow width" ];
      in {
        bars = [ ];
        ${null/*bars*/} = [
          {
            # colors = {
            #   activeWorkspace = { background = "#5f676a"; border = "#333333"; text = "#ffffff"; };
            #   background = "#000000";
            #   bindingMode = { background = "#900000"; border = "#2f343a"; text = "#ffffff"; };
            #   focusedWorkspace = { background = "#285577"; border = "#4c7899"; text = "#ffffff"; };
            #   inactiveWorkspace = { background = "#222222"; border = "#333333"; text = "#888888"; };
            #   separator = "#666666";
            #   statusline = "#ffffff";
            #   urgentWorkspace = { background = "#900000"; border = "#2f343a"; text = "#ffffff"; };
            # };
            inherit fonts;
            hiddenState = "hide";
            mode = "dock";
            position = "top";
            statusCommand = "${config.programs.i3status.package}/bin/i3status";
            trayOutput = "primary";
            workspaceButtons = true;
            workspaceNumbers = true;
          }
        ];
        defaultWorkspace = "workspace number 1";
        inherit fonts;
        input = {
          "type:keyboard" = let cfgKeyboard = config.home.keyboard; in lib.mkIf (cfgKeyboard != null) {
            xkb_layout = lib.mkIf (cfgKeyboard.layout != null) (escapeSwayArg cfgKeyboard.layout);
            xkb_model = lib.mkIf (cfgKeyboard.model != null) (escapeSwayArg cfgKeyboard.model);
            xkb_options = escapeSwayArg (lib.concatStringsSep "," cfgKeyboard.options);
            xkb_variant = lib.mkIf (cfgKeyboard.variant != null) (escapeSwayArg cfgKeyboard.variant);
          };
          "type:touchpad" = {
            dwt = "disabled";
          };
        };
        keybindings = mergeAttrList [
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+${k}") ks) (map (d: "focus ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Shift+${k}") ks) (map (d: "move ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Ctrl+${k}") ks) (map (d: "move container to output ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrMap (ks: zipToAttrs (map (k: "${modifier}+Shift+Ctrl+${k}") ks) (map (d: "move workspace to output ${d}") dirNames)) [ viKeys arrowKeys ])
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+${k}") workspaceKeys) (map (n: "workspace number ${n}") workspaceNames)))
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+Shift+${k}") workspaceKeys) (map (n: "move workspace number ${n}") workspaceNames)))
          (mergeAttrList (zipToAttrs (map (k: "${modifier}+Shift+Ctrl+${k}") workspaceKeys) (map (n: "move workspace to output ${n}") workspaceNames)))
          {
            "${modifier}+Return" = "exec ${cfg.config.terminal}";
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
            "${modifier}+Shift+e" =
              "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit; systemctl --user stop graphical-session.target; systemctl --user stop graphical-session-pre.target'";
          }
        ];
        menu = "${pkgs.dmenu}/bin/dmenu_run";
        modes = {
          resize = mergeAttrList [
            (mergeAttrMap (ks: zipToAttrs ks (map (a: "resize ${a}") resizeActions)) [ viKeys arrowKeys ])
            {
              "Escape" = "mode default";
              "Return" = "mode default";
            }
          ];
        };
        modifier = "Mod4";
        terminal = "${config.programs.foot.package}/bin/footclient";
        # workspaceLayout = "tabbed";
      };
      extraConfig = ''
        focus_wrapping workspace
        for_window [shell=".*"] title_format "%title :: %shell"
      '';
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_QPA_PLATFORMTHEME=qt5ct
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Firefox
        export MOZ_ENABLE_WAYLAND=1
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
      systemdIntegration = true;
      wrapperFeatures.gtk = true;
      xwayland = true;
    };
  };
  xdg.portal.desktop = {
    enable = true;
    gtk.usePortal = true;
    wlr.enable = true;
  };

  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "bottom";
        position = "top";
        modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ]; # "wlr/taskbar"
        # modules-center = [ "sway/window" ];
        modules-center = [ ];
        # modules-right = [ "network" "battery" "disk" "cpu" "memory" "clock" "tray" ];
        modules-right = [ "custom/status" "tray" ];
        modules = {
          # "cpu" = {
          #   format = "{load}";
          # };
          "sway/workspaces" = {
            all-outputs = true;
          };
          "custom/status" = {
            exec = "${config.programs.i3status.package}/bin/i3status";
            tooltip = false;
          };
          # "wlr/taskbar" = {
          #   all-outputs = false;
          # };
        };
      }
    ];
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: monospace;
        font-size: 10pt;
      }
      window#waybar {
        background: #000000;
        color: #ffffff;
      }
      #workspaces button {
        padding: 0 2px;
        background: #222222;
        color: #888888;
        border: 1px solid #333333;
      }
      #workspaces button.focused {
        background: #285577;
        color: #ffffff;
        border: 1px solid #4c7899;
      }
    '';
    systemd.enable = true;
  };
  services.blueman-applet.enable = true;
}

# vim:ft=nix:et:sw=2:tw=78
