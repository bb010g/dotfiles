{ ... }:
finalPkgs: prevPkgs:
let
  inherit (finalPkgs)
    lib
    ;
  inherit (lib)
    optionals
    ;
in
{
  neovim-unwrapped = prevPkgs.neovim-unwrapped.overrideAttrsWithArgs (
    finalArgs@{
      lua,
      stdenv,
      # a development binary to help debug issues
      enableDebug ? false,
      # for neovim developers, beware of the slow binary
      enableDeveloper ? false,
    ... }:
    finalAttrs: prevAttrs:
    assert enableDeveloper -> enableDebug;
    {
      NIX_CFLAGS_COMPILE =
        if enableDebug then
          prevAttrs.NIX_CFLAGS_COMPILE or "" ++ " -Og"
        else
          prevAttrs.NIX_CFLAGS_COMPILE or "";
      cmakeBuildType =
        if enableDebug then
          "Debug"
        else
          prevAttrs.cmakeBuildType or "Release";
      cmakeFlags =
        if enableDeveloper then
          prevAttrs.cmakeFlags or [ ] ++ [
            "-DLUACHECK_PRG=${lua.pkgs.luacheck}/bin/luacheck"
            "-DENABLE_LTO=OFF"
          ] ++ optionals stdenv.isLinux [
            # https://github.com/google/sanitizers/wiki/AddressSanitizerFlags
            # https://clang.llvm.org/docs/AddressSanitizer.html#symbolizing-the-reports
            "-DENABLE_ASAN_UBSAN=ON"
          ]
        else
          prevAttrs.cmakeFlags or [ ];

      dontStrip = enableDebug || prevAttrs.dontStrip or false;
      separateDebugInfo = enableDebug || prevAttrs.separateDebugInfo or false;

      doCheck = (enableDeveloper && stdenv.isLinux) || prevAttrs.doCheck or false;
    }
  );
}
