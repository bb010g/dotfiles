{ config, lib, pkgs, ... }:

let
  inherit (lib)
    escape
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.services.udev;
  drivesCfg = cfg.ioSchedulers.drives;
  escapeUdevString = s: "\"${escape [ "\"" ] s}\"";
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
  mkIoSchedulerEnabledOption = name: mkOption {
    type = types.bool;
    default = false;
    defaultText = "`true` if the ${name} I/O scheduler is enabled";
    description = "True if the ${name} I/O scheduler is enabled";
  };
in
{
  options = {
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

        bfq.enabled = mkIoSchedulerEnabledOption "BFQ";
        kyber.enabled = mkIoSchedulerEnabledOption "kyber";
        mq-deadline.enabled = mkIoSchedulerEnabledOption "mq-deadline";

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

        bfq.enabled = mkIoSchedulerEnabledOption "BFQ";
        kyber.enabled = mkIoSchedulerEnabledOption "kyber";
        mq-deadline.enabled = mkIoSchedulerEnabledOption "mq-deadline";

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
    (mkIf drivesCfg.hdd.enable {
      services.udev.ioSchedulers.rules = drivesCfg.hdd.rules;
      services.udev.ioSchedulers.bfq.enabled =
        mkIf (drivesCfg.hdd.scheduler == "bfq") true;
      services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf (drivesCfg.hdd.scheduler == "mq-deadline") true;
      services.udev.ioSchedulers.kyber.enabled =
        mkIf (drivesCfg.hdd.scheduler == "kyber") true;
    })
    (mkIf drivesCfg.nvme.enable {
      services.udev.ioSchedulers.rules = drivesCfg.nvme.rules;
      services.udev.ioSchedulers.bfq.enabled =
        mkIf (drivesCfg.nvme.scheduler == "bfq") true;
      services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf (drivesCfg.nvme.scheduler == "mq-deadline") true;
      services.udev.ioSchedulers.kyber.enabled =
        mkIf (drivesCfg.nvme.scheduler == "kyber") true;
    })
    (mkIf drivesCfg.ssd.enable {
      services.udev.ioSchedulers.rules = drivesCfg.ssd.rules;
      services.udev.ioSchedulers.bfq.enabled =
        mkIf (drivesCfg.ssd.scheduler == "bfq") true;
      services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf (drivesCfg.ssd.scheduler == "mq-deadline") true;
      services.udev.ioSchedulers.kyber.enabled =
        mkIf (drivesCfg.ssd.scheduler == "kyber") true;
    })
    (mkIf cfg.ioSchedulers.enable {
      services.udev.packages = mkIf (cfg.ioSchedulers.rules != "")
        [ ioSchedulersUdevRules ];
    })
    (mkIf initrdDrivesCfg.hdd.enable {
      boot.initrd.services.udev.ioSchedulers.rules =
        initrdDrivesCfg.hdd.rules;
      boot.initrd.services.udev.ioSchedulers.bfq.enabled =
        mkIf (initrdDrivesCfg.hdd.scheduler == "bfq") true;
      boot.initrd.services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf (initrdDrivesCfg.hdd.scheduler == "mq-deadline") true;
      boot.initrd.services.udev.ioSchedulers.kyber.enabled =
        mkIf (initrdDrivesCfg.hdd.scheduler == "kyber") true;
    })
    (mkIf initrdDrivesCfg.nvme.enable {
      boot.initrd.services.udev.ioSchedulers.rules =
        initrdDrivesCfg.nvme.rules;
      boot.initrd.services.udev.ioSchedulers.bfq.enabled =
        mkIf (initrdDrivesCfg.nvme.scheduler == "bfq") true;
      boot.initrd.services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf (initrdDrivesCfg.nvme.scheduler == "mq-deadline") true;
      boot.initrd.services.udev.ioSchedulers.kyber.enabled =
        mkIf (initrdDrivesCfg.nvme.scheduler == "kyber") true;
    })
    (mkIf initrdDrivesCfg.ssd.enable {
      boot.initrd.services.udev.ioSchedulers.rules =
        initrdDrivesCfg.ssd.rules;
      boot.initrd.services.udev.ioSchedulers.bfq.enabled =
        mkIf (initrdDrivesCfg.ssd.scheduler == "bfq") true;
      boot.initrd.services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf (initrdDrivesCfg.ssd.scheduler == "mq-deadline") true;
      boot.initrd.services.udev.ioSchedulers.kyber.enabled =
        mkIf (initrdDrivesCfg.ssd.scheduler == "kyber") true;
    })
    (mkIf initrdCfg.ioSchedulers.enable {
      boot.initrd.extraUdevRulesCommands = mkIf
        (!config.boot.initrd.systemd.enable &&
          initrdCfg.ioSchedulers.rules != "")
        ''
          cp -v ${initrdIoSchedulersUdevRules}/etc/udev/rules.d/*.rules "$out"/
        '';
      boot.initrd.availableKernelModules = mkMerge [
        (mkIf initrdCfg.ioSchedulers.bfq.enabled [ "bfq" ])
        (mkIf initrdCfg.ioSchedulers.mq-deadline.enabled [ "mq-deadline" ])
        (mkIf initrdCfg.ioSchedulers.kyber.enabled [ "kyber" ])
      ];
      boot.initrd.services.udev.packages = mkIf
        (initrdCfg.ioSchedulers.rules != "")
        [ initrdIoSchedulersUdevRules ];
      services.udev.ioSchedulers.bfq.enabled =
        mkIf initrdCfg.ioSchedulers.bfq.enabled true;
      services.udev.ioSchedulers.mq-deadline.enabled =
        mkIf initrdCfg.ioSchedulers.mq-deadline.enabled true;
      services.udev.ioSchedulers.kyber.enabled =
        mkIf initrdCfg.ioSchedulers.kyber.enabled true;
    })
  ];
}
