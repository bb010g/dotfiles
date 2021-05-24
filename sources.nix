let
  systemBoot = builtins.currentSystem;
  sourcesBoot = import ./nix/sources.nix { system = systemBoot; };
  nixpkgsBoot = import sourcesBoot.nixpkgs { system = systemBoot; };
  libBoot = import (sourcesBoot.nixpkgs + "/lib");
  makeScopeBoot = libBoot.makeScope;
  newScopeBoot = libBoot.callPackageWith;
in makeScopeBoot newScopeBoot (self: let
  inherit (self) sources;
in {
  sources = sourcesBoot // {
  };
  sources-ext = builtins.fromJSON (builtins.readFile ./nix/sources-ext.json);

  nur = { pkgs }: import ./config-nur.nix {
    inherit pkgs;
    nur-local = null;
    nur-remote = sources.nur;
  };
})
