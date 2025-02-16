{ homeManagerModules, ... }:
{ config, lib, ... }:
let
  inherit (builtins) isNull;
  inherit (lib.attrsets) concatMapAttrs mapAttrs setAttrByPath;
  inherit (lib.modules) mkDefault mkIf mkMerge mkOverride setDefaultModuleLocation;
  inherit (lib.strings) removePrefix;
  inherit (lib.trivial) importTOML;
  mapImportModule = importModule: file: setDefaultModuleLocation file (importModule file);
  mapImportModuleTo = f: optionPath: file: mapImportModule (file: { config = setAttrByPath optionPath (f file); }) file;
  addBuiltinAliases =
    let
      removePrefix' = prefix: str:
        let
          unprefixedStr = removePrefix prefix str;
        in
        if unprefixedStr == str then null else unprefixedStr;
    in
    settings: if settings ? revset-aliases then settings // {
      revset-aliases = concatMapAttrs (builtinName: value: {
        ${builtinName} = value;
        ${removePrefix' "builtin_" builtinName} = builtinName;
      }) settings.revset-aliases or { };
    } else settings;
in
{
  imports = [
    homeManagerModules.jujutsu
    (mapImportModuleTo (file: mapAttrs (name: mapAttrs (name: mkOverride 1100)) (addBuiltinAliases (importTOML file))) [ "programs" "jujutsu" "settings" ] ./_jj-config-builtin.toml)
    (mapImportModuleTo (file: mapAttrs (name: mapAttrs (name: mkOverride 1050)) (addBuiltinAliases (importTOML file))) [ "programs" "jujutsu" "settings" ] ./_jj-config-builtin-trunks.toml)
    (mapImportModuleTo (file: importTOML file) [ "programs" "jujutsu" "settings" ] ./_jj-config.toml)
  ];

  config = mkMerge [
    {
      programs.jujutsu.enable = true;
      programs.jujutsu.settings.git.push-bookmark-prefix = "jj/bb010g/";
      programs.jujutsu.settings.merge-tools.${config.programs.jujutsu.difftastic.tool}.diff-invocation-mode = "file-by-file";
      programs.jujutsu.settings.merge-tools.vimdiff.program = "nvim";
      programs.jujutsu.settings.user.email = mkIf (!(isNull config.programs.git.userEmail)) (mkDefault config.programs.git.userEmail);
      programs.jujutsu.settings.user.name = mkIf (!(isNull config.programs.git.userName)) (mkDefault config.programs.git.userName);
      programs.jujutsu.settings.revset-aliases."immutable_midstream_trunks()" = ''coalesce(builtin_immutable_midstream_trunks(), remote_immutable_trunks(exact:"bb010g"))'';
      programs.jujutsu.settings.revset-aliases."mutable_midstream_trunks()" = ''coalesce(builtin_mutable_midstream_trunks(), remote_mutable_trunks(exact:"bb010g"))'';
      programs.jujutsu.watchman.enable = true;
    }
    (mkIf config.programs.git.difftastic.enable {
      programs.jujutsu.difftastic.enable = mkDefault true;
      programs.jujutsu.difftastic.settings.display = mkDefault config.programs.git.difftastic.display;
    })
  ];
}
