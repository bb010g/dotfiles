{ pkgs
, nur-local ? trace "config-nur nur-local default" ~/nix/nur
, nur-remote ? trace "config-nur nur-remote fetch default"
    (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz")
, repoOverrides' ? trace "config-nur tryRepoOverrides default" [
    "bb010g"
    "mozilla"
    "nexromancers"
  ]
, repoOverrides ? trace "config-nur repoOverrides default" {
  }
, trace ? _: e2: e2
}:

let
  inherit (builtins) pathExists;
  mapAttrs' = builtins.mapAttrs' or (f: set:
    builtins.listToAttrs
      (builtins.map (attr: f attr set.${attr}) (builtins.attrNames set)));
  traceMsg' = sep: msg1: msg2: trace (toString msg1 + sep + toString msg2);
  traceMsg = traceMsg' " ";
  traceVal = msg: e: traceMsg msg e e;

  nur-path = if nur-local != null && pathExists nur-local then
    trace "nur-local ${toString nur-local}" nur-local
  else
    trace "nur-remote" nur-remote;
  passedArgs = { inherit pkgs; inherit trace; };

  nur-manifest =
    (builtins.fromJSON (builtins.readFile (nur-path + "/repos.json"))).repos;

  repoOverrides'' =
    (builtins.listToAttrs
      (builtins.map
        (repo: { name = repo; value = ~/nix + "/nur-${repo}"; })
        repoOverrides')) // repoOverrides;
in trace "importing nur" (import nur-path ({
  pkgs = trace "nur arg pkgs" pkgs;
  repoOverrides = mapAttrs' (n: v: traceMsg "override" n (let
      p = traceVal "override path"
        (v + ("/" + ((nur-manifest.${n} or { }).file or "")));
    in {
      name = traceMsg "override pathExists" p
        (if pathExists p then n else null);
      value = let
        e = traceMsg "override imported" p (import p);
      in e (builtins.intersectAttrs (builtins.functionArgs e) passedArgs);
    }))
    repoOverrides'';
}))

# vim:et:sw=2:tw=78
