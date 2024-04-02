{ config, lib, ... }:

{
  config = {
    nixpkgs.overlays = [
      (finalPkgs: prevPkgs: {
        libsForQt5 = prevPkgs.libsForQt5.overrideScope (finalLibsForQt5: prevLibsForQt5: {
          plasma5 = prevLibsForQt5.plasma5.overrideScope (finalPlasma5: prevPlasma5: {
            thirdParty = prevPlasma5.thirdParty // {
              polonium = prevPlasma5.thirdParty.polonium.overrideAttrs (finalAttrs: prevAttrs: {
                version = "1.0rc";
                src = prevAttrs.src.override {
                  rev = "v${finalAttrs.version}";
                  hash = "sha256-AdMeIUI7ZdctpG/kblGdk1DBy31nDyolPVcTvLEHnNs=";
                };
              });
            };
          });
          polonium = finalLibsForQt5.plasma5.thirdParty.polonium;
        });
      })
    ];
  };
}
