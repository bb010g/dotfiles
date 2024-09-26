{ ... }:
moduleArgs@{ config, lib, options, pkgs, utils, ... }:

let
  inherit (lib)
    attrNames
    concatMapStringsSep
    escapeNixIdentifier
    filter
    literalExpression
    mapAttrs
    mapAttrsToList
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    subtractLists
    types
    ;
  inherit (utils)
    escapeUdevString
    ;
  cfg = config.services.udev;
  drivesCfg = cfg.ioSchedulers.drives;
  initrdCfg = config.boot.initrd.services.udev;
  initrdDrivesCfg = initrdCfg.ioSchedulers.drives;
  initrdIoSchedulersUdevRules = pkgs.writeTextFile {
    name = "initrd-io-schedulers-udev-rules";
    text = initrdCfg.ioSchedulers.rules;
    destination = "/etc/udev/rules.d/60-io-schedulers.rules";
  };
  ioSchedulersUdevRules = pkgs.writeTextFile {
    name = "io-schedulers-udev-rules";
    text = cfg.ioSchedulers.rules;
    destination = "/etc/udev/rules.d/60-io-schedulers.rules";
  };
  mkDisableOption = name:
    mkEnableOption name // { default = true; example = false; };
  mkInternalRulesOption = default: mkOption {
    inherit default;
    type = types.lines;
    internal = true;
  };
  mkIoSchedulerDisableDriveOption = name:
    mkDisableOption "I/O scheduler udev rules for ${name}";
  rootConfig = config;
  utils = moduleArgs.utils // import ../../../nixos/lib/utils.nix { inherit config lib pkgs utils; };
