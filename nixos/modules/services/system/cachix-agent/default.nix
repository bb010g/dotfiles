{ config, lib, ... }:

let
  cfg = config.services.cachix-agent;
  serviceCfg = config.systemd.services.cachix-agent;
in {
  config = lib.mkIf cfg.enable {
    systemd.services.cachix-agent = {
      serviceConfig = {
        RestartMaxDelaySec = 300;
        RestartSteps = 20;
      };
    };
  };
}
