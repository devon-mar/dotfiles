function on_attach_common(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  -- format
  vim.keymap.set("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)
  -- show code actions
  vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, bufopts)
end

local is_not_windows = not (vim.loop.os_uname().sysname:find("Windows") and true or false)

return {
  {
    "cpea2506/one_monokai.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      highlights = function(colours)
        return {
          -- Spell
          SpellBad = { sp = colours.red, undercurl = true },
          SpellCap = { sp = colours.yellow, undercurl = true },
          SpellLocal = { sp = colours.green, undercurl = true },
          SpellHint = { sp = colours.light_gray, undercurl = true },
        }
      end,
    },
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        whitelist = { "c" },
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          -- racket = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate", "TSUpdateSync" },
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })
    end,
    opts = {
      ensure_installed = {
        "c",
        "go",
        "hcl",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "racket",
        "rust",
        "terraform",
        "vim",
        "vimdoc",
        "yaml",
      },
      auto_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          scope_incremental = "<CR>",
          node_incremental = "<TAB>",
          node_decremental = "<S-TAB>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        stages = "fade",
      })
      vim.notify = require("notify")
      --- https://github.com/rcarriga/nvim-notify/wiki/Usage-Recipes#lsp-status-updates
      -- table from lsp severity to vim severity.
      local severity = {
        "error",
        "warn",
        "info",
        "info", -- map both hint and info to info?
      }
      vim.lsp.handlers["window/showMessage"] = function(err, method, params, client_id)
        vim.notify(method.message, severity[params.type])
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local augroup = vim.api.nvim_create_augroup("LSPFormat", {})

      local on_attach = function(client, bufnr)
        on_attach_common(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
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

        -- https://github.com/astral-sh/ruff/blob/main/crates/ruff_server/docs/setup/NEOVIM.md
        if client.name == "ruff" then
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false

          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format()
            end,
          })
        end

        --- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
          local semantic = client.config.capabilities.textDocument.semanticTokens
          client.server_capabilities.semanticTokensProvider = {
            full = true,
            legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
            range = true,
          }
        end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          on_attach(client, ev.buffer)
        end,
      })

      --- border stuff
      -- https://github.com/neovim/neovim/blob/2b35de386ee8854e1012feb4a6cc53b099220677/src/nvim/api/win_config.c#L452
      local border = {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
      }
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or border
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      })
      vim.lsp.enable("rust_analyzer")

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            semanticTokens = true,
            gofumpt = true,
          },
        },
      })
      vim.lsp.enable("gopls")

      vim.lsp.enable("clangd")

      vim.lsp.config("ansiblels", {
        ansible = {
          validation = {
            enabled = true,
            lint = {
              enabled = true,
            },
          },
        },
      })
      vim.lsp.enable("ansiblels")

      vim.lsp.config("yamlls", {
        yaml = {
          schemas = {
            ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            ["https://json.schemastore.org/clang-format.json"] = ".clang-format",
          },
        },
      })
      vim.lsp.enable("yamlls")

      vim.lsp.config("pyright", {
        pyright = {
          -- Using Ruff's import organizer
          disableOrganizeImports = true,
        },
      })
      vim.lsp.enable("pyright")

      vim.lsp.enable("ruff")

      vim.lsp.enable("terraform_lsp")

      vim.lsp.enable("jsonls")

      --- https://neovim.discourse.group/t/lspinfo-window-border/1566/9
      require("lspconfig.ui.windows").default_options.border = "rounded"
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = {
      "html",
      "json",
      "lua",
      "python",
      "racket",
      "terraform",
      "yaml",
      "yaml.ansible",
    },
    config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      null_ls.setup({
        on_attach = function(client, bufnr)
          on_attach_common(client, bufnr)
          if
            vim.api.nvim_buf_get_option(bufnr, "filetype") ~= "racket"
            and client:supports_method("textDocument/formatting")
          then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
        sources = {
          --- python
          null_ls.builtins.diagnostics.mypy,

          -- lua
          null_ls.builtins.formatting.stylua,

          null_ls.builtins.formatting.prettier.with({
            filetypes = { "json", "yaml", "yaml.ansible", "html" },
          }),

          -- racket
          null_ls.builtins.formatting.raco_fmt,

          -- terraform
          null_ls.builtins.formatting.terraform_fmt,
        },
      })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "L3MON4D3/LuaSnip",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- Auto pairs
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      -- https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance#menu-type
      local kind_icons = {
        Text = "",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰇽",
        Variable = "󰂡",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "󰅲",
      }

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        formatting = {
          format = function(entry, vim_item)
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
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
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
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
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp_signature_help", priority = 40 },
          { name = "nvim_lsp", priority = 30 },
          { name = "buffer", priority = 20 },
          { name = "path", priority = 10 },
        }),
        -- https://github.com/hrsh7th/nvim-cmp/pull/676#issuecomment-1002532096
        enabled = function()
          if
            require("cmp.config.context").in_treesitter_capture("comment") == true
            or require("cmp.config.context").in_syntax_group("Comment")
          then
            return false
          else
            return true
          end
        end,
      })
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    lazy = true,
    build = "make",
    cond = is_not_windows,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    cmd = { "Telescope", "EditConfig" },
    keys = {
      { "<leader>fb", "<cmd>Telescope buffers<cr>" },
      { "<leader>b", "<cmd>Telescope buffers<cr>" },
      { "<leader>fe", "<cmd>Telescope file_browser<cr>" },
      { "<leader>fE", "<cmd>Telescope file_browser path=%:p:h<cr>" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
      { "<leader>ft", "<cmd>Telescope filetypes<cr>" },
      { "<leader>fz", "<cmd>Telescope find_files<cr>" },
      { "<leader>gc", "<cmd>Telescope git_bcommits<cr>" },
      { "<leader>lE", "<cmd>Telescope diagnostics<cr>" },
      { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>" },
      { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>" },
      { "<leader>lr", "<cmd>Telescope lsp_references<cr>" },
      { "<leader>lH", "<cmd>Telescope search_history<cr>" },
      { "<leader>lh", "<cmd>Telescope resume<cr>" },
      { "<F7>", "<cmd>Telescope spell_suggest<cr>" },
    },
    config = function()
      require("telescope").setup({
        extensions = {
          file_browser = {
            --- group files and folders
            grouped = true,
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
        defaults = {
          file_ignore_patterns = { "^.git/" },
          mappings = {
            i = {
              -- :h telescope.defaults.history
              ["<C-Down>"] = require("telescope.actions").cycle_history_next,
              ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
            },
          },
        },
        pickers = {
          lsp_document_symbols = { symbol_width = 50 },
          find_files = {
            hidden = true,
            file_ignore_patterns = {
              ".git/",
              ".venv/",
              "__pycache__/",
            },
          },
          git_bcommits = {
            mappings = {
              i = {
                ["<CR>"] = function(prompt_bufnr)
                  require("telescope.actions").close(prompt_bufnr)

                  local ft = vim.bo.filetype

                  local bufnr = vim.api.nvim_create_buf(false, true)
                  local sha = require("telescope.actions.state").get_selected_entry().value
                  local file = vim.fn.expand("%")
                  local stdout = require("telescope.utils").get_os_command_output(
                    { "git", "--no-pager", "show", sha .. ":./" .. file },
                    vim.fn.getcwd()
                  )

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
                end,
              },
            },
          },
        },
      })
      if is_not_windows then
        require("telescope").load_extension("fzf")
      end
      require("telescope").load_extension("file_browser")
      local telescope = require("telescope.builtin")
      local config_dir = vim.fn.stdpath("config")
      vim.api.nvim_create_user_command("EditConfig", function()
        telescope.find_files({ cwd = config_dir, follow = true })
      end, { nargs = 0 })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>" },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>" },
      { "<leader>gsh", "<cmd>Gitsigns stage_hunk<cr>" },
      { "<leader>gd", "<cmd>Gitsigns diffthis<cr>" },
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>" },
    },
    config = function()
      require("gitsigns").setup({
        signcolumn = false,
        numhl = true,
        status_formatter = function(status)
          local status_txt = { " " .. status.head }
          local added, changed, removed = status.added, status.changed, status.removed
          if added and added > 0 then
            table.insert(status_txt, "+" .. added)
          end
          if changed and changed > 0 then
            table.insert(status_txt, "~" .. changed)
          end
          if removed and removed > 0 then
            table.insert(status_txt, "-" .. removed)
          end
          return table.concat(status_txt, " ") .. " |"
        end,
      })
    end,
  },
  {
    "akinsho/git-conflict.nvim",
    event = { "BufreadPost" },
    config = function()
      require("git-conflict").setup()
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup({ mappings = false })
      vim.keymap.set("n", "<leader>/", function()
        require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1)
      end)

      -- From the docs
      local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
      vim.keymap.set("x", "<leader>/", function()
        vim.api.nvim_feedkeys(esc, "nx", false)
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end)

      local ft = require("Comment.ft")
      ft.racket = { ";;%s", "#|%s|#" }
    end,
  },
  {
    "pearofducks/ansible-vim",
    ft = { "yaml.ansible" },
  },
  {
    "windwp/nvim-autopairs",
    lazy = true,
    config = function()
      require("nvim-autopairs").setup()
      local add_not_ft = function(rule, ft)
        if rule.not_filetypes == nil then
          rule.not_filetypes = { ft }
        else
          table.insert(rule.not_filetypes, ft)
        end
      end
      add_not_ft(require("nvim-autopairs").get_rule("'")[1], "racket")
      add_not_ft(require("nvim-autopairs").get_rule("`"), "racket")
      add_not_ft(require("nvim-autopairs").get_rule("'")[1], "scribble")
      add_not_ft(require("nvim-autopairs").get_rule("`"), "scribble")
      -- need this when lazy loading
      require("nvim-autopairs").force_attach()
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = { "|", "¦", "┆", "┊" } },
      scope = { show_start = false, show_end = false },
    },
  },
  {
    "j-hui/fidget.nvim",
    branch = "legacy",
    event = "LspAttach",
    config = function()
      require("fidget").setup({
        window = {
          --- transparent
          blend = 0,
        },
      })
    end,
  },
  {
    "benknoble/scribble.vim",
    ft = "scribble",
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}
