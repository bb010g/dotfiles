let
  systemBoot = builtins.currentSystem;
  sourcesBoot = import ./nix/sources.nix { system = systemBoot; };
  nixpkgsBoot = import sourcesBoot.nixpkgs { system = systemBoot; };
  libBoot = import (sourcesBoot.nixpkgs + "/lib");
  makeScopeBoot = libBoot.makeScope;
  newScopeBoot = libBoot.callPackageWith;
in makeScopeBoot newScopeBoot (self: let
  inherit (self) importFirstExists sources;
in {
  tryEval' = t: f: e:
    let e' = builtins.tryEval e; in if e'.success then t e'.value else f;
  tryPathExists = self.tryEval' libBoot.pathExists false;
  importFirstExists = default: list:
    import (libBoot.findFirst self.tryPathExists default list);

  nixpkgsArg = {
    # system = self.nixpkgsSystem;
    # config = self.nixpkgsConfig;
    # overlays = self.nixpkgsOverlays;
    # crossOverlays = self.nixpkgsCrossOverlays;
  };
  # nixpkgsSystem = systemBoot;
  # nixpkgsConfig = {
  # };
  # nixpkgsOverlays = [
  #   (nixpkgs: nixpkgsSuper: {
  #   })
  # ];
  # nixpkgsCrossOverlays = [
  # ];
  # nixpkgs = self.nixpkgs-stable;
  # lib = nixpkgs.lib;

  sources = sourcesBoot // {
  };
  sources-ext = builtins.fromJSON (builtins.readFile ./nix/sources-ext.json);

  nur = { pkgs }: import ./config-nur.nix {
    inherit pkgs;
    nur-local = null;
    nur-remote = sources.nur;
  };

  nixpkgsArg-stable = self.nixpkgsArg;
  nixpkgsFun-stable = importFirstExists sources.nixpkgs-stable [
    <nixos-20.03>
    <nixos>
    <nixpkgs>
  ];
  nixpkgs-stable = self.nixpkgsFun-stable self.nixpkgsArg-stable;
  lib-stable = self.nixpkgs-stable.lib;
  nixpkgsArg-unstable = self.nixpkgsArg;
  nixpkgsFun-unstable = importFirstExists sources.nixpkgs-unstable [
    <nixos-unstable>
    <nixpkgs-unstable>
  ];
  nixpkgs-unstable = self.nixpkgsFun-unstable self.nixpkgsArg-stable;
  lib-unstable = self.nixpkgs-unstable.lib;
  nixpkgsArg-unstable-bb010g = self.nixpkgsArg;
  nixpkgsFun-unstable-bb010g = importFirstExists
    sources.nixpkgs-unstable-bb010g
  [
    <nixos-unstable-bb010g>
    <nixpkgs-unstable-bb010g>
    <bb010g-nixos-unstable>
    <bb010g-nixpkgs-unstable>
  ];
  nixpkgs-unstable-bb010g =
    self.nixpkgsFun-unstable-bb010g self.nixpkgsArg-unstable-bb010g;
  lib-unstable-bb010g = self.nixpkgs-unstable-bb010g.lib;
})
