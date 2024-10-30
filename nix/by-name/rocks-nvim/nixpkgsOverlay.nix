{ inputs, ... }:
finalPkgs: prevPkgs:
{
  luaPackagesExtensions = prevPkgs.luaPackagesExtensions ++ [
    (finalLuaPackages: prevLuaPackages: {
      rocks-nvim = prevLuaPackages.rocks-nvim.overrideAttrs (finalAttrs: prevAttrs: {
        knownRockspec = null;
        rockspecVersion = finalAttrs.version;
        src = inputs.rocks-nvim;
        version = "scm-1";
      });
    })
  ];
}
