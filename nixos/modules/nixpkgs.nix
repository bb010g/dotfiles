moduleArgs@{ config, lib, ... }:

let
  flakeInputs = moduleArgs.flakeInputs or { };
  neovimInput = flakeInputs.neovim or null;
in
{
  config = {
    nixpkgs.overlays = [
      (finalPkgs: prevPkgs: {
        # stable pkgs
        neovim-stable-unwrapped = prevPkgs.neovim-unwrapped;
        neovim-stable = finalPkgs.wrapNeovim finalPkgs.neovim-stable-unwrapped { };
        # pkgs
        neovim-unwrapped = finalPkgs.neovim-stable-unwrapped;
      })
    ] ++ lib.optionals (neovimInput != null) [
      (finalPkgs: prevPkgs:
      let
        overridePkgs = neovimInput.overlay
          (finalPkgs // {
            neovim = finalPkgs.neovim-unwrapped;
            neovim-debug = finalPkgs.neovim-debug-unwrapped;
            neovim-developer = finalPkgs.neovim-developer-unwrapped;
          })
          prevPkgs;
        stableOverridePkgs = neovimInput.overlay
          (finalPkgs // {
            neovim-unwrapped = finalPkgs.neovim-stable-unwrapped;
            neovim = finalPkgs.neovim-stable-unwrapped;
            neovim-debug = finalPkgs.neovim-debug-stable-unwrapped;
            neovim-developer = finalPkgs.neovim-developer-stable-unwrapped;
          })
          prevPkgs;
        unstableOverridePkgs = neovimInput.overlay
          (finalPkgs // {
            neovim-unwrapped = finalPkgs.neovim-unstable-unwrapped;
            neovim = finalPkgs.neovim-unstable-unwrapped;
            neovim-debug = finalPkgs.neovim-debug-unstable-unwrapped;
            neovim-developer = finalPkgs.neovim-developer-unstable-unwrapped;
          })
          prevPkgs;
      in
      {
        # pkgs
        neovim-debug-unwrapped = overridePkgs.neovim-debug;
        neovim-developer-unwrapped = overridePkgs.neovim-developer;
        # unstable pkgs
        neovim-unstable-unwrapped = stableOverridePkgs.neovim;
        neovim-unstable = finalPkgs.wrapNeovim finalPkgs.neovim-unwrapped-unstable { };
        # unstable developer pkgs
        neovim-debug-unstable-unwrapped = unstableOverridePkgs.neovim-debug;
        neovim-developer-unstable-unwrapped = unstableOverridePkgs.neovim-developer;
        # stable developer pkgs
        neovim-debug-stable-unwrapped = stableOverridePkgs.neovim-debug;
        neovim-developer-stable-unwrapped = stableOverridePkgs.neovim-developer;
      } // builtins.removeAttrs overridePkgs [ "neovim" "neovim-debug" "neovim-developer" ])
      (finalPkgs: prevPkgs: {
        neovim-unwrapped = finalPkgs.neovim-unstable-unwrapped;
      })
    ];
  };
}
