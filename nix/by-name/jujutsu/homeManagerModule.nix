{ ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins)
    isNull
    isPath
    null
    toString
    ;
  inherit (lib.attrsets)
    attrNames
    ;
  inherit (lib.lists)
    concatLists
    concatMap
    optional
    toList
    ;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (lib.options)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    ;
  inherit (lib.strings) isString;
  inherit (lib.trivial) isBool const;
  inherit (lib.types) types;
  cfg = config.programs.jujutsu;
  coercedToList =
    let
      inherit (lib.types) defaultFunctor mkOptionType optionDescriptionPhrase;
    in
    finalType:
    let
      finalTypeDescriptionIsComposite = finalType.descriptionClass or null == "composite";
    in
    mkOptionType rec {
      name = "coercedToList";
      description =
        if finalTypeDescriptionIsComposite then
          "value of or ${finalType.description}"
        else
          "${
            optionDescriptionPhrase (descriptionClass: descriptionClass == "noun") finalType
          }, converting any non-list into a singleton list";
      descriptionClass =
        if finalTypeDescriptionIsComposite then "conjunction" else "nonRestrictiveClause";
      check = x: finalType.check (toList x);
      merge = loc: defs: finalType.merge loc (map (def: def // { value = toList def.value; }) defs);
      emptyValue = toList finalType.emptyValue;
      getSubOptions = finalType.getSubOptions;
      getSubModules = finalType.getSubModules;
      substSubModules = m: coercedToList (finalType.substSubModules m);
      functor = (defaultFunctor name) // {
        binOp = payload: payload': payload.finalType.typeMerge payload'.finalType.functor;
        payload = finalType;
        type = types.${name} or coercedToList;
      };
      nestedTypes.finalType = finalType;
    };
  concatMapAttrsToList = f: attrs: concatMap (name: f name attrs.${name}) (attrNames attrs);
  emptyList = types.enum [ [ ] ] // {
    description = "empty list";
    descriptionClass = "noun";
    emptyValue.value = [ ];
  };
  emptyListOr = types.either emptyList;
  stringToKeyedOption =
    name:
    let
      name' =
        assert isString name || name ? __toString;
        toString name;
    in
    value: if isNull value then "--${name'}" else "--${name'}=${value}";
  mapStringsToKeyedOptionsList =
    f: name:
    let
      f' = f name;
      stringToKeyedOption' = stringToKeyedOption name;
    in
    values: map (value: stringToKeyedOption' (f' value)) (toList values);
  toString' = e: if isPath e then "${e}" else toString e;
in
{
  options.programs.jujutsu = {
    difftastic.enable = mkEnableOption "the Difftastic syntax highlighter.";
    difftastic.package = mkPackageOption pkgs "Difftastic" { default = [ "difftastic" ]; };
    difftastic.tool = mkOption {
      default = "difft";
      description = "The tool name to use for {option}`programs.jujutsu.settings.ui.diff.tool`.";
      type = types.nonEmptyStr;
    };
    difftastic.settings = mkOption {
      description = "The initial command line arguments to pass to Difftastic.";
      type = types.submodule {
        freeformType = types.attrsOf (
          types.either (coercedToList (types.listOf (types.either types.null types.str))) (
            types.coercedTo types.bool (value: if value then "on" else "off") types.str
          )
        );
        options.background = mkOption {
          default = [ ];
          description = ''
            Whether Difftastic should use the lighter or darker colors
            for syntax highlighting.
          '';
          example = "dark";
          type = emptyListOr (
            types.enum [
              "light"
              "dark"
            ]
          );
        };
        options.color = mkOption {
          default = "always";
          description = "When to use color output.";
          example = [ ];
          type = emptyListOr (
            types.enum [
              "always"
              "auto"
              "never"
            ]
          );
        };
        options.display = mkOption {
          default = "side-by-side";
          description = "The display mode to show results with.";
          example = "inline";
          type = emptyListOr (
            types.enum [
              "side-by-side"
              "side-by-side-show-both"
              "inline"
            ]
          );
        };
      };
    };
    difftastic.args = mkOption {
      internal = true;
      type = types.listOf (types.str);
      default =
        concatMapAttrsToList (
          name: value:
          let
            value' = if isBool value then if value then "on" else "off" else value;
          in
          mapStringsToKeyedOptionsList (name: toString') name value'
        ) cfg.difftastic.settings
        ++ [
          "$left"
          "$right"
        ];
      defaultText = literalExpression ''
        let
          inherit (lib.trivial) isBool;
          inherit (lib.strings) isString mapToKeyedOptionsList;
        in
        lib.attrsets.concatMapAttrsToList (
          name: value:
          let
            value' = if isBool value then if value then "on" else "off" else value;
          in
          mapToKeyedOptionsList toString' name value'
        ) config.programs.jujutsu.difftastic.settings
        ++ [
          "$left"
          "$right"
        ]'';
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.difftastic.enable {
      programs.jujutsu.settings = {
        ui.diff.tool = mkDefault cfg.difftastic.tool;
        merge-tools.${cfg.difftastic.tool} = {
          program = mkDefault (getExe cfg.difftastic.package);
          diff-args = cfg.difftastic.args;
        };
      };
    })
  ]);
}
