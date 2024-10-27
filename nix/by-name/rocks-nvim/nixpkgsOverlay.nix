{ inputs, ... }:
finalPkgs: prevPkgs:
{
  luaPackagesExtensions = prevPkgs.luaPackagesExtensions ++ [
    (finalLuaPackages: prevLuaPackages: {
      rocks-nvim = prevLuaPackages.rocks-nvim.overrideAttrs (finalAttrs: prevAttrs: {
        version = "scm-1";
        knownRockspec = "${finalAttrs.src}/rocks.nvim-scm-1.rockspec";
        src = inputs.rocks-nvim;
      });
    })
  ];

  vimPlugins = prevPkgs.vimPackages.extend (finalVimPlugins: prevVimPlugins: {
    rocks-nvim = final.neovimUtils.buildNeovimPlugin {
      luaAttr = final.neovim-unwrapped.lua.pkgs.rocks-nvim;
    };
  });
}
