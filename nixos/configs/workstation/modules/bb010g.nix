{ config, flakeConfig, lib, ... }:

{
  config = {
    home-manager.users.bb010g = flakeConfig.flake.homeManagerModules.configuration-bb010g;
    # Define a user account.
    users.users.bb010g = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      hashedPassword = "$y$j9T$cUQllF01PobECG4vm4/Pw/$qDfVrxiI/4i53T54oDhf9rr3ZZpRhAwPFdcZfO.UNmD";
    };
    users.users.root.hashedPassword = "$y$j9T$cUQllF01PobECG4vm4/Pw/$qDfVrxiI/4i53T54oDhf9rr3ZZpRhAwPFdcZfO.UNmD";
  };
}
