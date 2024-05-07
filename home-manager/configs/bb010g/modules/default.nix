moduleArgs@{ lib, pkgs, ... }:

let
  flakeConfig = moduleArgs.flakeConfig or null;
in
{
  config = {
    home.homeDirectory = "/home/bb010g";

    home.packages = [
      pkgs.bitwarden-cli # Bitwarden
      pkgs.bitwarden-desktop # Bitwarden
      pkgs.firefox # Web
      pkgs.neochat # Matrix
      pkgs.obsidian # Obsidian
      pkgs.sublime-merge # Git
      pkgs.telegram-desktop # Telegram
    ];

    home.username = "bb010g";

    programs.atuin.enable = true;
    programs.atuin.settings.update_check = false;
    programs.atuin.settings = {
      dialect = "us";
      dotfiles.enabled = false;
      exit_mode = "return-query";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "session";
      search_mode = "skim";
      search_mode_shell_up_key_binding = "prefix";
      style = "compact";
      sync.records = true;
      workspaces = true;
    };

    programs.bat.enable = true;

    programs.eza.enable = true;

    programs.foot.enable = true;
    programs.foot.settings = {
      key-bindings.font-decrease = "Control+Alt+minus Control+Alt+KP_Subtract";
      key-bindings.font-increase = "Control+Alt+plus Control+Alt+KP_Add";
      key-bindings.font-reset = "Control+Alt+equal Control+Alt+KP_Enter";
      key-bindings.primary-paste = "Control+Shift+Insert";
      key-bindings.scrollback-down-page = "Control+Alt+Page_Down";
      key-bindings.scrollback-up-page = "Control+Alt+Page_Up";
      key-bindings.spawn-terminal = "none";
      main.dpi-aware = "yes";
      main.font = "monospace:size=10";
      scrollback.lines = 10000;
    };

    programs.vscode.enable = true;
    programs.vscode.extensions = [
      pkgs.vscode-extensions.alygin.vscode-tlaplus
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
    programs.vscode.userSettings = {
      "FSharp.suggestGitIgnore" = false;
      "accessibility.sounds.terminalBell"."sound" = "on";
      "code-eol.highlightNonDefault" = true;
      "debug.showSubSessionsInToolBar" = true;
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
      "window.confirmBeforeClose" = "keyboardOnly";
      "window.openFoldersInNewWindow" = "on";
      "workbench.colorTheme" = "GitHub Light Default";
      "xml.codeLens.enabled" = true;
      "xml.validation.resolveExternalEntities" = true;
    };

    programs.zellij.enable = true;
    programs.zellij.enableBashIntegration = true;

    # Discord (via Vesktop)
    services.arrpc.enable =
      if flakeConfig != null then
        flakeConfig.programs.vesktop.enable
      else
        lib.mkDefault false;
  };
}
