let
  inherit (_lib.fixedPoints)
    makeExtensible
    makeInheritable
    ;
  inherit (_lib.functions)
    toFunction
    ;
  inherit (_lib.lists)
    ;
  inherit (_lib.paths)
    concatMapDirEntriesToList
    importOr
    mapExistingPathOr
    mapImportOr
    readDirEntries
    ;
  inherit (_lib.pop)
    composeProto
    extendObj
    extensionToProto
    getProto
    hookObj
    identityProto
    instantiateObj
    mapMeta
    setDefaultName
    ;
  inherit (_lib.strings)
    hasPrefix
    hasSuffix
    ;
  inherit (builtins)
    attrNames
    concatMap
    filter
    listToAttrs
    map
    pathExists
    readDir
    stringLength
    substring
    ;
  inherit (genericLib)
    concatMapEntriesOfDirToList
    ;
  _lib = import ./_lib.nix;
  genericLib = {
    concatMapEntriesOfDirToList = pathFn: path:
      concatMapDirEntriesToList pathFn (readDirEntries path);
  };
in genericLib // makeInheritable (makeExtensible (finalLib: let
  inherit (finalLib)
    baseNameIsIgnored
    baseNameIsNix
    concatMapNixSourcePathsOfDirToList
    isNixSourceFilter
    moduleConfigurationOfDir
    moduleConfigurationsOfDir
    moduleConfigurationsAttrName
    moduleConfigurationsBaseName
    moduleConfigurationsForDir
    moduleDataBaseName
    moduleDataForPath
    moduleListAttrName
    moduleListBaseName
    moduleListOfDir
    modulesBaseName
    modulesForDir
    modulesPathAttrName
  ;
  makeStaticObj = obj:
    extendObj null (mapMeta (meta: { base = { }; proto = final: prev: prev // obj; }) obj);
in {
  baseNameIsIgnored = hasPrefix "_";
  baseNameIsNix = hasSuffix ".nix";
  concatMapNixSourcePathsOfDirToList = pathFn: path: concatMapEntriesOfDirToList (baseName: path: type:
    if baseNameIsIgnored baseName then [ ]
    else if type == "directory" || baseNameIsNix baseName then pathFn baseName path type
    else [ ]
  ) path;
  isNixSourceFilter = baseName: path: type:
    !(baseNameIsIgnored baseName) && (type == "directory" || baseNameIsNix baseName);
  moduleConfigurationOfDir = moduleConfigurationsForDir;
  moduleConfigurationsAttrName = "configurations";
  moduleConfigurationsBaseName = "configurations";
  moduleConfigurationsForDir = path: toFunction (importOr (
    moduleConfigurations: moduleConfigurations
  ) (path + "/${moduleConfigurationsBaseName}.nix")) ((
    modulesForDir path
  ) // mapExistingPathOr (configurationsDirPath: {
    ${moduleConfigurationsAttrName} = moduleConfigurationsOfDir configurationsDirPath;
  }) { } (path + "/${moduleConfigurationsBaseName}"));
  moduleConfigurationsOfDir = path: listToAttrs (concatMapEntriesOfDirToList (childBaseName: childPath: childFileType:
    if baseNameIsIgnored childBaseName then [ ] else if childFileType == "directory" then [
      { name = childBaseName; value = moduleConfigurationOfDir childPath; }
    ] else [ ]
  ) path);
  moduleDataBaseName = "default";
  moduleDataForPath = path: toFunction (importOr (
    moduleData: moduleData
  ) (path + "/${moduleDataBaseName}.nix")) (moduleConfigurationsForDir path);
  moduleListAttrName = "moduleList";
  moduleListBaseName = "module-list";
  moduleListOfDir = path: let
    defaultModules = {
      ${moduleListAttrName} = moduleList;
      ${modulesPathAttrName} = path;
    };
    moduleList = modulePathsOfDir path;
    modulePathsOfDir = concatMapNixSourcePathsOfDirToList (childBaseName: childPath: childType:
      if childType == "directory" then (moduleListOfDir childPath).${moduleListAttrName}
      else [ childPath ]
    );
  in toFunction (mapImportOr (moduleList: defaultModules // {
    ${moduleListAttrName} = moduleList;
  }) (
    modules: modules
  ) (path + "/${moduleListBaseName}.nix")) defaultModules;
  modulesBaseName = "modules";
  modulesPathAttrName = "modulesPath";
  modulesForDir = path: let
    modulesPath = path + "/${modulesBaseName}";
  in toFunction (importOr (
    modules: modules
  ) (path + "/${modulesBaseName}.nix")) (mapExistingPathOr moduleListOfDir { } modulesPath);
  withShortNames = finalLib.__extend__ (final: prev: {
    moduleConfigurationsAttrName = "configs";
    moduleConfigurationsBaseName = "configs";
  });
  withNixosAttrNames = finalLib.__extend__ (final: prev: {
    moduleConfigurationsAttrName = "nixosConfigurations";
    moduleListAttrName = "nixosModuleList";
    modulesPathAttrName = "nixosModulesPath";
  });
  # withNixosBaseNames = (makeStaticObj finalLib).__extend__ (final: prev: {
  #   moduleConfigurationsBaseName = "nixos-configurations";
  #   moduleDataBaseName = "nixos";
  #   moduleListBaseName = "nixos-module-list";
  #   modulesBaseName = "nixos-modules";
  # });
}))
