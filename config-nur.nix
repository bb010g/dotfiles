{ pkgs
, nur-local ? trace "config-nur nur-local default" ~/nix/nur
, nur-remote ? trace "config-nur nur-remote fetch default"
    (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz")
, repoOverrides ? trace "config-nur repoOverrides default" {
    bb010g = ~/nix/nur-bb010g;
    nexromancers = ~/nix/nur-nexromancers;
  }
, trace ? _: y: y
}:

let
  inherit (builtins) pathExists;
  mapAttrs' = builtins.mapAttrs' or (f: set:
    builtins.listToAttrs
      (builtins.map (attr: f attr set.${attr}) (builtins.attrNames set)));

  nur-path = if nur-local != null && pathExists nur-local then
    trace "nur-local ${toString nur-local}" nur-local
  else
    trace "nur-remote" nur-remote;
  passedArgs = { inherit pkgs; inherit trace; };
in trace "importing nur" (import nur-path ({
  pkgs = trace "nur arg pkgs" pkgs;
  repoOverrides = mapAttrs' (n: v: {
    name = trace "override pathExists ${toString v}"
      (if pathExists v then n else null);
    value = let e = trace "override imported ${toString v}" (import v); in
      e (builtins.intersectAttrs (builtins.functionArgs e) passedArgs);
  }) repoOverrides;
}))

# vim:et:sw=2:tw=78
