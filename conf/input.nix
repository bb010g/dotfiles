# let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:
# let nur = srcs.nur { inherit pkgs; }; in

{
  # imports = [
  #   # nur.modules.bb010g.home-manager.xcompose
  # ];

  config = {
    home.keyboard = {
      layout = "us,gr";
      options = [
        "compose:ralt"
        "ctrl:swap_lalt_lctl"
        "caps:swapescape"
        "grp:rctrl_rshift_toggle"
      ];
    };

    xcompose = let
      ruleOn = rule: events: rule // { inherit events; };
      minus = {
        result = { string = "−"; keysym = "U2212"; };
        comment = "MINUS SIGN";
      };
    in {
      enable = true;
      rules = [
        { include = "%L"; }
        { commentLines = ""; } # blank line
        (ruleOn minus [ "<Multi_key>" "<underscore>" "<minus>" ])
        (ruleOn minus [ "<Multi_key>" "<minus>" "<underscore>" ])
      ];
    };
  };
}
