{ ... }:
{ config, lib, pkgs, ... }:
let
in
{
  config.programs.vscode.enable = true;
  config.programs.vscode.extensions = [
    pkgs.vscode-extensions.bazelbuild.vscode-bazel
    pkgs.vscode-extensions.cweijan.vscode-database-client2
    pkgs.vscode-extensions.daohong-emilio.yash
    pkgs.vscode-extensions.davidlday.languagetool-linter
    pkgs.vscode-extensions.dbaeumer.vscode-eslint
    pkgs.vscode-extensions.denoland.vscode-deno
    pkgs.vscode-extensions.donjayamanne.githistory
    pkgs.vscode-extensions.editorconfig.editorconfig
    pkgs.vscode-extensions.esbenp.prettier-vscode
    pkgs.vscode-extensions.firefox-devtools.vscode-firefox-debug
    pkgs.vscode-extensions.firsttris.vscode-jest-runner
    pkgs.vscode-extensions.fundament.alicorn-test
    pkgs.vscode-extensions.github.github-vscode-theme
    pkgs.vscode-extensions.github.vscode-github-actions
    pkgs.vscode-extensions.golang.go
    pkgs.vscode-extensions.gruntfuggly.todo-tree
    pkgs.vscode-extensions.ionide.ionide-fsharp
    pkgs.vscode-extensions.jnoortheen.nix-ide
    pkgs.vscode-extensions.julialang.language-julia
    pkgs.vscode-extensions.kahole.magit
    pkgs.vscode-extensions.mkhl.direnv
    pkgs.vscode-extensions.ms-kubernetes-tools.vscode-kubernetes-tools
    pkgs.vscode-extensions.ms-python.black-formatter
    pkgs.vscode-extensions.ms-python.debugpy
    pkgs.vscode-extensions.ms-python.python
    pkgs.vscode-extensions.ms-python.vscode-pylance
    pkgs.vscode-extensions.ms-toolsai.jupyter
    pkgs.vscode-extensions.ms-toolsai.jupyter-keymap
    pkgs.vscode-extensions.ms-toolsai.jupyter-renderers
    pkgs.vscode-extensions.ms-toolsai.vscode-jupyter-cell-tags
    pkgs.vscode-extensions.ms-toolsai.vscode-jupyter-slideshow
    pkgs.vscode-extensions.ms-vscode-remote.remote-containers
    pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
    pkgs.vscode-extensions.ms-vscode.anycode
    pkgs.vscode-extensions.ms-vscode.cmake-tools
    pkgs.vscode-extensions.ms-vscode.cpptools
    pkgs.vscode-extensions.ms-vscode.cpptools-extension-pack
    pkgs.vscode-extensions.ms-vscode.hexeditor
    pkgs.vscode-extensions.ms-vscode.live-server
    pkgs.vscode-extensions.ms-vscode.makefile-tools
    pkgs.vscode-extensions.ms-vscode.powershell
    pkgs.vscode-extensions.ms-vsliveshare.vsliveshare
    pkgs.vscode-extensions.redhat.java
    pkgs.vscode-extensions.redhat.vscode-xml
    pkgs.vscode-extensions.redhat.vscode-yaml
    pkgs.vscode-extensions.rust-lang.rust-analyzer
    pkgs.vscode-extensions.stylelint.vscode-stylelint
    pkgs.vscode-extensions.tamasfe.even-better-toml
    # pkgs.vscode-extensions.tlaplus.vscode-ide
    pkgs.vscode-extensions.twxs.cmake
    pkgs.vscode-extensions.vadimcn.vscode-lldb
    pkgs.vscode-extensions.valentjn.vscode-ltex
    pkgs.vscode-extensions.vscjava.vscode-gradle
    pkgs.vscode-extensions.vscjava.vscode-java-debug
    pkgs.vscode-extensions.vscjava.vscode-java-dependency
    pkgs.vscode-extensions.vscjava.vscode-java-test
    pkgs.vscode-extensions.vscjava.vscode-maven
    pkgs.vscode-extensions.vspacecode.vspacecode
    pkgs.vscode-extensions.vspacecode.whichkey
    pkgs.vscode-extensions.ziglang.vscode-zig
  ];
  config.programs.vscode.mutableExtensionsDir = true;
  config.programs.vscode.userSettings = {
    "FSharp.suggestGitIgnore" = false;
    "Lua.codeLens.enable" = true;
    "accessibility.sounds.terminalBell"."sound" = "on";
    "code-eol.highlightNonDefault" = true;
    "database-client.autoSync" = true;
    "debug.showSubSessionsInToolBar" = true;
    "debug.showVariableTypes" = true;
    "editor.accessibilitySupport" = true;
    "editor.experimentalWhitespaceRendering" = "font";
    "editor.guides.bracketPairs" = "active";
    "editor.guides.bracketPairsHorizontal" = true;
    "editor.linkedEditing" = true;
    "evenBetterToml.semanticTokens" = true;
    "files.autoSave" = "off";
    "files.eol" = "\n";
    "files.insertFinalNewline" = true;
    "githubPullRequests.pullBranch" = "never";
    "githubPullRequests.upstreamRemote" = "never";
    "gitlens.defaultDateShortFormat" = "YYYY-MM-DD";
    "gitlens.defaultDateStyle" = "absolute";
    "gitlens.defaultTimeFormat" = "H:mm";
    "julia.enableTelemetry" = true;
    "julia.symbolCacheDownload" = true;
    "keyboard.dispatch" = "keyCode";
    "lldb.launch.expressions" = "native";
    "redhat.telemetry.enabled" = true;
    "rust-analyzer.cargo.buildScripts.enable" = true;
    "rust-analyzer.cargo.check.command" = "clippy";
    "rust-analyzer.diagnostics.useRustcErrorCode" = true;
    "rust-analyzer.imports.group.enable" = false;
    "rust-analyzer.inlayHints.bindingModeHints.enable" = true;
    "rust-analyzer.inlayHints.closureCaptureHints.enable" = true;
    "rust-analyzer.inlayHints.closureReturnTypeHints.enable" = true;
    "rust-analyzer.inlayHints.discriminantHints.enable" = true;
    "rust-analyzer.inlayHints.expressionAdjustmentHints.enable" = "always";
    "rust-analyzer.inlayHints.expressionAdjustmentHints.mode" = "postfix";
    "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "skip_trivial";
    "rust-analyzer.procMacro.enable" = true;
    "rust-analyzer.semanticHighlighting.operator.specialization.enable" = true;
    "terminal.integrated.confirmOnExit" = "hasChildProcesses";
    "terminal.integrated.enableImages" = true;
    "terminal.integrated.enableVisualBell" = true;
    "terminal.integrated.hideOnStartup" = "whenEmpty";
    "terminal.integrated.persistentSessionReviveProcess" = "onExitAndWindowClose";
    "terminal.integrated.persistentSessionScrollback" = 1000;
    "terminal.integrated.rightClickBehavior" = "nothing";
    "terminal.integrated.scrollback" = 10000;
    "terminal.integrated.shellIntegration.history" = 1000;
    "terminal.integrated.tabs.hideCondition" = "never";
    "terminal.integrated.tabs.showActions" = "always";
    "terminal.integrated.tabs.showActiveTerminal" = "always";
    "todo-tree.general.schemes" = [ "file" "ssh" "untitled" "vscode-notebook-cell" "vscode" ];
    "visualjj.showSourceControlColocated" = true;
    "window.autoDetectColorScheme" = lib.mkDefault false;
    "window.confirmBeforeClose" = "keyboardOnly";
    "window.openFoldersInNewWindow" = "on";
    "window.titleBarStyle" = "custom";
    "workbench.preferredDarkColorTheme" = lib.mkDefault "GitHub Dark Default";
    "workbench.preferredLightColorTheme" = "GitHub Light Default";
    # "workbench.colorTheme" = "modus-vivendi-tinted"; # TODO(<me@bb010g.com>)
    # "workbench.colorTheme" = config.programs.vscode.userSettings."workbench.preferredDarkColorTheme";
    "workbench.colorTheme" = "GitHub Dark Default";
    "xml.codeLens.enabled" = true;
    "xml.validation.resolveExternalEntities" = true;
  };
}
