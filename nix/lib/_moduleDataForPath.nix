let
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
    concatMapAttrs'
    concatMapAttrsToList
    concatMapPathsOfDir
    concatMapPathsOfDir'
    hasPrefix
    hasSuffix
    importOr
    isFunction
    makeExtensible
    makeExtensibleHook
    makeInheritable
    makeInheritableHook
    mapExistingPathOr
    mapFilteredPathsOfDir
    mapFilteredPathsOfDir'
    mapImport
    mapImportOr
    toFunction
  ;
  inherit (popLib)
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
  genericLib = {
    concatMapAttrs' = f: attrs: listToAttrs (concatMapAttrsToList f attrs);
    concatMapAttrsToList = f: attrs:
      concatMap (attrName: f attrName attrs.${attrName}) (attrNames attrs);
    concatMapPathsOfDir = f: path: let
      childTypes = readDir path;
      childBaseNames = attrNames childTypes;
    in concatMapPathsOfDir' f path childTypes childBaseNames;
    concatMapPathsOfDir' = f: path: childTypes: childBaseNames: concatMap (childBaseName: let
      childPath = path + "/${childBaseName}";
      childType = childTypes.${childBaseName};
    in f childBaseName childPath childType) childBaseNames;
    hasPrefix = prefix: let prefixLength = stringLength prefix; in
      str: let strLength = stringLength str; in
      strLength >= prefixLength && substring 0 prefixLength str == prefix;
    hasSuffix = suffix: let suffixLength = stringLength suffix; in
      str: let strLength = stringLength str; in
      strLength >= suffixLength && substring (strLength - suffixLength) strLength str == suffix;
    importOr = f: path: mapExistingPathOr import f path;
    isFunction = let
      isFunction' = builtins.isFunction;
      isFunction = f: isFunction' f || (f ? __functor && isFunction (f.__functor f));
    in isFunction;
    makeExtensible = mkFinal:
      hookObj makeExtensibleHook (instantiateObj (final: prev: prev // mkFinal final) { });
    makeExtensibleHook = final: prev:
      prev // { __extend__ = extension: extendObj (extensionToProto extension) final; };
    makeInheritable = obj: hookObj makeInheritableHook obj;
    makeInheritableHook = final: prev: prev // { __inherit__ = proto: extendObj proto final; };
    mapExistingPathOr = f: default: path: if pathExists path then f path else default;
    mapImportOr = f: mapExistingPathOr (path: f (import path));
    mapFilteredPathsOfDir = filterF: f: path: let
      childTypes = readDir path;
      childBaseNames = attrNames childTypes;
    in mapFilteredPathsOfDir' filterF f path childTypes childBaseNames;
    mapFilteredPathsOfDir' = filterF: f: path: childTypes: childBaseNames: let
      filteredChildBaseNames = filter (childBaseName: let
        childPath = path + "/${childBaseName}";
        childType = childTypes.${childBaseName};
      in filterF childBaseName childPath childType) childBaseNames;
    in map (childBaseName: let
      childPath = path + "/${childBaseName}";
      childType = childTypes.${childBaseName};
    in f childBaseName childPath childType) filteredChildBaseNames;
    toFunction = v: if isFunction v then v else _: v;
  };
  popLib = import ./_pop.nix;
in genericLib // makeInheritable (makeExtensible (finalLib: let
  inherit (finalLib)
    baseNameIsIgnored
    baseNameIsNix
    concatMapNixSourcePathsOfDir
    isNixSourceFilter
    mapNixSourcePathsOfDir
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
  concatMapNixSourcePathsOfDir = f: path: concatMapPathsOfDir (baseName: path: type:
    if baseNameIsIgnored baseName then [ ]
    else if type == "directory" || baseNameIsNix baseName then f baseName path type
    else [ ]
  ) path;
  isNixSourceFilter = baseName: path: type:
    !(baseNameIsIgnored baseName) && (type == "directory" || baseNameIsNix baseName);
  mapNixSourcePathsOfDir = f: path: mapFilteredPathsOfDir isNixSourceFilter f path;
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
  moduleConfigurationsOfDir = path: listToAttrs (concatMapPathsOfDir (childBaseName: childPath: childFileType:
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
    modulePathsOfDir = concatMapNixSourcePathsOfDir (childBaseName: childPath: childType:
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
  withShortBaseNames = finalLib.__extend__ (final: prev: {
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
