local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  use {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        stages = "fade"
      })
      vim.notify = require("notify")
      
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig["rust_analyzer"].setup{
        capabilities = capabilities
      }
      lspconfig["racket_langserver"].setup{
        cmd = { "xvfb-run", "racket", "--lib", "racket-langserver" },
        capabilities = capabilities
      }
      lspconfig["gopls"].setup{
        capabilities = capabilities
      }
      lspconfig["clangd"].setup{
        capabilities = capabilities
      }
    end
  }

  use {
    "cpea2506/one_monokai.nvim",
    config = function()
      require("one_monokai").setup({ transparent = true })
    end
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      if not packer_bootstrap then
        vim.cmd("TSUpdate")
      end
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c",
          "lua",
          "vim",
          "help",
          "rust",
          "go",
        },
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        rainbow = {
          enable = true,
          disable = { "html" },
          extended_mode = false,
          max_file_lines = nil,
        },
      })
    end,
  }
  use {
    "mrjones2014/nvim-ts-rainbow",
    after = "nvim-treesitter"
  }

  use {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      vim.opt.completeopt = {"menu", "menuone", "noselect"}

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      -- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#menu-type
      local kind_icons = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "ﴯ",
        Interface = "",
        Module = "",
        Property = "ﰠ",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = ""
      }

      cmp.setup({
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
          vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            nvim_lua = "[Lua]",
              latex_symbols = "[LaTeX]",
            })[entry.source.name]
          return vim_item
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-e>'] = cmp.mapping.abort(),
          ['<C-Space>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          },

          ['<Tab>'] = function(fallback)
            if not cmp.select_next_item() then
              if vim.bo.buftype ~= 'prompt' and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if not cmp.select_prev_item() then
              if vim.bo.buftype ~= 'prompt' and has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
        }),
        -- https://github.com/hrsh7th/nvim-cmp/pull/676#issuecomment-1002532096
        enabled = function()
          if require"cmp.config.context".in_treesitter_capture("comment") == true or require"cmp.config.context".in_syntax_group("Comment") then
            return false
          else
            return true
          end
        end,
      })

    end
  }
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-buffer"

  use {
    "luochen1990/rainbow",
    ft = { "scheme" }
  }

  use {
    "benknoble/vim-racket",
    ft = { "scheme" }
  }
  
  -- use {
  --   "gpanders/nvim-parinfer",
  --   ft = { "scheme" }
  -- }

  use {
    "nvim-telescope/telescope.nvim",
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function()
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files, {})
      vim.keymap.set("n", "<leader>fg", telescope.live_grep, {})
      vim.keymap.set("n", "<leader>fb", telescope.buffers, {})
      vim.keymap.set("n", "<leader>fh", telescope.help_tags, {})
      -- https://github.com/neovim/nvim-lspconfig/issues/1046#issuecomment-1396124472
      vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, {})
    end
  }

  use {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signcolumn = false,
        numhl = true
      })
    end
  }

  use {
    "akinsho/toggleterm.nvim",
    tag = '*',
    config = function()
      require("toggleterm").setup({
        direction = "float"
      })
    end
  }
  

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
