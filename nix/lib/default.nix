let
  moduleDataForPath = import ./_moduleDataForPath.nix;
  popLib = import ./_pop.nix;
  finalLib = {
    _moduleDataForPath = moduleDataForPath;
    _pop = popLib;
  };
in finalLib
