{ config, lib, pkgs, ... }:

{
  imports = [
    ../secrets/mpd.nix
  ];

  config = {
    home.packages = [
      pkgs.cantata
      pkgs.mpc_cli
    ];

    services.mpd = {
      enable = true;
      daemons = rec {
        default = {
          autoStart = false;
          extraConfig = ''
            audio_output {
              type "pulse"
              name "PulseAudio"
            }
          '';
          package = pkgs.mpd;
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
        nas = external // {
          network.port = 6603;
        };
      };
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
