let
  inherit (builtins) isAttrs;

  # nixpkgs/lib/trivial.nix
  setFunctionArgs = f: args: { __functor = self: f; __functionArgs = args; };
  isFunction = let
    isFunction' = builtins.isFunction;
  in f: isFunction' f || (f ? __functor && isFunction (f.__functor f));
  functionArgs = let
    functionArgs' = builtins.functionArgs;
  in f: f.__functionArgs or functionArgs' f;

  setFunctionArgs' = f: args:
    if isAttrs f && f ? __functor
      then f // { __functionArgs = args; }
      else setFunctionArgs f args;
  mapFunctionArgs = f: fun: setFunctionArgs' fun (f (functionArgs fun));
  wrapFunction = wrapperFnFn: origFn: let
    wrapperFn = wrapperFnFn origFn;
    origArgs = functionArgs origFn;
  in mapFunctionArgs (wrapperArgs: origArgs // wrapperArgs) wrapperFn;
  override = f: newArgs: if isFunction newArgs then f.override newArgs else
    mapFunctionArgs (fArgs: fArgs // functionArgs newArgs) (f.override newArgs);
in
let sources = import ./nix/sources.nix; in
[
  (import ./nixpkgs-customization-overlay.nix)
  (pkgs: pkgsSuper: {
    gitignore = import sources.gitignore { inherit (pkgs) lib; };
    niv = (import (pkgs.applyPatches {
      src = sources.niv;
      name = "niv-src";
      patches = [
        (builtins.toFile "niv-lib.patch" /*patch*/''
--- a/foo/default.nix
+++ b/foo/default.nix
@@ -76,7 +76,7 @@ mkDerivation {
               description = spec.synopsis;
               license =
                 if builtins.hasAttr "license" spec && spec.license == "MIT"
-                then stdenv.lib.licenses.mit
+                then lib.licenses.mit
                 else throw "Don't know how to handle license: ''${builtins.toJSON spec.license}";
             }
         ) {};
'')
      ];
    }) { inherit pkgs; }).niv;
    nur = import ./config-nur.nix { inherit pkgs; };
    nix-gl = import sources.nix-gl { inherit pkgs; };
    pythonInterpreters = pkgsSuper.pythonInterpreters.overrideScope (pySelf: pySuper: let
      inherit (pySelf) callPackage;
    in {
    });
  })
]
