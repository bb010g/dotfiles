{ config, lib, ... }:

{
  config = {
    home-manager.users.bb010g = (
      { config, lib, pkgs, ... }:

      {
        home.packages = [
          pkgs.bitwarden-cli # Bitwarden
          pkgs.bitwarden-desktop # Bitwarden
          pkgs.firefox # Web
          pkgs.neochat # Matrix
          pkgs.sublime-merge # Git
          pkgs.telegram-desktop # Telegram
        ];

        home.stateVersion = "23.11";

        programs.bat.enable = true;
        programs.eza.enable = true;
      }
    );
    # Define a user account.
    users.users.root.hashedPassword = "$y$j9T$cUQllF01PobECG4vm4/Pw/$qDfVrxiI/4i53T54oDhf9rr3ZZpRhAwPFdcZfO.UNmD";
    users.users.bb010g = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      hashedPassword = "$y$j9T$cUQllF01PobECG4vm4/Pw/$qDfVrxiI/4i53T54oDhf9rr3ZZpRhAwPFdcZfO.UNmD";
    };
  };
}
