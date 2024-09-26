prevLib: finalLib:
let
  inherit (finalLib.attrs) mapAttrs;
  inherit (finalLib.filesystem) import pathExists;

  /**
    Returns a module that,
    with a default location for reporting errors & a default module identity,
    imports a module.

    # Inputs

    `file`
    : Default location for reporting errors, or `null`.

    `key`
    : Default key for module identity, or `null`.

    `content`
    : Module to be imported.
  */
  lib.modules.mkImport = file: key: content:
    { _type = "import";
      ${if file != null then "_file" else null} = file;
      ${if key != null then "key" else null} = key;
      inherit content;
    };

  /**
    Returns a module that, with a default location for reporting errors,
    imports a list of modules.

    # Inputs

    `file`
    : Default location for reporting errors, or `null`.

    `imports`
    : Modules to import.
  */
  lib.modules.importModules = file: imports: {
    ${if file != null then "_file" else null} = file;
    inherit imports;
  };

  lib.filesystem.importPath =
      path:
      let
        defaultPath = path + "/default.nix";
      in
      if pathExists defaultPath then
        defaultPath
      else if pathExists path then
        path
      else
        null;
in
prevLib // prevLib.attrs.mapAttrs (name: value: prevLib.${name} or { } // value) lib
