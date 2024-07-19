{ inputs, ... }:
finalPkgs: prevPkgs:
let
  inherit (finalPkgs)
    lib
    ;
  inherit (lib)
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
    optionals
    pipe
    readFile
    remove
    splitString
    substring
    toLower
    ;
  concatMapAttrsToList = f: attrs:
    concatMap (name: f name attrs.${name}) (attrNames attrs);
in
if prevPkgs ? neovim-unstable-unwrapped then {
  neovim-unstable = prevPkgs.neovim-unstable or (finalPkgs.wrapNeovim finalPkgs.neovim-unstable-unwrapped { });
} else {
  neovim-stable-unwrapped = prevPkgs.neovim-stable-unwrapped.overrideAttrsWithArgs ({ fetchurl, useTreesitterParserDeps ? false, ... }: finalAttrs: prevAttrs: {
    treesitter-parsers =
      if useTreesitterParserDeps then
        pipe finalAttrs.passthru.deps [
          (concatMapAttrsToList (name: value:
            let
              nameMatches = match "TREESITTER_(.*)" name;
              name' = elemAt nameMatches 0;
            in
            if nameMatches != null then
              [ { name = toLower name'; value.src = fetchurl value; } ]
            else
              [ ]))
          listToAttrs
          (treesitter-parsers: treesitter-parsers // {
            markdown = treesitter-parsers.markdown // { location = "tree-sitter-markdown"; };
            markdown-inline = treesitter-parsers.markdown // { language = "markdown_inline"; location = "tree-sitter-markdown-inline"; };
          })
        ]
      else
        prevAttrs.treesitter-parsers;
    passthru.deps = prevAttrs.passthru.deps or (pipe "${finalAttrs.src}/cmake.deps/deps.txt" [
      readFile
      (splitString "\n")
      (concatMap (str:
        let
          matches = match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*";
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
  });
  neovim-unstable-unwrapped = (finalPkgs.neovim-stable-unwrapped.override {
    useTreesitterParserDeps = true;
  }).overrideAttrs (finalAttrs: prevAttrs: {
    version = finalAttrs.src.shortRev or (if finalAttrs.src ? rev then substring 0 8 finalAttrs.src.rev else "dirty");
    src = inputs.neovim;
    preConfigure = prevAttrs.preConfigure or "" + ''
      sed -i cmake.config/versiondef.h.in -e 's/@NVIM_VERSION_PRERELEASE@/-dev+${finalAttrs.version}/'
    '';
  });
  neovim-unstable = finalPkgs.wrapNeovim finalPkgs.neovim-unstable-unwrapped { };
}
