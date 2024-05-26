moduleArgs@{ config, lib, modulesPath, pkgs, utils, ... }:

let
  utils = moduleArgs.utils // import ../../../lib/utils.nix { inherit config lib pkgs utils; };
in
{
  config = lib.mkMerge [
    {
      programs.firefox.preferences = {
        "browser.compactmode.show" = true;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.sessionstore.restore_on_demand" = true;
        "browser.sessionstore.restore_pinned_tabs_on_demand" = true;
        "browser.tabs.unloadOnLowMemory" = lib.mkDefault false;
        "browser.tabs.warnOnClose" = lib.mkDefault true;
        "dom.memory.foreground_content_processes_have_larger_page_cache" = lib.mkDefault true;
        # From <https://searchfox.org/mozilla-central/rev/f967675ec87bb200b5b911b6fd0fb8c1e06c5167/modules/libpref/init/StaticPrefList.yaml#3136-3143>:
        # > 0 no-op
        # > 1 free dirty mozjemalloc pages
        # > 2 trigger memory-pressure/heap-minimize
        # > 3 trigger memory-pressure/low-memory
        # Used in <https://searchfox.org/mozilla-central/rev/f967675ec87bb200b5b911b6fd0fb8c1e06c5167/dom/ipc/ContentChild.cpp#2786-2797>.
        "dom.memory.memory_pressure_on_background" = lib.mkDefault 2;
      };
      programs.firefox.preferencesStatus = "default";
    }
  ];
}
