{ config, lib, pkgs, ... }:

{
  imports = [
    ../secrets/tokens.nix
  ];

  config = {
    systemd.user.sessionVariables = {
      EDITOR = "ed";
      GITHUB_TOKEN = config.secrets.tokens.github;
      NIX_PATH = "$HOME/nix/channels\${NIX_PATH:+:$NIX_PATH}";
      PAGER = "less -RF";
      # TODO: move next to neovim conf?
      VISUAL = "nvim";
      # # We have to replicate this from `environment.variables` in
      # # `<nixpkgs/nixos/modules/programs/environment.nix>`.
      # # https://github.com/NixOS/nixpkgs/pull/67389
      # #   NixOS/nixpkgs@48426833c861ad8c4e601324462b352c58b8b230
      # XDG_CONFIG_DIRS = "/etc/xdg\${XDG_CONFIG_DIRS:+:$XDG_CONFIG_DIRS}";
    };
  };
}

# vim:ft=nix:et:sw=2:tw=78
