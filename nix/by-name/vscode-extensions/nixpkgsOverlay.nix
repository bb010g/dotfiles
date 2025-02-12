{ inputs, ... }:
let
  input = inputs.alicorn-vscode-extension;
in
pkgsFinal: pkgsPrev: {
  vscode-extensions = pkgsPrev.vscode-extensions.extend (extensionsFinal: extensionsPrev: {
    fundament.alicorn-test = pkgsFinal.callPackage (input + "/alicorn-vscode-extension.nix") { };
  });
}
