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
  (pkgsFinal: pkgsPrev: let
    addSearchPathOutput =
      let
        inherit (pkgsFinal.lib)
          concatStringsSep
          makeSearchPathOutput
          splitString
          unique
        ;
      in
      output:
      subDir:
      additionalPkgs:
      let
        additionalSearchPath =
          makeSearchPathOutput output subDir additionalPkgs;
        additionalSearchPathComponents = splitString ":" additionalSearchPath;
      in
      searchPath:
      let
        searchPathComponents = splitString ":" searchPath;
        mergedSearchPathComponents = unique
          (searchPathComponents ++ additionalSearchPathComponents);
      in
      concatStringsSep ":" mergedSearchPathComponents;
    addLibraryPath = addSearchPathOutput "lib" "lib";
  in {
    gitignore = import sources.gitignore { inherit (pkgsFinal) lib; };
    niv = (import sources.niv { pkgs = pkgsFinal; }).niv;
    nur = import ./config-nur.nix { pkgs = pkgsFinal; };
    nix-gl = import sources.nix-gl { pkgs = pkgsFinal; };
    # pythonInterpreters = pkgsPrev.pythonInterpreters.overrideScope (pyFinal: pyPrev: let
    #   inherit (pyFinal) callPackage;
    # in {
    # });
    # steamPackages = pkgsPrev.steamPackages.overrideScope (steamPackagesFinal: steamPackagesPrev: {
    # #   steam-runtime = steamPackagesPrev.steam-runtime.overrideAttrs (attrsPrev: rec {
    # #     version = "0.20210630.0";
    # #     src = pkgsFinal.fetchurl {
    # #       url = "https://repo.steampowered.com/steamrt-images-scout/snapshots/${version}/steam-runtime.tar.xz";
    # #       sha256 = "sha256-vwSgk3hEaI/RO9uvehAx3+ZBynpqjwGDzuyeyGCnu18=";
    # #       name = "scout-runtime-${version}.tar.gz";
    # #     };
    # #   });
    # # })).overrideScope (steamPackagesFinal: steamPackagesPrev: {
    #   steam-fhsenv = steamPackagesPrev.steam-fhsenv.override (argsPrev: {
    #     extraPkgs = pkgs: (argsPrev.extraPkgs or (pkgs': [ ]) pkgs) ++ [
    #       pkgs.harfbuzz
    #       pkgs.libthai
    #       pkgs.pango
    #     ];
    #   });
    # });
    webex = pkgsFinal.callPackage ./webex {
      enableWayland = true;
    };
    firefox-bin-unwrapped = pkgsPrev.firefox-bin-unwrapped.overrideAttrs (attrsPrev: {
      # TODO: remove after commit
      #   "firefox-bin: add libXtst and libXrandr to lib path"
      libPath = addLibraryPath [
        pkgsFinal.xorg.libXrandr
        pkgsFinal.xorg.libXtst
      ] attrsPrev.libPath or "";
    });
  })
]
