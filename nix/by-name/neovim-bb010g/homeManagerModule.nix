{ rows, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkDefault mkEnableOption mkIf;
  inherit (lib.strings) readFile;
  cfg = config.programs.neovim;
  opts = options.programs.neovim;
in
{
  imports = [
    rows.neovim.homeManagerModule
  ];

  options.programs.neovim.presets.boring-bb010g.enable =
    mkEnableOption "bb010g's boring Neovim config preset";
  options.programs.neovim.presets.default-bb010g.enable =
    mkEnableOption "bb010g's default Neovim config preset";
  options.programs.neovim.presets.rocks-bb010g.enable =
    mkEnableOption "bb010g's rocks.nvim-based Neovim config preset";
  options.programs.neovim.presets.vim-site-bb010g.enable =
    mkEnableOption "bb010g's Neovim config preset to set up `vim.site`";

  config = lib.mkMerge [
    (mkIf cfg.presets.vim-site-bb010g.enable {
      programs.neovim.extraLuaConfigFirst = mkBefore ''do local vimSubmodules = vim._submodules; if vimSubmodules.site == nil then vimSubmodules.site = true end end'';
      xdg.dataFile."nvim/site/lua/vim/site/init.lua".text = readFile ./_vim-site/lua/vim/site/init.lua;
    })
    (mkIf cfg.presets.default-bb010g.enable {
      programs.neovim.package = mkDefault pkgs.neovim-unstable-unwrapped;
      programs.neovim.presets.vim-site-bb010g.enable = mkDefault true;
    })
    (mkIf cfg.presets.boring-bb010g.enable {
      programs.neovim.plugins = [
        {
          plugin = pkgs.vimPlugins.mini-nvim;
          type = "lua";
          config = ''
            do
              require('mini.basics').setup({
                options = {
                  basic = true,
                  extra_ui = true,
                },
                mappings = {
                  basic = false,
                  toggle_prefix = [[\]],
                },
                autocommands = {
                  basic = true,
                  relnum_in_visual_mode = false,
                },
              })
              vim.o.cursorlineopt = 'number'
              vim.o.ruler = true
              vim.o.showmode = true
              vim.opt.shortmess:remove('WcC')

              vim.keymap.set({'n', 'v'}, 's', '<Nop>', { silent = true }) -- disable synonym for `cl`

              require('mini.icons').setup({
                style = 'ascii',
              })

              local MiniPick = require('mini.pick')
              MiniPick.setup({
              })
              vim.ui.select = MiniPick.ui_select

              require('mini.align').setup({
                mappings = {
                  start = 'gl',
                  start_with_preview = 'gL',
                },
              })

              require('mini.bracketed').setup({
              })

              local MiniNotify = require('mini.notify')
              MiniNotify.setup({
                window = {
                  config = function(buf_id)
                    local current_win = vim.api.nvim_get_current_win()
                    return {
                      anchor = 'NE',
                      col = vim.api.nvim_win_get_width(current_win),
                      relative = 'win',
                      row = 0,
                      win = current_win,
                    }
                  end,
                },
              })
              vim.notify = MiniNotify.make_notify({
              })

              require('mini.operators').setup({
                evaluate = {
                  prefix = 'g=',
                },
                exchange = {
                  prefix = 'sw',
                },
                multiply = {
                  prefix = 'sm',
                },
                replace = {
                  prefix = 'sR',
                },
                sort = {
                  prefix = 'so',
                },
              })

              require('mini.sessions').setup({
                autoread = true,
                directory = ''', -- `vim.fn.stdpath('data') .. '/session'`
              })

              require('mini.surround').setup({
                mappings = {
                  add = 'sa', -- Add surrounding in Normal and Visual modes
                  delete = 'sd', -- Delete surrounding
                  find = 'sf', -- Find surrounding (to the right)
                  find_left = 'sF', -- Find surrounding (to the left)
                  highlight = 'sh', -- Highlight surrounding
                  replace = 'sr', -- Replace surrounding
                  update_n_lines = 'sn', -- Update `n_lines`

                  suffix_last = 'l', -- Suffix to search with "prev" method
                  suffix_next = 'n', -- Suffix to search with "next" method
                },
              })

              require('mini.trailspace').setup({
              })

              if false then
              local MiniClue = require('mini.clue')
              MiniClue.setup({
                triggers = {
                  -- Leader triggers
                  { mode = 'n', keys = '<Leader>' },
                  { mode = 'x', keys = '<Leader>' },

                  -- Built-in completion
                  { mode = 'i', keys = '<C-x>' },

                  -- `g` key
                  { mode = 'n', keys = 'g' },
                  { mode = 'x', keys = 'g' },

                  -- Marks
                  { mode = 'n', keys = "'" },
                  { mode = 'n', keys = '`' },
                  { mode = 'x', keys = "'" },
                  { mode = 'x', keys = '`' },

                  -- Registers
                  { mode = 'n', keys = '"' },
                  { mode = 'x', keys = '"' },
                  { mode = 'i', keys = '<C-r>' },
                  { mode = 'c', keys = '<C-r>' },

                  -- Window commands
                  { mode = 'n', keys = '<C-w>' },

                  -- `z` key
                  { mode = 'n', keys = 'z' },
                  { mode = 'x', keys = 'z' },
                },

                clues = {
                  MiniClue.gen_clues.builtin_completion(),
                  MiniClue.gen_clues.g(),
                  MiniClue.gen_clues.marks(),
                  MiniClue.gen_clues.registers(),
                  MiniClue.gen_clues.windows(),
                  MiniClue.gen_clues.z(),
                },
              })
              end
            end'';
        }

        {
          plugin = pkgs.vimPlugins.vim-polyglot;
          type = "lua";
          config = ''
            do
              local polyglot_disabled = vim.g.polyglot_disabled
              if polyglot_disabled == nil then polyglot_disabled = {}; vim.g.polyglot_disabled = polyglot_disabled end
              if not vim.list_contains(polyglot_disabled, 'sensible') then table.insert(polyglot_disabled, 'sensible') end
            end'';
        }

        { plugin = pkgs.vimPlugins.ale; }
        { plugin = pkgs.vimPlugins.vim-eunuch; }
        { plugin = pkgs.vimPlugins.vim-scriptease; }
      ];
      programs.neovim.presets.default-bb010g.enable = mkDefault true;
      programs.neovim.presets.rocks-bb010g.enable = false;
    })
    (mkIf cfg.presets.rocks-bb010g.enable {
      programs.neovim.extraPackages =
        let
          neovim-unwrapped = cfg.package;
          nlua = neovim-unwrapped.lua.pkgs.nlua.override { inherit neovim-unwrapped; };
        in
        [
          neovim-unwrapped.lua
          nlua
        ];
      programs.neovim.plugins = [
        pkgs.vimPlugins.rocks-nvim

        # pkgs.vimPlugins.rocks-config-nvim # provides `rocks-dev.rocks.hooks.preload`
        # pkgs.vimPlugins.rocks-dev-nvim # provides `rocks-dev.rocks.hooks.preload`
        pkgs.vimPlugins.rocks-git-nvim
      ];
      programs.neovim.presets.default-bb010g.enable = mkDefault true;
      programs.neovim.presets.rocks-bb010g.enable = false;
      programs.neovim.extraLuaConfig = ''
        vim.opt.number, vim.opt.relativenumber = true, true
        vim.opt_global.scrolloff, vim.opt_global.sidescrolloff = 5, 4
      '';
    })
  ];
}
