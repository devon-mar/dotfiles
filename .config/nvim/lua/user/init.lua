local config = {
  plugins = {
    init = {
      ["declancm/cinnamon.nvim"] = { disable = true }
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
      highlights.Normal = {bg = C.none, ctermbg = C.none}
      highlights.CursorColumn = {cterm = {}, ctermbg = C.none, ctermfg = C.none}
      highlights.CursorLineNr = {cterm = {}, ctermbg = C.none, ctermfg = C.none}
      highlights.LineNr = {}
      highlights.SignColumn = {}
      highlights.StatusLine = {}
      return highlights
    end,
  },
}

return config
