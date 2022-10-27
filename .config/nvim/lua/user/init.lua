local config = {
  plugins = {
    init = {
      ["declancm/cinnamon.nvim"] = { disable = true },
      ["goolord/alpha-nvim"] = { disable = true }
    },
    notify = {
      background_colour = "#000000"
    }
  },
  highlights = {
    default_theme = function(highlights)
      local C = require "default_theme.colors"

      -- transparency
      -- https://github.com/AstroNvim/AstroNvim/issues/8
      if vim.g.neovide == nil then
        highlights.Normal = {bg = C.none, ctermbg = C.none}
        highlights.NormalNC = {bg = C.none, ctermbg = C.none}
        highlights.CursorColumn = {cterm = {}, ctermbg = C.none, ctermfg = C.none}
        highlights.CursorLineNr = {cterm = {}, ctermbg = C.none, ctermfg = C.none}
        highlights.LineNr = {}
        highlights.SignColumn = {}
        highlights.StatusLine = {}
      end
      return highlights
    end,
  },
  polish = function()
    if vim.g.neovide == true then
      vim.g.neovide_cursor_animation_length = 0
      vim.opt.guifont = "CaskaydiaMono NF SemiLight:h12"
    end
  end
}

return config