in
{
  options = {
    boot.ioSchedulers = mkOption {
      default = { };
      example = literalExpression ''
        {
          bfq.enable = true;
          bore.enable = lib.mkForce false;
        }
      '';
      type = types.attrsOf (types.submodule ({ config, name, ... }: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = false;
            defaultText = "`true` if this I/O scheduler is enabled";
            example = literalExpression ''lib.mkForce false'';
            description = ''
              Whether this I/O scheduler is enabled. This may be used together
              with `lib.mkForce` to explicitly disable support.
            '';
          };
          kernelModules = mkOption {
            type = types.listOf types.str;
            # based on `elevator_change()` in `@linux//block/elevator.c`
            default = [ ];
            example = [ name ];
            description = ''
              A set of kernel modules needed to use this I/O scheduler.
            '';
          };
        };
      }));
      description = ''
        Supported I/O schedulers and their state. This may be used together with
        `lib.mkForce` to explicitly disable support for specific I/O schedulers,
        e.g. to disable BORE with an unsupported kernel.
      '';
    };
    boot.initrd.ioSchedulers = mkOption {
      default = { };
      example = options.boot.ioSchedulers.example;
      type = types.attrsOf (types.submodule ({ config, name, ... }: let
        ioSchedulerOptions = options.boot.ioSchedulers.type.getSubOptions options.boot.ioSchedulers.loc;
      in {
        options = {
          enable = mkOption {
            inherit (ioSchedulerOptions.enable) example type;
            default = false;
            defaultText = "`true` if this I/O scheduler is enabled in initrd";
            description = ''
              Whether this I/O scheduler is enabled in initrd. This may be used
              together with `lib.mkForce` to explicitly disable support.
            '';
          };
          kernelModules = mkOption {
            inherit (ioSchedulerOptions.kernelModules) type;
            # based on `elevator_change()` in `@linux//block/elevator.c`
            default = [ ];
            example = [ name ];
            description = ''
              A set of kernel modules needed to use this I/O scheduler in
              initrd.
            '';
          };
        };
      }));
      description = ''
        Supported I/O schedulers and their state in initrd.
      '';
    };

    services.udev = {
      ioSchedulers = {
        enable = mkEnableOption "I/O scheduler udev rules";
        rules = mkOption {
          default = "";
          type = types.lines;
          description = ''
            {command}`udev` rules for I/O schedulers.
            They'll be written into the file {file}`60-io-schedulers.rules`.
            Thus they are read and applied as essential initrd rules.
          '';
        };

        drives.hdd.enable = mkIoSchedulerDisableDriveOption "spinning HDDs";
        drives.hdd.rules = mkInternalRulesOption ''
          # set scheduler for rotating HDDs
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}=${escapeUdevString drivesCfg.hdd.scheduler}'';
        drives.hdd.scheduler = mkOption {
          type = types.str;
          description = "Default I/O scheduler for spinning HDDs.";
          default = "bfq";
        };

        drives.nvme.enable = mkIoSchedulerDisableDriveOption "NVMe drives";
        drives.nvme.rules = mkInternalRulesOption ''
          # set scheduler for NVMe drives
          ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}=${escapeUdevString drivesCfg.nvme.scheduler}'';
        drives.nvme.scheduler = mkOption {
          type = types.str;
          description = "Default I/O scheduler for NVME drives.";
          default = "none";
          example = "kyber";
        };

        drives.ssd.enable = mkIoSchedulerDisableDriveOption
          "SSDs and eMMC drives";
        drives.ssd.rules = mkInternalRulesOption ''
          # set scheduler for SSDs and eMMC drives
          ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}=${escapeUdevString drivesCfg.ssd.scheduler}'';
        drives.ssd.scheduler = mkOption {
          type = types.str;
          description = "Default I/O scheduler for SSDs and eMMC drives.";
          default = "mq-deadline";
          example = "none";
        };
      };
    };
    boot.initrd.services.udev = {
      ioSchedulers = {
        enable = mkEnableOption "I/O scheduler udev rules to include in the initrd *only*";
        rules = mkOption {
          default = "";
          type = types.lines;
          description = ''
            {command}`udev` rules for I/O schedulers to include in the initrd
            *only*.
            They'll be written into the file {file}`60-io-schedulers.rules`.
            Thus they are read and applied as essential initrd rules.
          '';
        };

        drives.hdd.enable = mkIoSchedulerDisableDriveOption
          "spinning HDDs to include in the initrd *only*";
        drives.hdd.rules = mkInternalRulesOption ''
          # set scheduler for rotating HDDs
          ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}=${escapeUdevString initrdDrivesCfg.hdd.scheduler}'';
        drives.hdd.scheduler = mkOption {
          type = types.str;
          description = "Default I/O scheduler for spinning HDDs.";
          default = "bfq";
        };

        drives.nvme.enable = mkIoSchedulerDisableDriveOption
          "NVMe drives to include in the initrd *only*";
        drives.nvme.rules = mkInternalRulesOption ''
          # set scheduler for NVMe drives
          ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}=${escapeUdevString initrdDrivesCfg.nvme.scheduler}'';
        drives.nvme.scheduler = mkOption {
          type = types.str;
          description = "Default I/O scheduler for NVME drives.";
          default = "none";
          example = "kyber";
        };

        drives.ssd.enable = mkIoSchedulerDisableDriveOption
          "SSDs and eMMC drives to include in the initrd *only*";
        drives.ssd.rules = mkInternalRulesOption ''
          # set scheduler for SSDs and eMMC drives
          ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}=${escapeUdevString initrdDrivesCfg.ssd.scheduler}'';
        drives.ssd.scheduler = mkOption {
          type = types.str;
          description = "Default I/O scheduler for SSDs and eMMC drives.";
          default = "mq-deadline";
          example = "none";
        };
      };
    };
  };
  config = mkMerge [
    {
      boot.ioSchedulers.bfq.kernelModules = [ "bfq" ];
      boot.ioSchedulers.mq-deadline.kernelModules = [ "mq-deadline" ];
      boot.ioSchedulers.kyber.kernelModules = [ "kyber" ];
      boot.initrd.ioSchedulers.bfq.kernelModules = [ "bfq" ];
      boot.initrd.ioSchedulers.mq-deadline.kernelModules = [ "mq-deadline" ];
      boot.initrd.ioSchedulers.kyber.kernelModules = [ "kyber" ];
    }
    {
      assertions =
        let
          initrdIoSchedulers = config.boot.initrd.ioSchedulers;
          initrdEnabledIoSchedulerNames = filter
            (name: initrdIoSchedulers.${name}.enable)
            (attrNames initrdIoSchedulers);
          ioSchedulers = config.boot.ioSchedulers;
          enabledIoSchedulerNames = filter
            (name: ioSchedulers.${name}.enable)
            (attrNames ioSchedulers);
          missingIoSchedulerNames =
            subtractLists initrdEnabledIoSchedulerNames enabledIoSchedulerNames;
        in
        [
          {
            assertion = missingIoSchedulerNames == [ ];
            message = ''
              The ‘boot.initrd.ioSchedulers.<name>.enable’ option is true
              while the ‘boot.ioSchedulers.<name>.enable’ option is false
              for the following names: ${concatMapStringsSep escapeNixIdentifier " " missingIoSchedulerNames}'';
          }
        ];
      boot.initrd.availableKernelModules = mkMerge (
        mapAttrsToList
          (name: cfg': mkIf cfg'.enable cfg'.kernelModules)
          config.boot.initrd.ioSchedulers
      );
      boot.ioSchedulers = mapAttrs
        (name: cfg': mkIf cfg'.enable { enable = true; })
        config.boot.initrd.ioSchedulers;
    }
    (mkIf drivesCfg.hdd.enable {
      services.udev.ioSchedulers.rules = drivesCfg.hdd.rules;
      boot.ioSchedulers.${drivesCfg.hdd.scheduler}.enable = true;
    })
    (mkIf drivesCfg.nvme.enable {
      services.udev.ioSchedulers.rules = drivesCfg.nvme.rules;
      boot.ioSchedulers.${drivesCfg.nvme.scheduler}.enable = true;
    })
    (mkIf drivesCfg.ssd.enable {
      services.udev.ioSchedulers.rules = drivesCfg.ssd.rules;
      boot.ioSchedulers.${drivesCfg.ssd.scheduler}.enable = true;
    })
    (mkIf cfg.ioSchedulers.enable {
      services.udev.packages = mkIf (cfg.ioSchedulers.rules != "")
        [ ioSchedulersUdevRules ];
    })
    (mkIf initrdDrivesCfg.hdd.enable {
      boot.initrd.services.udev.ioSchedulers.rules =
        initrdDrivesCfg.hdd.rules;
      boot.initrd.ioSchedulers.${initrdDrivesCfg.hdd.scheduler}.enable = true;
    })
    (mkIf initrdDrivesCfg.nvme.enable {
      boot.initrd.services.udev.ioSchedulers.rules =
        initrdDrivesCfg.nvme.rules;
      boot.initrd.ioSchedulers.${initrdDrivesCfg.nvme.scheduler}.enable = true;
    })
    (mkIf initrdDrivesCfg.ssd.enable {
      boot.initrd.services.udev.ioSchedulers.rules =
        initrdDrivesCfg.ssd.rules;
      boot.initrd.ioSchedulers.${initrdDrivesCfg.ssd.scheduler}.enable = true;
    })
    (mkIf initrdCfg.ioSchedulers.enable {
      boot.initrd.extraUdevRulesCommands = mkIf
        (!config.boot.initrd.systemd.enable &&
          initrdCfg.ioSchedulers.rules != "")
        ''
          cp -v ${initrdIoSchedulersUdevRules}/etc/udev/rules.d/*.rules "$out"/
        '';
      boot.initrd.services.udev.packages = mkIf
        (initrdCfg.ioSchedulers.rules != "")
        [ initrdIoSchedulersUdevRules ];
    })
  ];
}
