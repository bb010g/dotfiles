{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.squeezelite;
  finalProgramPath = cfg.finalPackage + "/bin/${cfg.finalPackage.meta.mainProgram}";
  stateDir = "squeezelite";
in
{
  options = {
    services.squeezelite = {
      enable = lib.mkEnableOption "the Squeezelite headless player for Lyrion Music Server";

      package = lib.mkPackageOption pkgs "Squeezelite" { default = [ "squeezelite" ]; };

      finalPackage = lib.mkPackageOption pkgs "configured Squeezelite" { default = null; } // {
        readOnly = true;
      };

      audioBackend.pulseAudio.enable = lib.mkEnableOption "PulseAudio backend";

      extraArgs = lib.mkOption {
        type = lib.types.str;
        description = ''Extra command-line arguments to pass to Squeezelite.'';
        default = "";
      };
    };
  };

  config = lib.mkMerge [
    {
      services.squeezelite.finalPackage =
        if cfg.audioBackend.pulseAudio.enable then
          cfg.package.override {
            audioBackend = "pulse";
            pulseSupport = null;
          }
        else
          cfg.package;
    }
    (lib.mkIf cfg.enable {
      home.packages = [ cfg.finalPackage ];

      systemd.user.services.squeezelite = {
        Unit = {
          After = [
            "network.target"
            "sound.target"
          ];
          Description = "Squeezelite headless player for Lyrion Music Server";
          Documentation = "man:squeezelite(5)";
          Wants = [ "sound.target" ];
        };
        Service = {
          ExecStart = "${finalProgramPath} -N %S/${stateDir}/player-name ${cfg.extraArgs}";
          StateDirectory = stateDir;
          Type = "exec";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    })
  ];
}
