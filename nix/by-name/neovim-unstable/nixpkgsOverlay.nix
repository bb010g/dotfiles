{ inputs, ... }:
finalPkgs: prevPkgs:
let
  inherit (finalPkgs)
    lib
    ;
  inherit (lib)
    any
    attrNames
    concatMap
    const
    elemAt
    flip
    foldl'
    listToAttrs
    map
    mapAttrs
    match
    mirrorFunctionArgs
    optionals
    pipe
    readFile
    remove
    splitString
    substring
    toLower
    warn
    ;
  concatMapAttrsToList = f: attrs:
    concatMap (name: f name attrs.${name}) (attrNames attrs);
in
if prevPkgs ? neovim-unstable-unwrapped then {
  neovim-unstable = prevPkgs.neovim-unstable or (finalPkgs.wrapNeovim finalPkgs.neovim-unstable-unwrapped { });
} else {
  neovim-stable-unwrapped = prevPkgs.neovim-stable-unwrapped.overrideAttrsWithArgs
    ({ fetchurl, useTreesitterParserDeps ? false, ... }: finalAttrs: prevAttrs: {
      treesitter-parsers =
        if useTreesitterParserDeps then
          pipe finalAttrs.passthru.deps [
            (concatMapAttrsToList (name: value:
              let
                nameMatches = match "treesitter_(.*)" name;
                name' = elemAt nameMatches 0;
              in
              if nameMatches != null then
                [ { name = name'; value.src = fetchurl value; } ]
              else
                [ ]))
            listToAttrs
            (treesitter-parsers: treesitter-parsers // {
              markdown = treesitter-parsers.markdown // { location = "tree-sitter-markdown"; };
              markdown_inline = treesitter-parsers.markdown // { language = "markdown_inline"; location = "tree-sitter-markdown-inline"; };
            })
          ]
        else
          prevAttrs.treesitter-parsers;
      passthru.deps = prevAttrs.passthru.deps or (pipe "${finalAttrs.src}/cmake.deps/deps.txt" [
        readFile
        (splitString "\n")
        (concatMap (str:
          let
            matches = match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*" str;
          in
          optionals (matches != null) [ matches ]))
        (flip foldl' { } (deps: matches:
          let
            depName = toLower (elemAt matches 0);
            name = toLower (elemAt matches 1);
            value = elemAt matches 2;
          in
          deps // {
            ${depName} = deps.${depName} or { } // {
              ${name} = value;
            };
          }))
      ]);
    })
    { };
  neovim-unstable-unwrapped = finalPkgs.neovim-stable-unwrapped.overrideAttrsWithArgs ({ fetchurl, utf8proc, ... }: finalAttrs: prevAttrs: {
    buildInputs =
      prevAttrs.buildInputs ++
      (if any (p: p.name == "utf8proc") prevAttrs.buildInputs then
        warn "neovim already depends on utf8proc" [ ]
      else
        [
          (utf8proc.overrideAttrs {
            src = fetchurl finalAttrs.passthru.deps.utf8proc;
          })
        ]);
    version = finalAttrs.src.shortRev or (if finalAttrs.src ? rev then substring 0 8 finalAttrs.src.rev else "dirty");
    src = inputs.neovim;
    preConfigure = prevAttrs.preConfigure or "" + ''
      sed -i cmake.config/versiondef.h.in -e 's/@NVIM_VERSION_PRERELEASE@/-dev+${finalAttrs.version}/'
    '';
  }) (prevArgs: let
    newArgs = finalPkgs.callPackage ({ utf8proc }: { inherit utf8proc; }) { };
  in {
    tree-sitter = prevArgs.tree-sitter.overrideAttrsWithArgs ({ ... }: prevAttrs: {
      postPatch = prevAttrs.postPatch or "" + ''
        sed -e 's/playground::serve(.*$/println!("ERROR: web-ui is not available in this Nixpkgs build; enable the webUISupport"); std::process::exit(1);/' \
            -i cli/src/main.rs
      '';
    }) (prevArgs': {
      rustPlatform = prevArgs'.rustPlatform // {
        buildRustPackage = mirrorFunctionArgs prevArgs'.rustPlatform.buildRustPackage (args: prevArgs'.rustPlatform.buildRustPackage (args // {
          version = "bundled";
          src = prevArgs.fetchurl finalPkgs.neovim-unstable-unwrapped.passthru.deps.treesitter;
          cargoHash = "sha256-umNoJn5fctYk3J2ekYjJx1fCwfAMspEHjmYUvw6Qb0Y=";
        }));
      };
    });
    useTreesitterParserDeps = true;
    utf8proc = prevArgs.utf8Proc or newArgs.utf8proc;
  });
  neovim-unstable = finalPkgs.wrapNeovim finalPkgs.neovim-unstable-unwrapped { };
}
