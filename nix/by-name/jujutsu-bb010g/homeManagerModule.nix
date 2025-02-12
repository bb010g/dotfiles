{ homeManagerModules, ... }:
{ config, lib, pkgs, ... }:
let
  inherit (builtins) isNull;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.attrsets) setAttrByPath;
  inherit (lib.modules) mkDefault mkIf mkMerge mkOverride setDefaultModuleLocation;
  inherit (lib.trivial) importTOML;
  mapImportModule = importModule: file: setDefaultModuleLocation file (importModule file);
  mapImportModuleTo = f: optionPath: file: mapImportModule (file: { config = setAttrByPath optionPath (f file); }) file;
in
{
  imports = [
    homeManagerModules.jujutsu
    (mapImportModuleTo (file: mapAttrs (name: mapAttrs (name: mkOverride 1100)) (importTOML file)) [ "programs" "jujutsu" "settings" ] ./_jj-config-builtin.toml)
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
      programs.jujutsu.watchman.enable = true;
    }
    (mkIf config.programs.git.difftastic.enable {
      programs.jujutsu.difftastic.enable = mkDefault true;
      programs.jujutsu.difftastic.settings.display = mkDefault config.programs.git.difftastic.display;
    })
  ];
}
