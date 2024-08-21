let
  inherit (builtins') mapAttrs throw;
  builtins' = import ../builtins/lib.nix;
  final = builtins'.scopedImport scope ./lib.nix;
  scope = mapAttrs (name: value: throw "Bare builtin: ${name}") builtins // {
    builtins = builtins';
  };
in
scope // final
