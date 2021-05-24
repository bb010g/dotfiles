let srcs = import ../sources.nix; in
{ config, lib, pkgs, ... }:

{
  config = {
    programs.neovim = let
      pkgsNvim = pkgs;
      nvimUnwrapped = pkgsNvim.neovim-unwrapped;
      nvim = pkgsNvim.wrapNeovim nvimUnwrapped {
        vimAlias = true;
      };
    in {
      enable = true;
      package = nvimUnwrapped;
      extraConfig = /*vim*/''
"" general mappings (set before other uses)
" <Leader>
let mapleader = "\<Space>"

"" ale
" completion
let g:ale_completion_enabled = 1

"" context_filetype
" language support
if !exists('g:context_filetype#filetypes')
  let g:context_filetype#filetypes = {}
endif
let g:context_filetype#filetypes.markdown = [{ 'start': '^\s\{,3}\([`~]\)\(\1\{2,}\)\s*\(\w*\)\@>', 'end': '^\s\{,3}\1\2$', 'filetype': '\3', }]
let g:context_filetype#filetypes.markdown = [
\ {
\   'start': '^\s*```\s*\(\h\w*\)',
\   'end': '^\s*```$',
\   'filetype': '\1',
\ },
\]
let g:context_filetype#filetypes.nix = [
\ {
\   'start': '/\*\(\h\w*\)\*/'."'"."'",
\   'end': "'"."'".'\%($\|[^$'."'".']\|.\@!$\)',
\   'filetype': '\1',
\ },
\]
let g:context_filetype#filetypes.sh = [
\ {
\   'start': '<<\s*\(['."'".'"]\)\(\h\w*\)\1\s*#\s*vim:\s*ft=\(\h\w*\)\n',
\   'end': '\n\2',
\   'filetype': '\3',
\ },
\]

"" diff output
" patience algorithm
if has("patch-8.1.0360")
  set diffopt+=internal,algorithm:patience
endif

"" polyglot configuration
" disable language packs
let g:polyglot_disabled = [
"\ LaTeX-Box
\ "latex",
\]

"" swapfiles
" don't bother with unmodified, detached swapfiles
let g:RecoverPlugin_Delete_Unmodified_Swapfile = 1

"" window management
" don't unload buffers when abandoned (hid)
set hidden
" more natural new splits (sb spr)
set splitbelow splitright
" termopen.vim: easy terminal splits
let g:termopen_autoinsert = 0
nmap <silent> <M-Return> :call TermOpen()<CR>

"" window viewport
" cursor line margin (so siso)
set scrolloff=5 sidescrolloff=4

      '';
      extraPython3Packages = pyPs: [
        # for vim-sved
        pyPs.dbus-python
        pyPs.pygobject3
      ];
      plugins = let
        inherit (pkgsNvim.vimUtils.override { vim = nvim; }) buildVimPluginFrom2Nix;
        basicVimPlugin = pname: version: src:
          buildVimPluginFrom2Nix {
            pname = lib.removePrefix "vim-" pname;
            inherit version src;
          };
        sourcesVimPlugin = pname: let
            src = srcs.sources.${pname};
            date = lib.elemAt (builtins.split "T" src.date) 0;
          in basicVimPlugin pname date src;

        vim-sved = (sourcesVimPlugin "vim-sved").overrideAttrs(o: {
          patches = srcs.sources.vim-sved.patches or [] ++ [
            (builtins.toFile "nvim-host-python.patch" /*diff*/''
--- a/ftplugin/tex_evinceSync.vim
+++ b/ftplugin/tex_evinceSync.vim
@@ -39,2 +39,2 @@
 if has("nvim")
-	let g:evinceSyncDaemonJob = jobstart([s:pycmd, "1"],
+	let g:evinceSyncDaemonJob = jobstart([g:python_host_prog, s:pycmd, "1"],
            '')
          ];
        });
      # TODO: make this module-based instead of a realized function mapping
      #   over a big list
      in map sourcesVimPlugin [
        "vim-ale"
        "vim-caw"
        "vim-characterize"
        "vim-context-filetype"
        "vim-diffchar"
        "vim-dirdiff"
        "vim-direnv"
        "vim-dirvish"
        "vim-editorconfig"
        "vim-eunuch"
        "vim-exchange"
        "vim-gina"
        "vim-linediff"
        "vim-lion"
        "vim-magnum"
        "vim-operator-user"
        "vim-polyglot"
        "vim-precious"
        "vim-radical"
        "vim-recover"
        "vim-remote-viewer"
        "vim-repeat"
        "vim-sandwich"
        "vim-scriptease"
        "vim-startuptime"
        "vim-suda"
        "vim-table-mode"
        "vim-targets"
        "vim-termopen"
        "vim-textobj-user"
        "vim-undotree"
        "vim-visualrepeat"
      ] ++ [
        # vim-sved
      ];
    };

    systemd.user.sessionVariables = {
      VISUAL = "nvim";
    };

    xdg.configFile."nvim/filetype.vim".text = /*vim*/''
'';
  };
}

# vim:ft=nix:et:sw=2:tw=78
