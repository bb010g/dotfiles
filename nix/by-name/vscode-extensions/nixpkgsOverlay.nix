{ inputs, ... }:
let
  input = inputs.alicorn-vscode-extension;
in
finalPkgs: prevPkgs:
let
  inherit (finalPkgs) lib;
in
{
  vscode-extensions = lib.recursiveUpdate prevPkgs.vscode-extensions (
    (finalExtensions: prevExtensions: {
      fundament.alicorn-test = finalPkgs.callPackage (input + "/alicorn-vscode-extension.nix") { };
    })
      finalPkgs.vscode-extensions
      prevPkgs.vscode-extensions
  );
}
