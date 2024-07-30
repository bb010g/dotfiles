{ ... }:
finalPkgs: prevPkgs:
if prevPkgs ? neovim-stable-unwrapped then {
} else {
  neovim-stable = finalPkgs.wrapNeovim finalPkgs.neovim-stable-unwrapped { };
  neovim-stable-unwrapped = prevPkgs.neovim-unwrapped;
  neovim-unwrapped = finalPkgs.neovim-stable-unwrapped;
}
