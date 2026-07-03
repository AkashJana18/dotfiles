return {
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          -- Main editor
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },
          EndOfBuffer = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          LineNr = { bg = "NONE" },
          CursorLineNr = { fg = colors.lavender, bold = true },

          -- Keep the current line visible
          CursorLine = { bg = colors.surface0 },
          CursorColumn = { bg = colors.surface0 },

          -- Visual selection
          Visual = { bg = colors.surface1 },

          -- Floating windows
          NormalFloat = { bg = "NONE" },
          FloatTitle = { fg = colors.blue, bold = true },
          FloatBorder = { fg = colors.blue, bg = "NONE" },

          -- Completion menu
          Pmenu = { bg = "NONE" },
          PmenuSel = { bg = colors.surface1, fg = colors.text },
          PmenuSbar = { bg = colors.surface0 },
          PmenuThumb = { bg = colors.overlay0 },

          -- Telescope
          TelescopeNormal = { bg = "NONE" },
          TelescopePromptNormal = { bg = "NONE" },
          TelescopeResultsNormal = { bg = "NONE" },
          TelescopePreviewNormal = { bg = "NONE" },

          TelescopeBorder = { fg = colors.blue, bg = "NONE" },
          TelescopePromptBorder = { fg = colors.blue, bg = "NONE" },
          TelescopeResultsBorder = { fg = colors.blue, bg = "NONE" },
          TelescopePreviewBorder = { fg = colors.blue, bg = "NONE" },

          -- Neo-tree
          NeoTreeNormal = { bg = "NONE" },
          NeoTreeNormalNC = { bg = "NONE" },
          NeoTreeEndOfBuffer = { bg = "NONE" },
          NeoTreeFloatNormal = { bg = "NONE" },
          NeoTreeFloatBorder = { fg = colors.blue, bg = "NONE" },

          -- Lazy
          LazyNormal = { bg = "NONE" },
          LazyButton = { bg = "NONE" },
          LazyButtonActive = { bg = colors.surface1, fg = colors.text },
          LazyH1 = { bg = "NONE" },
          LazySpecial = { bg = "NONE" },
          LazyProgressDone = { bg = "NONE" },
          LazyProgressTodo = { bg = "NONE" },

          -- Misc
          MasonNormal = { bg = "NONE" },
          WhichKeyFloat = { bg = "NONE" },

          -- Search
          Search = { bg = colors.yellow, fg = colors.base },
          CurSearch = { bg = colors.peach, fg = colors.base },
          IncSearch = { bg = colors.red, fg = colors.base },
        }
      end,
    },
  },

  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      require("transparent").setup({
        extra_groups = {
          "Normal",
          "NormalNC",
          "NormalFloat",
          "FloatTitle",

          "SignColumn",
          "EndOfBuffer",
          "LineNr",

          "NeoTreeNormal",
          "NeoTreeNormalNC",
          "NeoTreeEndOfBuffer",
          "NeoTreeFloatNormal",

          "LazyNormal",
          "LazyButton",
          "LazyH1",
          "LazySpecial",
          "LazyProgressDone",
          "LazyProgressTodo",

          "MasonNormal",
          "WhichKeyFloat",

          "TelescopeNormal",
          "TelescopePromptNormal",
          "TelescopeResultsNormal",
          "TelescopePreviewNormal",

          "Pmenu",
        },
      })

      require("transparent").clear_prefix("BufferLine")
      require("transparent").clear_prefix("Lazy")
      require("transparent").clear_prefix("Mason")
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
