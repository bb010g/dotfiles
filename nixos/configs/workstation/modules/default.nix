# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

moduleArgs@{ config, lib, modulesPath, pkgs, utils, ... }:

let
  utils = moduleArgs.utils // import ../../../lib/utils.nix { inherit config lib pkgs utils; };
in
{
  config = lib.mkMerge [
    # Use systemd in initrd.
    {
      boot.initrd.systemd.enable = true;
    }
    # Use the systemd-boot EFI boot loader.
    {
      boot.loader.systemd-boot.enable = true;
    }
    # Use the latest Linux kernel.
    (lib.mkDefault {
      boot.kernelPackages = pkgs.linuxPackages_latest;
    })
    # Use the latest supported ZFS kernel.
    (lib.mkIf (config.boot.supportedFilesystems.zfs or false || config.boot.initrd.supportedFilesystems.zfs or false) {
      boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    })
    # Configure networking.
    {
      assertions = [
        {
          assertion = config.services.avahi.enable -> !config.services.resolved.enable;
          message = "User configuration expects Avahi without systemd-resolved.";
        }
      ];

      environment.systemPackages = [
        pkgs.croc
        pkgs.curl
        (lib.getBin pkgs.ldns) # drill
        pkgs.tcpdump
        pkgs.wget
        pkgs.wget2
      ];

      # # Pick only one of the below networking options.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
      networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

      # # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      programs.wireshark.enable = true;

      services.avahi.enable = true;
      services.avahi.nssmdns4 = true;
      services.avahi.nssmdns6 = true;
      services.avahi.openFirewall = true;
      services.avahi.publish.addresses = true;
      services.avahi.publish.domain = true;
      services.avahi.publish.enable = true;
      services.avahi.publish.hinfo = true;
      services.avahi.publish.userServices = true;
      services.avahi.publish.workstation = true;

      services.i2pd.yggdrasil.enable = true;

      services.jellyfin.openFirewall = true;

      services.mediatomb.openFirewall = true;

      services.murmur.openFirewall = true;

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;
      services.openssh.openFirewall = true;

      services.pixiecore.openFirewall = true;

      services.samba.openFirewall = true;

      services.shairport-sync.openFirewall = true;

      # Enable the Tailscale client daemon.
      services.tailscale.enable = true;
      services.tailscale.openFirewall = true;
      services.tailscale.useRoutingFeatures = "both";

      # Enable the Yggdrasil network daemon.
      services.yggdrasil.enable = true;
      services.yggdrasil.persistentKeys = true;
      # <https://publicpeers.neilalexander.dev/>
      services.yggdrasil.settings.Peers = [
        # United States
        "tls://longseason.1200bps.xyz:13122"
        "tls://supergay.network:443"
        "tls://supergay.network:9001"
        "tcp://supergay.network:9002"
        "quic://yggdrasil-2.herronjo.com:1337?key=6cbcd23d94c9a300e442bd1054c7ced8d09dbb6349261651b24e76851efb7edf"
        # Canada
        "tls://cal.servers.devices.cwinfo.net:58226"
      ];
    }
    # Configure internationalization.
    {
      # # Set your time zone.
      time.timeZone = "America/Los_Angeles";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";
      console = {
        # font = "Lat2-Terminus16";
        # keyMap = "us";
        useXkbConfig = true; # use xkb.options in tty.
      };
    }
    # Enable magic SysRq
    {
      boot.kernel.sysctl."kernel.sysrq" = 1;
      boot.kernelParams = [ "sysrq_always_enabled=1" ];
    }
    # Configure I/O schedulers.
    {
      boot.initrd.services.udev.ioSchedulers.enable = true;
      services.udev.ioSchedulers.enable = true;

      # Counteract ZFS setting I/O scheduler to none for spinning HDDs with `zfs_member`s
      services.udev.extraRules = lib.mkIf config.boot.supportedFilesystems.zfs or false (lib.mkMerge [
        (lib.mkIf config.services.udev.ioSchedulers.drives.hdd.enable (lib.mkAfter ''
          # re-set I/O scheduler for rotating HDDs with ZFS partitions
          ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*", ENV{DEVTYPE}=="partition", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/rotational}=="1", ATTR{../queue/scheduler}=${utils.escapeUdevString config.services.udev.ioSchedulers.drives.hdd.scheduler}
        ''))
      ]);
    }
    # Use Wayland.
    {
      environment.systemPackages = [
        pkgs.wl-clipboard
      ];
      services.displayManager.sddm.wayland.enable = true;
      services.xserver.excludePackages = [
        pkgs.xorg.xorgserver.out
      ];
      xdg.portal.xdgOpenUsePortal = true;
    }
    # # Enable system greeter.
    # {
    #   services.greetd.enable = true;
    # }
    # KDE Plasma 6 graphical session.
    {
      environment.systemPackages = [
        # pkgs.aha # `aha(1)` # dependency of Info Center
        # pkgs.clinfo # `clinfo(1)` # dependency of Info Center
        pkgs.foot # terminal
        # pkgs.glxinfo # `glxinfo(1)`, `eglinfo(1)` # dependency of Info Center
        pkgs.libsForQt5.polonium # NOTE: Might move to Plasma 6 architecture soon
        # pkgs.pciutils # `lspci(1)` # dependency of Info Center
        pkgs.quota # pkgs.unixtools.quota # dependency of Disk Quota widget
        # pkgs.vulkan-tools # `vulkaninfo(1)` # dependency of Info Center
        # pkgs.wayland-utils # `wayland-info(1)` # dependency of Info Center
      ];
      programs.loginGreeters.tuigreet.enable = true;
      services.desktopManager.plasma6.enable = true;
      services.xserver.enable = true;
    }
    # KDE Plasma system utilities
    (lib.mkIf config.services.desktopManager.plasma6.enable {
      environment.systemPackages = [
        pkgs.hotspot # Linux perf
        pkgs.kdePackages.kjournald # systemd journal
        pkgs.systemdgenie # systemd service & login session management
      ];
    })
    # Uncategorized confifguration.
    {
      boot.initrd.systemd.emergencyAccess = config.users.users.root.hashedPassword;

      services.smartd.enable = true;

      # # Configure keymap in X11
      services.xserver.xkb.layout = "us";
      # services.xserver.xkb.options = "eurosign:e,caps:escape";

      # Enable CUPS to print documents.
      services.printing.enable = true;
      services.printing.browsing = true;
      services.printing.cups-pdf.enable = true;
      services.printing.tempDir = "/tmp/cups";

      # Enable sound.
      sound.enable = true;
      services.pipewire.enable = true;
      services.pipewire.alsa.enable = true;
      services.pipewire.jack.enable = true;
      services.pipewire.pulse.enable = true;

      # # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      users.mutableUsers = false;

      # # Some programs need SUID wrappers, can be configured further or are
      # # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:
    }
    # Enable flatpak.
    {
      services.flatpak.enable = true;
      services.flatpak.remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      services.flatpak.uninstallUnmanaged = true;
    }
    (lib.mkIf config.services.flatpak.enable (lib.mkMerge [
      # Discord (via Vesktop)
      {
        programs.vesktop.flatpak.enable = true;
        programs.vesktop.flatpak.package = { appId = "dev.vencord.Vesktop"; origin = "flathub"; };
      }
      (lib.mkIf config.services.desktopManager.plasma6.enable {
        environment.systemPackages = [
          pkgs.kdePackages.discover
        ];
      })
    ]))
    # Use compressed swap.
    {
      zramSwap.enable = true;
      zramSwap.algorithm = "zstd";
    }
    # Use XDG directories.
    {
      nix.settings.use-xdg-base-directories = true;
    }
    # Enable Nix flakes.
    {
      nix.settings.extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
    }
    # Enable unfree packages.
    {
      nixpkgs.config.allowUnfree = true;
    }
    # Enable the Cachix binary cache.
    {
      environment.systemPackages = [
        pkgs.cachix
      ];
      nix.settings.extra-substituters = [ "https://nix-community.cachix.org" "https://devenv.cachix.org" "https://bb010g.cachix.org" ];
      nix.settings.extra-trusted-public-keys = [ "bb010g.cachix.org-1:djBep9/0fi6Lmm5s3kHo/XHfvkWtVSIKxVrCIGdk9LA=" "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      services.cachix-agent.enable = true;
    }
    # Enable Ed, the standard text editor.
    {
      environment.systemPackages = [
        pkgs.ed
      ];
      environment.variables.EDITOR = lib.mkOverride 800 "ed";
    }
    # Enable the inxi system information tool.
    {
      environment.systemPackages = [
        (pkgs.inxi.override (prevAttrs: { withRecommendedSystemPrograms = true; }))
      ];
    }
    # Configure shell niceties.
    {
      programs.bash.blesh.enable = true;
      # environment.systemPackages = [
      #   pkgs.atuin
      # ];
    }
    # Enable extra base system utilities.
    {
      environment.systemPackages = [
        pkgs.bat
        # pkgs.diffoscope
        pkgs.du-dust
        pkgs.eza
        pkgs.file
        pkgs.fd
        pkgs.fselect
        pkgs.jq
        pkgs.kmon
        (lib.getBin pkgs.libarchive) # bsdtar
        pkgs.ltrace
        pkgs.mtm
        pkgs.procs
        pkgs.progress
        pkgs.ripgrep
        pkgs.strace
        pkgs.uftrace
        pkgs.units
      ];
    }
    # Enable the sysprof profiling daemon.
    (lib.mkIf config.services.xserver.enable {
      services.sysprof.enable = true;
    })
    # Enable the Goldwarden client for the Bitwarden password manager.
    {
      programs.goldwarden.enable = true;
      programs.goldwarden.useSshAgent = true;
    }
    # Enable direnv.
    {
      programs.direnv.enable = true;
    }
    # Enable extra Nix utilities.
    {
      environment.systemPackages = [
        pkgs.nix-bisect
        pkgs.nix-diff
        pkgs.nix-eval-jobs
        # pkgs.nix-fast-build # TODO(Dusk): Nixpkgs overlay
        pkgs.nix-melt
        pkgs.nix-output-monitor
        pkgs.nix-search-cli
        pkgs.nix-top
        pkgs.nixfmt-rfc-style or pkgs.nixfmt
        pkgs.nixos-firewall-tool
        pkgs.nixos-option
        pkgs.nixpkgs-hammering
        pkgs.nvd
      ];
      programs.direnv.nix-direnv.enable = true;
    }
    # Enable extra terminfos.
    {
      environment.systemPackages = [
        pkgs.alacritty.terminfo
        pkgs.foot.terminfo
        pkgs.kitty.terminfo
        pkgs.mtm.terminfo
        pkgs.rio.terminfo
        pkgs.rxvt-unicode-unwrapped.terminfo
        pkgs.st.terminfo
        pkgs.wezterm.terminfo
      ];
    }
    # Enable terminal multiplexers.
    {
      environment.systemPackages = [
        pkgs.vtm
        pkgs.zellij
      ];
      programs.tmux.enable = true;
      programs.tmux.clock24 = true;
      programs.tmux.keyMode = "vi";
      programs.tmux.terminal = "tmux-direct";
    }
    # Enable the htop process monitor.
    {
      programs.htop.enable = true;
      programs.htop.settings = {
      };
    }
    # Enable the bottom process monitor.
    {
      environment.systemPackages = [
        pkgs.bottom
      ];
    }
    # Enable standalone Neovim.
    (lib.mkIf (!config.programs.neovim.enable) {
      environment.systemPackages = [
        pkgs.neovim
      ];
      environment.variables.EDITOR = lib.mkOverride 900 "nvim";
      environment.variables.VISUAL = lib.mkOverride 900 "nvim";
    })
    # Enable Git.
    {
      environment.systemPackages = [
        pkgs.git-dive
        pkgs.git-revise
        pkgs.git-stack
      ];
      programs.git.enable = true;
      programs.git.package = pkgs.gitFull;
      programs.git.lfs.enable = true;
    }
    # Enable the Podman container engine.
    {
      virtualisation.podman.enable = true;
      virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
    }
    # Uncategorized graphical confifguration.
    (lib.mkIf config.services.xserver.enable {
      environment.systemPackages = [
        pkgs.foot
        pkgs.qdirstat
      ];
      programs.wireshark.package = pkgs.wireshark;
      # Discord (via Vesktop)
      programs.vesktop.enable = true;
    })
    # Enable debuginfod.
    {
      services.nixseparatedebuginfod.enable = true;
    }
    {
      nix.settings.auto-optimise-store = lib.mkDefault true;
    }
    # Make the NixOS configuration accessible, with or without flakes.
    (lib.mkMerge [
      {
        # Copy the NixOS configuration file and link it from the resulting system
        # (/run/current-system/configuration.nix). This is useful in case you
        # accidentally delete configuration.nix.
        system.copySystemConfiguration = !lib.inPureEvalMode; # TODO(Dusk): `true`
      }
      (if !(moduleArgs.self or { } ? outPath) then { } else {
        system.extraSystemBuilderCmds = /* lib.mkIf config.system.copySystemConfiguration */ ''
          ln -s ${lib.escapeShellArg moduleArgs.self.outPath} "$out/configuration"'';
      })
    ])
  ];
}
# vim: set sta et sw=2 ts=8:
