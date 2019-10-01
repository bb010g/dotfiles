let sources = import ./nix/sources.nix; in
{
  allowUnfree = true;
  android_sdk.accept_license = true;
  packageOverrides = pkgs: {
    gitignore = import sources.gitignore { inherit (pkgs) lib; };
    niv = import sources.niv { inherit pkgs; };
    nur = import ./config-nur.nix { inherit pkgs; };
    lorri = import sources.lorri { };
    lorri-unstable = import sources.lorri-unstable { };
  };
}

# vim:et:sw=2:tw=78
