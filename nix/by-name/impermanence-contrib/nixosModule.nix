{ ... }:
{ config, lib, ... }:

{
  options = {
    # environment.persistence
  };
  # TODO(Dusk): currently always on
  # Configure permament stateroot over impermanent sysroot
  config = lib.mkMerge [
    {
      environment.persistence."/configroot".bindfs.mountPoints.ignoreExistingEmpties = true;
      environment.persistence."/configroot".bindfs.mountPoints.method = "empty";
      environment.persistence."/configroot".persistentStoragePath = "/configroot";
      environment.persistence."/spoolroot".bindfs.mountPoints.ignoreExistingEmpties = true;
      environment.persistence."/spoolroot".bindfs.mountPoints.method = "empty";
      environment.persistence."/spoolroot".persistentStoragePath = "/spoolroot";
      environment.persistence."/stateroot".bindfs.mountPoints.ignoreExistingEmpties = true;
      environment.persistence."/stateroot".bindfs.mountPoints.method = "empty";
      environment.persistence."/stateroot".persistentStoragePath = "/stateroot";
      environment.persistence."/logroot".bindfs.mountPoints.ignoreExistingEmpties = true;
      environment.persistence."/logroot".bindfs.mountPoints.method = "empty";
      environment.persistence."/logroot".persistentStoragePath = "/logroot";
      environment.persistence."/cacheroot".bindfs.mountPoints.ignoreExistingEmpties = true;
      environment.persistence."/cacheroot".bindfs.mountPoints.method = "empty";
      environment.persistence."/cacheroot".persistentStoragePath = "/cacheroot";
      environment.persistence."/tmproot".bindfs.mountPoints.ignoreExistingEmpties = true;
      environment.persistence."/tmproot".bindfs.mountPoints.method = "empty";
      environment.persistence."/tmproot".persistentStoragePath = "/tmproot";
      # environment.persistence."/runroot".bindfs.mountPoints.ignoreExistingEmpties = true;
      # environment.persistence."/runroot".bindfs.mountPoints.method = "empty";
      # environment.persistence."/runroot".enable = false;
      # environment.persistence."/runroot".persistentStoragePath = "/";
    }
    {
      environment.persistence."/configroot".directories = [
      ];
      environment.persistence."/configroot".files = [
        { file = "/etc/machine-id"; }
      ];
      environment.persistence."/configroot".hideMounts = lib.mkDefault true;

      environment.persistence."/spoolroot".directories = [
        { directory = "/var/spool"; }
      ];
      environment.persistence."/spoolroot".files = [
      ];
      environment.persistence."/spoolroot".hideMounts = lib.mkDefault true;

      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/nixos"; }
      ];
      environment.persistence."/stateroot".files = [
      ];
      environment.persistence."/stateroot".hideMounts = lib.mkDefault true;

      environment.persistence."/logroot".directories = [
        { directory = "/var/log"; }
      ];
      environment.persistence."/logroot".files = [
      ];
      environment.persistence."/logroot".hideMounts = lib.mkDefault true;

      environment.persistence."/cacheroot".directories = [
        { directory = "/var/cache"; }
      ];
      environment.persistence."/cacheroot".files = [
      ];
      environment.persistence."/cacheroot".hideMounts = lib.mkDefault true;

      environment.persistence."/tmproot".directories = [
        { directory = "/var/tmp"; }
      ];
      environment.persistence."/tmproot".files = [
      ];
      environment.persistence."/tmproot".hideMounts = lib.mkDefault true;

      # environment.persistence."/runroot".directories = [
      # ];
      # environment.persistence."/runroot".files = [
      # ];
      # environment.persistence."/runroot".hideMounts = lib.mkDefault true;
    }
    (lib.mkIf config.boot.initrd.network.ssh.enable {
      assertions = [
        {
          assertion = config.boot.loader.supportsInitrdSecrets;
          message = "User disk configuration expects the bootloader to support initrd secrets.";
        }
        { assertion = false; message = "TODO: Configure persistence for SSH on initrd."; }
      ];
      # boot.initrd.network.ssh.hostKeys = [
      # ];
    })
    /*(lib.mkIf config.boot.zfs.enabled */{
      environment.persistence."/stateroot".files = [
        { file = "/etc/zfs/zpool.cache"; }
      ];
    }/*)*/
    (lib.mkIf config.hardware.bluetooth.enable {
      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/bluetooth"; mode = "0700"; }
      ];
    })
    (lib.mkIf config.security.krb5.enable {
      environment.persistence."/configroot".files = [
        { file = "/etc/krb5.keytab"; /* mode = "0600"; */ }
      ];
    })
    (lib.mkIf config.services.cachix-agent.enable {
      environment.persistence."/configroot".files = [
        { file = config.services.cachix-agent.credentialsFile; /* mode = "0600"; */ }
      ];
    })
    (lib.mkIf config.services.colord.enable {
      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "0750"; }
      ];
    })
    (lib.mkIf config.services.i2p.enable {
      environment.persistence."/stateroot".directories = [
        { directory = "${config.users.users.i2p.home}/.i2pd"; user = "i2p"; group = "i2p"; mode = "0700"; }
      ];
    })
    (lib.mkIf config.services.i2pd.enable {
      environment.persistence."/stateroot".directories = [
        { directory = config.users.users.i2pd.home; user = "i2pd"; group = "i2pd"; mode = "0700"; }
      ];
    })
    (let
      cfg = config.services.jellyfin;
    in
    lib.mkIf cfg.enable {
      environment.persistence."/configroot".directories = [
        { directory = cfg.configDir; inherit (cfg) user group; mode = "0700"; }
      ];
      environment.persistence."/stateroot".directories = [
        { directory = cfg.dataDir; inherit (cfg) user group; mode = "0700"; }
      ];
      environment.persistence."/logroot".directories = [
        { directory = cfg.logDir; inherit (cfg) user group; mode = "0700"; }
      ];
      environment.persistence."/cacheroot".directories = [
        { directory = cfg.cacheDir; inherit (cfg) user group; mode = "0700"; }
      ];
    })
    (let
      cfg = config.services.mediatomb;
    in
    lib.mkIf cfg.enable {
      environment.persistence."/stateroot".directories = [
        { directory = cfg.dataDir; inherit (cfg) user group; mode = "0700"; }
      ];
    })
    (lib.mkIf config.services.openssh.enable {
      # TODO(Dusk): {option}`services.openssh.hostKeys` via sops-nix
      # TODO(Dusk): need to ensure the files will be made available at correct times, and that generation still works
      environment.persistence."/configroot".files = lib.concatMap (hostKey: [
        { file = "${hostKey.path}"; /* mode = "0600"; */ }
        { file = "${hostKey.path}.pub"; /* mode = "0644"; */ }
      ]) config.services.openssh.hostKeys;
      # services.openssh.hostKeys = [
      #   { path = "/configroot/etc/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
      #   { path = "/configroot/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
      # ];
    })
    (lib.mkIf config.services.samba.enable {
      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/samba"; }
        { directory = "/var/lock/samba"; }
      ];
      environment.persistence."/logroot".directories = [
        { directory = "/var/log/samba"; }
      ];
      environment.persistence."/cacheroot".directories = [
        { directory = "/var/cache/samba"; }
      ];
    })
    (lib.mkIf config.services.tailscale.enable {
      environment.persistence."/configroot".directories = [
        { directory = "/var/lib/tailscale"; mode = "0700"; }
      ];
      environment.persistence."/spoolroot".directories = [
        { directory = "/var/lib/tailscale/files"; mode = "0700"; }
      ];
    })
    (lib.mkIf config.services.yggdrasil.enable (lib.mkIf config.services.yggdrasil.persistentKeys {
      environment.persistence."/configroot".files = [
        { file = "/var/lib/yggdrasil/keys.json"; /* mode = "0700"; */ }
      ];
    }))
    # # TODO(Dusk): unbreak
    # (lib.mkIf config.sound.enable {
    #   environment.persistence."/stateroot".files = [
    #     { file = "/var/lib/alsa/asound.state"; /* mode = "0644"; */ }
    #   ];
    # })
    # systemd {manpage}`machinectl(1)` / {manpage}`systemd-nspawn(1)`
    {
      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/machines"; }
      ];
    }
    (lib.mkIf config.systemd.coredump.enable {
      environment.persistence."/logroot".directories = [
        { directory = "/var/lib/systemd/coredump"; }
      ];
    })
    (lib.mkIf config.networking.networkmanager.enable {
      # TODO(Dusk): verify configroot
      environment.persistence."/configroot".directories = [
        { directory = "/etc/NetworkManager/system-connections"; }
      ];
      # TODO(Dusk): verify stateroot & not cacheroot
      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/NetworkManager"; }
      ];
    })
    (lib.mkIf config.users.mutableUsers (lib.mkMerge [
      (lib.mkIf config.systemd.sysusers.enable {
        environment.persistence."/configroot".files = [
          { file = "/etc/passwd"; /* mode = "0644"; */ }
          { file = "/etc/shadow"; /* mode = "0000"; */ }
          { file = "/etc/subuid"; /* mode = "0644"; */ }
          { file = "/etc/group"; /* mode = "0644"; */ }
          { file = "/etc/gshadow"; /* mode = "0000"; */ }
          { file = "/etc/subgid"; /* mode = "0644"; */ }
        ];
      })
      (lib.mkIf (!config.systemd.sysusers.enable) {
        # see `nixpkgs/nixos/modules/config/update-users-groups.pl`
        environment.persistence."/configroot".files = [
          { file = "/etc/passwd"; /* mode = "0644"; */ }
          { file = "/etc/shadow"; /* mode = "0640"; */ }
          { file = "/etc/subuid"; /* mode = "0644"; */ }
          { file = "/etc/group"; /* mode = "0644"; */ }
          { file = "/etc/gshadow"; /* mode = "0640"; */ }
          { file = "/etc/subgid"; /* mode = "0644"; */ }
        ];
      })
    ]))
    (lib.mkIf config.virtualisation.containers.enable {
      environment.persistence."/stateroot".directories = [
        { directory = "/var/lib/containers/storage"; mode = "0755"; }
      ];
      virtualisation.containers.storage.settings.graphroot = "/var/lib/containers/storage";
    })
  ];
}
