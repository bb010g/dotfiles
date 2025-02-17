{ homeManagerModules, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.modules) mkBefore mkDefault mkIf;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) readFile;
  cfg = config.programs.neovim;
in
{
  imports = [
    homeManagerModules.neovim
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
      programs.neovim.extraLuaConfig = ''
        vim.opt_global.scrolloff, vim.opt_global.sidescrolloff = 5, 4
        if vim.fn.has('nvim-0.9') then vim.opt_global.exrc = true end
      '';
    })
    (mkIf cfg.presets.boring-bb010g.enable {
      programs.neovim.extraLuaConfigFirst = ''
        vim.loader.enable(true)
      '';
      programs.neovim.plugins = [
        # I'm pretty sure mini-nvim executes `runtime filetype.vim` somewhere, so disabling polyglot must be first.
        {
          plugin = pkgs.vimPlugins.vim-polyglot;
          type = "lua";
          config = ''
            vim.g.polyglot_disabled = vim.site.list_extend_unique(vim.g.polyglot_disabled or {}, { 'sensible' })'';
        }

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

              require('mini.pick').setup({
              })
              vim.ui.select = require('mini.pick').ui_select

              require('mini.align').setup({
                mappings = {
                  start = 'gl',
                  start_with_preview = 'gL',
                },
              })

              require('mini.bracketed').setup({
              })

              require('mini.notify').setup({
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
              vim.notify = require('mini.notify').make_notify({
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
              require('mini.clue').setup({
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
                  require('mini.clue').gen_clues.builtin_completion(),
                  require('mini.clue').gen_clues.g(),
                  require('mini.clue').gen_clues.marks(),
                  require('mini.clue').gen_clues.registers(),
                  require('mini.clue').gen_clues.windows(),
                  require('mini.clue').gen_clues.z(),
                },
              })
              end
            end'';
        }

        {
          plugin = pkgs.vimPlugins.nvim-treesitter;
          type = "lua";
          config = ''
            require('nvim-treesitter.configs').setup({
              highlight = {
                enable = true,
                disable = function(lang, buf)
                  local max_filesize = 100 * 1024 -- 100 KB
                  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                  if ok and stats and stats.size > max_filesize then
                      return true
                  end
                end,
              },
            })'';
        }

        {
          plugin = pkgs.vimPlugins.ale;
          type = "lua";
          config = ''
            vim.g.ale_floating_preview = 1'';
        }
        {
          plugin = pkgs.vimPlugins.direnv-nvim;
          type = "lua";
          config = ''
            require('direnv-nvim').setup({
            })'';
        }
        { plugin = pkgs.vimPlugins.netman-nvim; }
        { plugin = pkgs.vimPlugins.nvim-dap; }
        {
          plugin = pkgs.vimPlugins.nvim-dap-ui;
          type = "lua";
          config = ''
            vim.site._submodules.dapui = true
            vim.site.dapui.user_config = {
            }'';
        }
        {
          plugin = pkgs.vimPlugins.nvim-treesitter-context;
          type = "lua";
          config = ''
            require('treesitter-context.config').update({
              enable = true,
              multiwindow = true,
              mode = 'topline',
            })'';
        }
        { plugin = pkgs.vimPlugins.plenary-nvim; }
        {
          plugin = pkgs.vimPlugins.ssr-nvim;
          type = "lua";
          config = ''
            require('ssr').setup({
              adjust_window = true,
              border = 'rounded',
              -- max_height = 25,
              -- max_width = 120,
              -- min_height = 5,
              -- min_width = 50,
            })
            -- vim.keymap.set({ "n", "x" }, "<leader>sr", function() require("ssr").open() end)'';
        }
        { plugin = pkgs.vimPlugins.vim-eunuch; }
        { plugin = pkgs.vimPlugins.vim-scriptease; }
      ];
      programs.neovim.presets.default-bb010g.enable = mkDefault true;
      programs.neovim.presets.rocks-bb010g.enable = false;
    })
    (mkIf cfg.presets.rocks-bb010g.enable {
      assertions = [
        {
          assertion = !cfg.presets.boring-bb010g;
          message = "{option}`config.programs.neovim.presets.rocks-bb010g` is incompatible with {option}`config.programs.neovim.presets.boring-bb010g`";
        }
      ];
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
      programs.neovim.extraLuaConfig = ''
        vim.opt.number, vim.opt.relativenumber = true, true
      '';
    })
  ];
}
