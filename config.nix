{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = let local = ~/nix/nur; in import (
      if builtins.pathExists local then local else
        builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz"
    ) {
      inherit pkgs;
      repoOverrides = {
        bb010g = { type = "path"; url = ~/nix/nur-bb010g; };
        nexromancers = { type = "path"; url = ~/nix/nur-nexromancers; };
      };
    };
  };
}
