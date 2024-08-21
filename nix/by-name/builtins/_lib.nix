let
  baseLib.builtins = (builtins.import ./_builtins.nix builtins baseLib.builtins).builtins;
  lib = baseLib.builtins.import ./lib.nix baseLib lib;
in
lib
