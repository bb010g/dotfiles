{ inputs, nixosModules, ... }:
{
  imports = [
    inputs.lix-module.nixosModules.default
  ];

  config = {
    nix.settings.extra-substituters = [ "https://cache.lix.systems" ];
    nix.settings.extra-trusted-public-keys = [ "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" ];
  };
}
