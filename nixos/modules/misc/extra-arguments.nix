{ config, lib, pkgs, ... }:

let
  inherit (lib)
    extends
    fix'
    foldl'
    functionArgs
    isFunction
    mkOption
    toFunction
    types
    ;
  applyUnfixedUtils = unfixedUtils: finalUtils:
    unfixedUtils
      (if functionArgs unfixedUtils ? utils then
        { inherit config lib pkgs; utils = finalUtils; }
      else
        { inherit config lib pkgs; });
  toUnfixedFunction = v:
    if isFunction v then v else v.__unfix__ or (final: v);
in
{
  options = {
    # # `_module.args` needs to be a freeform type.
    # _module.args.utils = mkOption {
    #   internal = true;
    #   type = types.raw // {
    #     merge = loc: defs: fix' (final:
    #       foldl'
    #         (prev: def: prev // applyUnfixedUtils (toUnfixedFunction def) final)
    #         { }
    #         defs
    #     );
    #   };
    # };
  };
  config = {
    # _modules.args.utils = import ../../lib/utils.nix;
  };
}
