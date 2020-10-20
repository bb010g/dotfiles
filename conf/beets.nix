let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:

{
  imports = [
    ../secrets/tokens.nix
  ];

  config = {
    programs.beets = {
      enable = true;
      package = srcs.nixpkgs-unstable.beets;
      settings = {
        plugins = [
          # autotagger
          "chroma"
          "discogs"
          "fromfilename"
          # metadata
          # "absubmit" (needs streaming_music_extractor)
          "acousticbrainz"
          "fetchart"
          "ftintitle"
          "lastgenre"
          "lyrics"
          "mbsync"
          "replaygain"
          "scrub"
          # path formats
          "rewrite"
          "the"
          # interoperability
          "badfiles"
          "mpdupdate"
          # miscellaneous
          "convert"
          "duplicates"
          "export"
          "fuzzy"
          "info"
          "mbsubmit"
          "missing"
        ];

        acoustid.apikey = config.secrets.tokens.acoustid;
        badfiles = {
          commands = {
          };
        };
        convert = {
          embed = "no";
          format = "opus";
          formats = {
            opus = {
              # TODO: 256k is probably *reallY* high?
              # TODO: use opusenc instead?
              command = "${pkgs.ffmpeg} -i $source -y -map_metadata 0 -c:a libopus -b:a 256k $dest";
            };
          };
        };
        discogs.user_token = config.secrets.tokens.discogs;
        lyrics.google_API_key = config.secrets.tokens.google-custom-search;
        paths = {
          "default" = "%the{$albumartist}/%the{$album}%aunique{}/$track $title";
          "singleton" = "Non-Album/%the{$artist}/$title";
          "comp" = "Compilations/%the{$album}%aunique{}/$track $title";
        };
        replaygain = {
          # TODO: replace with software not maintained by a neo-Nazi
          backend = "bs1770gain";
        };
        mpd = {
          port = config.services.mpd.daemons.default.network.port;
        };
      };
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
