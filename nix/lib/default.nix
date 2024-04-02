let
  inherit (builtins)
    ;
  inherit (_lib.paths)
    getNixSourceDirEntries
    readDirEntries
    ;

  _lib = import ./_lib.nix;
in {
  inherit _lib;
  nixSourceDirEntries = getNixSourceDirEntries {
    dirEntries = readDirEntries ./.;
  };
}
