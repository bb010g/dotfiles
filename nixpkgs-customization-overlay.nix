let
  inherit (builtins) hasAttr listToAttrs map;

  flow = f: g: x: g (f x);

  mapAttr = name: f: set: set // { ${name} = f set.${name}; };
  mapAttrOr = name: f: nul: set: if hasAttr name set then mapAttr name f set else nul;
  mapAttrOrElse = name: f: nulF: set: mapAttrOr name f (nulF name set) set;

  isOverridable = hasAttr "override";
  isScope = hasAttr "overrideScope";
in
pkgsFinal: pkgsPrev: let
  inherit (pkgsFinal.lib) composeExtensions makeOverridable;
  attachScope = f: genFinal:
    let final = genFinal final // {
      overrideScope = g: attachScope (composeExtensions f g) genFinal;
      overrideScopeGenFinal = g: attachScope f (g genFinal);
      scopeGenFinal = genFinal;
      scopeOverrides = f;
    }; in final;
  attachEmptyScope = attachScope (final: prev: { });
in {
  fetchFromGitHub = let
    fetchPrev = pkgsPrev.fetchFromGitHub;
  in if isOverridable (fetchPrev { owner = null; repo = null; rev = null; })
    then fetchPrev
    else makeOverridable fetchPrev;

  pythonInterpreters = let
    pyInterpsPrev = pkgsPrev.pythonInterpreters;
  in if isScope pyInterpsPrev then pyInterpsPrev else attachEmptyScope (final:
    pyInterpsPrev.override (mapAttr "pkgs" (pkgs':
      mapAttr "callPackage" (callPackage:
        fn: flow (mapAttrOrElse "overrides" (overrides:
          pkgs'.lib.composeExtensions final.scopeOverrides overrides
        ) (pyFinal: pyPrev: pyPrev)) (callPackage fn)
      ) pkgs'
    ))
  );

  steamPackages = pkgsFinal.dontRecurseIntoAttrs (pkgsFinal.callPackage ./nixpkgs-steam-customisation.nix {
    buildFHSUserEnv = pkgsFinal.buildFHSUserEnvBubblewrap;
  });
}
