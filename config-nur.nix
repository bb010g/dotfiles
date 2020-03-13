{ pkgs
, nur-local ? ~/nix/nur
, nur-remote ? builtins.fetchTarball
    "https://github.com/nix-community/NUR/archive/master.tar.gz"
, repoOverrides' ? [
    "bb010g"
    "nexromancers"
  ]
, repoOverrides ? {
  }
, trace ? _: e2: e2
}:

let
  inherit (builtins) mapAttrs pathExists;
  mapAttrs' = builtins.mapAttrs' or (f: set:
    builtins.listToAttrs
      (builtins.map (attr: f attr set.${attr}) (builtins.attrNames set)));

  nur-path = if nur-local != null && pathExists nur-local then
    nur-local
  else
    nur-remote;
  passedArgs = {
    inherit pkgs;
    inherit trace;
    enablePkgsCompat = false;
  };

  nur-manifest =
    (builtins.fromJSON (builtins.readFile (nur-path + "/repos.json"))).repos;

  repoOverrides'' =
    (builtins.listToAttrs
      (builtins.map
        (repo: { name = repo; value = ~/nix + "/nur-${repo}"; })
        repoOverrides')) // repoOverrides;
in let nur = import nur-path ({
  inherit pkgs;
  repoOverrides = mapAttrs'
    (n: v: let
      p = v + ("/" + ((nur-manifest.${n} or { }).file or ""));
    in {
      name = if pathExists p then n else null;
      value = let
        e = import p;
      in e (builtins.intersectAttrs (builtins.functionArgs e) passedArgs);
    })
    repoOverrides'';
}); in nur // {
  lib = mapAttrs (_: r: r.lib) nur.repos;
  modules = mapAttrs (_: r: r.modules) nur.repos;
  overlays = mapAttrs (_: r: r.overlays) nur.repos;
  pkgs = mapAttrs (_: r: r.pkgs) nur.repos;
}

# vim:et:sw=2:tw=78
