{ flakeModules, ... }:
{
  imports = [
    flakeModules.homeConfigurations
    flakeModules.homeManagerModules
  ];
}
