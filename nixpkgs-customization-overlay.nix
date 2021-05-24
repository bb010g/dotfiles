let
  inherit (builtins) hasAttr listToAttrs map;

  flow = f: g: x: g (f x);

  mapAttr = name: f: set: set // { ${name} = f set.${name}; };
  mapAttrOr = name: f: nul: set: if hasAttr name set then mapAttr name f set else nul;
  mapAttrOrElse = name: f: nulF: set: mapAttrOr name f (nulF name set) set;

  isOverridable = hasAttr "override";
  isScope' = hasAttr "overrideScope";
in
pkgs: pkgsSuper: let
  inherit (pkgs.lib) composeExtensions makeOverridable;
  attachScope' = f: genSelf:
    let self = genSelf self // {
      overrideScope = g: attachScope' (composeExtensions f g) genSelf;
      overrideScopeGenSelf = g: attachScope' f (g genSelf);
      scopeGenSelf = genSelf;
      scopeOverrides = f;
    }; in self;
  attachEmptyScope' = attachScope' (self: super: { });
in {
  fetchFromGitHub = let
    fetchSuper = pkgsSuper.fetchFromGitHub;
  in if isOverridable (fetchSuper { owner = null; repo = null; rev = null; })
    then fetchSuper
    else makeOverridable fetchSuper;

  pythonInterpreters = let
    pyInterpsSuper = pkgsSuper.pythonInterpreters;
  in if isScope' pyInterpsSuper then pyInterpsSuper else attachEmptyScope' (self:
    pyInterpsSuper.override (mapAttr "pkgs" (pkgs':
      mapAttr "callPackage" (callPackage:
        fn: flow (mapAttrOrElse "overrides" (overrides:
          pkgs'.lib.composeExtensions self.scopeOverrides overrides
        ) (pySelf: pySuper: pySuper)) (callPackage fn)
      ) pkgs'
    ))
  );
}
