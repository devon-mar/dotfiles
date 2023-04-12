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

function on_attach_common(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  -- format
  vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format { async = true } end, bufopts)
  -- show code actions
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, bufopts)
end

return require("packer").startup(function(use)
  use {
    "wbthomason/packer.nvim",
    config = function()
      vim.cmd([[
        augroup packer_user_config
          autocmd!
          autocmd BufWritePost plugins.lua source <afile> | PackerCompile
        augroup end
      ]])
    end
  }

  use {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        stages = "fade"
      })
      vim.notify = require("notify")
      vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local lvl = ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type]
        notify(result.message, lvl, {
          title = "LSP | " .. client.name,
          timeout = 10000,
          keep = function()
            return lvl == "ERROR" or lvl == "WARN"
          end,
        })
      end
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    config = function()
      local on_attach = function(client, bufnr)
        on_attach_common(client, bufnr)
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, bufopts)
        -- go to declaration of the symbol under the cursor
        vim.keymap.set("n", "<leader>lD", vim.lsp.buf.declaration, bufopts)
        -- go to definition of the symbol under the cursor
        vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "<leader>le", function()
          vim.diagnostic.open_float({
            focusable = false,
            border = "rounded",
            source = "always",
          })
        end, bufopts)

        local telescope = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ls", telescope.lsp_document_symbols)
        vim.keymap.set("n", "<leader>lS", telescope.lsp_workspace_symbols)
        vim.keymap.set("n", "<leader>lr", telescope.lsp_references)

        --- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
          local semantic = client.config.capabilities.textDocument.semanticTokens
          client.server_capabilities.semanticTokensProvider = {
            full = true,
            legend = {tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes},
            range = true,
          }
        end

      end

      --- border stuff
      -- https://github.com/neovim/neovim/blob/2b35de386ee8854e1012feb4a6cc53b099220677/src/nvim/api/win_config.c#L452
      local border = {
            {"╭", "FloatBorder"},
            {"─", "FloatBorder"},
            {"╮", "FloatBorder"},
            {"│", "FloatBorder"},
            {"╯", "FloatBorder"},
            {"─", "FloatBorder"},
            {"╰", "FloatBorder"},
            {"│", "FloatBorder"},
      }
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig["rust_analyzer"].setup{
        on_attach = on_attach,
        capabilities = capabilities
      }
      lspconfig["racket_langserver"].setup{
        cmd = { "xvfb-run", "racket", "--lib", "racket-langserver" },
        on_attach = on_attach,
        capabilities = capabilities
      }
      lspconfig["gopls"].setup{
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            semanticTokens = true
          }
        }
      }
      lspconfig["clangd"].setup{
        on_attach = on_attach,
        capabilities = capabilities
      }
      lspconfig["ansiblels"].setup{
        on_attach = on_attach,
        capabilities = capabilities
      }
      lspconfig["yamlls"].setup{
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*"
            }
          }
        },
      }
      lspconfig["pyright"].setup{
        on_attach = on_attach,
        capabilities = capabilities
      }
    end
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    requires = {"nvim-lua/plenary.nvim"},
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        on_attach = on_attach_common,
        sources = {
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.black,

          null_ls.builtins.code_actions.gitsigns,

          null_ls.builtins.formatting.prettier,
        },
      })
    end,
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
          "go",
          "json",
          "lua",
          "python",
          "racket",
          "rust",
          "vim",
          "vimdoc",
          "yaml",
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
    "HiPhish/nvim-ts-rainbow2",
    after = "nvim-treesitter"
  }

  use {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      vim.opt.completeopt = {"menu", "menuone", "noselect"}

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      -- Auto pairs
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

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

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end

      cmp.setup({
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
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
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
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
          ['<C-Space>'] = cmp.mapping.complete(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm { select = false },
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 30 },
          { name = "buffer", priority = 20 },
          { name = "path", priority = 10 },
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
  use "hrsh7th/cmp-path"

  use {
    "benknoble/vim-racket",
    ft = { "scheme" }
  }
  
  use {
    "gpanders/nvim-parinfer",
    ft = { "scheme" },
    disable = true
  }

  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make"
  }
  use {
    "nvim-telescope/telescope.nvim",
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function()
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        },
        defaults = {
          file_ignore_patterns = {"^.git/"},
        },
        pickers = {
          find_files = { hidden = true },
          git_bcommits = {
            mappings = {
              i = {
                ["<CR>"] = function(prompt_bufnr)
                  require("telescope.actions").close(prompt_bufnr)

                  local ft = vim.bo.filetype

                  local bufnr = vim.api.nvim_create_buf(false, true)
                  local sha = require("telescope.actions.state").get_selected_entry().value
                  local file = vim.fn.expand("%")
                  local stdout = require("telescope.utils").get_os_command_output({"git", "--no-pager", "show", sha .. ":./" .. file}, vim.fn.getcwd())

                  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, stdout)
                  vim.api.nvim_buf_set_name(bufnr, file .. "@" .. sha)
                  vim.api.nvim_buf_set_option(bufnr, "readonly", true)
                  vim.cmd("rightbelow vert sbuffer " .. bufnr)
                  vim.bo.filetype = ft

                  vim.api.nvim_create_autocmd("WinClosed", {
                    buffer = bufnr,
                    nested = true,
                    once = true,
                    callback = function()
                      vim.api.nvim_buf_delete(bufnr, { force = true })
                    end,
                  })
                end
              }
            }
          }

        }
      })
      require("telescope").load_extension("fzf")
      local telescope = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", telescope.find_files)
      vim.keymap.set("n", "<leader>fg", telescope.live_grep)
      vim.keymap.set("n", "<leader>fb", telescope.buffers)
      vim.keymap.set("n", "<leader>fh", telescope.help_tags)
      vim.keymap.set("n", "<leader>ft", telescope.filetypes)
      vim.keymap.set("n", "<leader>gc", telescope.git_bcommits)
      vim.keymap.set("n", "<leader>lE", telescope.diagnostics)

      local config_dir = (vim.fn.has("win32") == 1) and "~/AppData/Local/nvim/lua" or "~/.config/nvim"
      vim.api.nvim_create_user_command("EditConfig", function() telescope.find_files({ cwd = config_dir }) end, { nargs=0 })
    end
  }

  use {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signcolumn = false,
        numhl = true,
        status_formatter = function(status)
          local status_txt = { " "..status.head }
          local added, changed, removed = status.added, status.changed, status.removed
          if added   and added   > 0 then table.insert(status_txt, '+'..added  ) end
          if changed and changed > 0 then table.insert(status_txt, '~'..changed) end
          if removed and removed > 0 then table.insert(status_txt, '-'..removed) end
          return table.concat(status_txt, " ") .. " |"
        end,
      })
    end
  }

  use {
    "akinsho/toggleterm.nvim",
    tag = "*",
    config = function()
      require("toggleterm").setup({
        direction = "float"
      })
    end
  }

  use {
    "akinsho/git-conflict.nvim",
    tag = "*",
    config = function()
      require("git-conflict").setup()
    end
  }

  use {
    "numToStr/Comment.nvim",
    config = function()
        require("Comment").setup({ mappings = false })
        vim.keymap.set("n", "<leader>/", function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end)

        -- From the docs
        local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
        vim.keymap.set("x", "<leader>/", function()
          vim.api.nvim_feedkeys(esc, "nx", false)
          require("Comment.api").toggle.linewise(vim.fn.visualmode())
        end)

        local ft = require("Comment.ft")
        ft.racket = { ";;%s", "#|%s|#" }
    end
  }

  use "pearofducks/ansible-vim"

  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
      local add_not_ft = function(rule, ft)
        if rule.not_filetypes == nil then
          rule.not_filetypes = {ft}
        else
          table.insert(rule.not_filetypes, ft)
        end
      end
      add_not_ft(require("nvim-autopairs").get_rule("'")[1], "racket")
      add_not_ft(require("nvim-autopairs").get_rule("`"), "racket")
    end,
  }

  use "L3MON4D3/LuaSnip"

  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        char_list = {"|", "¦", "┆", "┊"}
      })
    end,
  }

  use {
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({
        window = {
          --- transparent
          blend = 0
        }
      })
    end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
