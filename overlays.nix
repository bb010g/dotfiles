[
  (self: super: {
    # hyperfine 1.4.0
    hyperfine = super.callPackage <nixos-unstable/pkgs/tools/misc/hyperfine> {
      inherit (super.darwin.apple_sdk.frameworks) Security;
    };
  })
]
