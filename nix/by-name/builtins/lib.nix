let
  bareBuiltins = {
    inherit builtins;
  };
in
prevLib: finalLib:
let
  inherit (builtins) elemAt removeAttrs;
  inherit (finalLib.functions) functionArgs;

  builtinFunctionArgs = builtins.functionArgs;

  builtins = (builtinsProto bareBuiltins.builtins builtins).builtins;
  builtinsProto =
    prevLib.builtinsProto or (prevBuiltins: finalBuiltins: { builtins = prevBuiltins; });

  lib.attrs.attrAt = builtins.attrAt;
  lib.attrs.attrNames = builtins.attrNames;
  lib.attrs.attrValues = builtins.attrValues;
  lib.attrs.attrsToList = builtins.attrsToList;
  lib.attrs.catAttrs = builtins.catAttrs;
  lib.attrs.concatMapAttrsToList = builtins.concatMapAttrsToList;
  lib.attrs.filterAttrs = builtins.filterAttrs;
  lib.attrs.getAttr = builtins.getAttr;
  lib.attrs.getOptionalAttr = builtins.getOptionalAttr;
  lib.attrs.hasAttr = builtins.hasAttr;
  lib.attrs.isAttrs = builtins.isAttrs;
  lib.attrs.intersectAttrs = builtins.intersectAttrs;
  lib.attrs.listToAttrs = builtins.listToAttrs;
  lib.attrs.mapAttr = builtins.mapAttr;
  lib.attrs.mapAttrs = builtins.mapAttrs;
  lib.attrs.mapAttrsToList = builtins.mapAttrsToList;
  lib.attrs.mapOptionalAttr = builtins.mapOptionalAttr;
  lib.attrs.partitionAttr = builtins.partitionAttr;
  lib.attrs.partitionAttrs = builtins.partitionAttrs;
  lib.attrs.partitionOptionalAttr = builtins.partitionOptionalAttr;
  lib.attrs.relativeComplementAttrs = builtins.relativeComplementAttrs;
  lib.attrs.removeAttr = builtins.removeAttr;
  lib.attrs.removeAttrs = names: attrs: removeAttrs attrs names;
  lib.attrs.subAttrs = builtins.subAttrs;
  lib.attrs.unionAttrs = builtins.unionAttrs;
  lib.attrs.unsafeGetAttrPos = builtins.unsafeGetAttrPos;
  lib.attrs.zipAttrsWith = builtins.zipAttrsWith;
  lib.attrs.zipMapAttrsWith = builtins.zipMapAttrsWith;

  lib.bools.false = builtins.false;
  lib.bools.isBool = builtins.isBool;
  lib.bools.true = builtins.true;

  lib.debug.trace = builtins.trace;
  lib.debug.traceVerbose = builtins.traceVerbose;

  lib.derivations.addDrvOutputDependencies = builtins.addDrvOutputDependencies;
  lib.derivations.appendContext = builtins.appendContext;
  lib.derivations.derivation = builtins.derivation;
  lib.derivations.derivationStrict = builtins.derivationStrict;
  lib.derivations.getContext = builtins.getContext;
  lib.derivations.hasContext = builtins.hasContext;
  lib.derivations.parseDrvName = builtins.parseDrvName;
  lib.derivations.placeholder = builtins.placeholder;
  lib.derivations.storePath = builtins.storePath;
  lib.derivations.unsafeDiscardOutputDependency = builtins.unsafeDiscardOutputDependency;
  lib.derivations.unsafeDiscardStringContext = builtins.unsafeDiscardStringContext;

  lib.environment.currentSystem = builtins.currentSystem;
  lib.environment.currentTime = builtins.currentTime;
  lib.environment.getEnv = builtins.getEnv;
  lib.environment.langVersion = builtins.getEnv;
  lib.environment.nixPath = builtins.nixPath;
  lib.environment.nixVersion = builtins.nixVersion;
  lib.environment.storeDir = builtins.storeDir;

  lib.evaluation.abort = builtins.abort;
  lib.evaluation.addErrorContext = builtins.addErrorContext;
  lib.evaluation.break = builtins.break;
  lib.evaluation.deepSeq = builtins.deepSeq;
  lib.evaluation.seq = builtins.seq;
  lib.evaluation.throw = builtins.throw;
  lib.evaluation.tryEval = builtins.tryEval;

  lib.filesystem.findFile = builtins.findFile;
  lib.filesystem.hashFile = builtins.hashFile;
  lib.filesystem.import = builtins.import;
  lib.filesystem.pathExists = builtins.pathExists;
  lib.filesystem.readDir = builtins.readDir;
  lib.filesystem.readDirEntries = builtins.readDirEntries;
  lib.filesystem.readDirEntry = builtins.readDirEntry;
  lib.filesystem.readFile = builtins.readFile;
  lib.filesystem.readFileType = builtins.readFileType;
  lib.filesystem.scopedImport = builtins.scopedImport;

  lib.flakes.getFlake = builtins.getFlake;
  lib.flakes.parseFlakeRef = builtins.parseDrvName;
  lib.flakes.flakeRefToString = builtins.flakeRefToString;

  lib.functions.apply = builtins.apply;
  lib.functions.const = builtins.const;
  lib.functions.fix = builtins.fix;
  lib.functions.flip = builtins.flip;
  lib.functions.functionArgs =
    f:
    if f ? __functor then f.__functionArgs or (functionArgs (f.__functor f)) else builtinFunctionArgs f;
  lib.functions.identity = builtins.identity;
  lib.functions.isFunction = builtins.isFunction;
  lib.functions.pass = builtins.pass;
  lib.functions.pipe = builtins.pipe;

  lib.lists.all = builtins.all;
  lib.lists.any = builtins.any;
  lib.lists.concatLists = builtins.concatLists;
  lib.lists.concatMap = builtins.concatMap;
  lib.lists.elem = builtins.elem;

  /**
    Return the element at `index` from `list`.
    Indices start at 0.

    A fatal error occurs if the index is out of bounds.

    # Inputs

    `index`
    : Integer index into `list`.

    `list`
    : List to index.

    # Type

    ```
    lib.lists.elemAt :: Int -> [a] -> a
    ```

    # Examples
    :::{.example}
    ## `lib.lists.elemAt` usage example

    ```nix
    lib.lists.elemAt 2 "abcde"
    => "c"
    ```

    :::
  */
  lib.lists.elemAt = index: list: elemAt list index;

  lib.lists.genList = builtins.genList;
  lib.lists.genericClosure = builtins.genericClosure;
  lib.lists.getElem = builtins.getElem;
  lib.lists.groupBy = builtins.groupBy;
  lib.lists.head = builtins.head;
  lib.lists.sort = builtins.sort;
  lib.lists.tail = builtins.tail;
  lib.lists.filter = builtins.filter;
  lib.lists.foldl = builtins.foldl;
  lib.lists.foldl' = builtins.foldl';
  lib.lists.foldl'' = builtins.foldl'';
  lib.lists.foldr = builtins.foldr;
  lib.lists.foldr' = builtins.foldr';
  lib.lists.foldr'' = builtins.foldr'';
  lib.lists.isList = builtins.isList;
  lib.lists.length = builtins.length;
  lib.lists.map = builtins.map;
  lib.lists.partition = builtins.partition;

  lib.nulls.isNull = builtins.isNull;
  lib.nulls.null = builtins.null;

  lib.numbers.add = builtins.add;
  lib.numbers.bitAnd = builtins.bitAnd;
  lib.numbers.bitOr = builtins.bitOr;
  lib.numbers.bitXor = builtins.bitXor;
  lib.numbers.ceiling = builtins.ceil;
  lib.numbers.div = builtins.div;
  lib.numbers.floor = builtins.floor;
  lib.numbers.isFloat = builtins.isFloat;
  lib.numbers.isInt = builtins.isInt;
  lib.numbers.mul = builtins.mul;
  lib.numbers.sub = builtins.sub;

  lib.paths.isPath = builtins.isPath;

  lib.storePaths.fetchGit = builtins.fetchGit;
  lib.storePaths.fetchMercurial = builtins.fetchMercurial;
  lib.storePaths.fetchTarball = builtins.fetchTarball;
  lib.storePaths.fetchTree = builtins.fetchTree;
  lib.storePaths.fetchUrl = builtins.fetchurl;
  lib.storePaths.filterSource = builtins.filterSource;
  lib.storePaths.path = builtins.path;
  lib.storePaths.toFile = builtins.toFile;

  lib.strings.baseNameOf = builtins.baseNameOf;
  lib.strings.concatStringsSep = builtins.concatStringsSep;
  lib.strings.dirOf = builtins.dirOf;
  lib.strings.escape = builtins.escape;
  lib.strings.escapeNixIdentifier = builtins.escapeNixIdentifier;
  lib.strings.escapeNixString = builtins.escapeNixString;
  lib.strings.hasPrefix = builtins.hasPrefix;
  lib.strings.hasSuffix = builtins.hasSuffix;
  lib.strings.hashString = builtins.hashString;
  lib.strings.isString = builtins.isString;
  lib.strings.match = builtins.match;
  lib.strings.removePrefix = builtins.removePrefix;
  lib.strings.removeSuffix = builtins.removeSuffix;
  lib.strings.replaceStrings = builtins.replaceStrings;
  lib.strings.split = builtins.split;
  lib.strings.stringLength = builtins.stringLength;
  lib.strings.substring = builtins.substring;

  lib.values.fromJson = builtins.fromJSON;
  lib.values.fromToml = builtins.fromTOML;
  lib.values.lessThan = builtins.lessThan;
  lib.values.toJson = builtins.toJSON;
  lib.values.toString = builtins.toString;
  lib.values.toXml = builtins.toXML;
  lib.values.typeOf = builtins.typeOf;

  lib.versions.compareVersions = builtins.compareVersions;
  lib.versions.splitVersion = builtins.splitVersion;
in
(builtins.removeAttr "builtinsProto" prevLib // { inherit builtins; })
// builtins.mapAttrs (name: value: prevLib.${name} or { } // value) lib
