{ config, homeManagerModules ? { }, ... }:

{
  config = {
    home-manager.users.bb010g = homeManagerModules.configuration-bb010g or { };
    # Define a user account.
    users.users.bb010g = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      hashedPassword = "$y$j9T$cUQllF01PobECG4vm4/Pw/$qDfVrxiI/4i53T54oDhf9rr3ZZpRhAwPFdcZfO.UNmD";
    };
    users.users.root.hashedPassword = config.users.users.bb010g.hashedPassword;
  };
}
