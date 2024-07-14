{ config, lib, ... }:

{
  config = {
    systemd.user.targets.tray-pre = {
      Unit = {
        Before = [ "tray.target" ];
        Description = "Session services which should run early before the graphical system tray is brought up";
        RefuseManualStart = true;
        StopWhenUnneeded = true;
      };
    };
    # TODO: rename to graphical-tray
    systemd.user.targets.tray = {
      Unit = {
        After = [ "graphical-session.target" ];
        BindsTo = [ "graphical-session.target" ];
        Description = "Current graphical user system tray";
        RefuseManualStart = true;
        Requires = [ "graphical-session.target" ];
        StopWhenUnneeded = true;
      };
    };
  };
}
