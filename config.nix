{
  allowUnfree = true;
  extraOptions = "keep-outputs = true";
  packageOverrides = pkgs: {

    # hyperfine 1.4.0
    hyperfine = pkgs.callPackage <nixos-unstable/pkgs/tools/misc/hyperfine> {
      inherit (pkgs.darwin.apple_sdk.frameworks) Security;
    };

    nur = let
      inherit (pkgs) lib;
      local = ~/nix/nur;
      passedArgs = { inherit pkgs; };
    in import (
      if builtins.pathExists local then local else
        builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz"
    ) {
      inherit pkgs;
      repoOverrides = lib.mapAttrs' (n: v: {
        name = if builtins.pathExists v then n else null;
        value = let e = import v; in
          e (builtins.intersectAttrs (builtins.functionArgs e) passedArgs);
      }) {
        bb010g = ~/nix/nur-bb010g;
        nexromancers = ~/nix/nur-nexromancers;
      };
    };

  };
}
