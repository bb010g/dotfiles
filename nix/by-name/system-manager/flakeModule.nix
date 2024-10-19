{ flakeModules, ... }:
{
  imports = [
    flakeModules.systemConfigurations
    flakeModules.systemManagerModules
  ];
}
