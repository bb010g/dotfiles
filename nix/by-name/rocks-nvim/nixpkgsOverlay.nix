{ inputs, ... }:
let
  inputNameOrNull = name: if inputs ? ${name} then name else null;
in
finalPkgs: prevPkgs:
let
  inherit (finalPkgs) lib;
  inherit (lib.lists) optionals;

  hasLuaPackagesExtensions =
    inputs ? rocks-nvim
    || inputs ? rocks-config-nvim
    || inputs ? rocks-dev-nvim
    || inputs ? rocks-git-nvim;
in
{
  luaPackagesExtensions =
    prevPkgs.luaPackagesExtensions
    ++ optionals hasLuaPackagesExtensions [
      (finalLuaPackages: prevLuaPackages: {
        ${inputNameOrNull "rocks-nvim"} = prevLuaPackages.rocks-nvim.overrideAttrs (
          finalAttrs: prevAttrs: {
            knownRockspec = null;
            rockspecFilename = null;
            rockspecVersion = "scm-1";
            src = inputs.rocks-nvim;
            version = finalAttrs.rockspecVersion;
          }
        );

        ${inputNameOrNull "rocks-config-nvim"} = prevLuaPackages.rocks-config-nvim.overrideAttrs (
          finalAttrs: prevAttrs: {
            knownRockspec = null;
            rockspecFilename = null;
            rockspecVersion = "scm-1";
            src = inputs.rocks-config-nvim;
            version = finalAttrs.rockspecVersion;
          }
        );

        ${inputNameOrNull "rocks-dev-nvim"} = prevLuaPackages.rocks-dev-nvim.overrideAttrs (
          finalAttrs: prevAttrs: {
            knownRockspec = null;
            rockspecFilename = null;
            rockspecVersion = "scm-1";
            src = inputs.rocks-dev-nvim;
            version = finalAttrs.rockspecVersion;
          }
        );

        ${inputNameOrNull "rocks-git-nvim"} = prevLuaPackages.rocks-git-nvim.overrideAttrs (
          finalAttrs: prevAttrs: {
            knownRockspec = null;
            rockspecFilename = null;
            rockspecVersion = "scm-1";
            src = inputs.rocks-git-nvim;
            version = finalAttrs.rockspecVersion;
          }
        );
      })
    ];
}
