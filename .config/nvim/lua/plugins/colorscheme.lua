return { --[[
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      custom_highlights = function()
        return {
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },
          CursorLine = { bg = "NONE" },
          CursorColumn = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          LineNr = { bg = "NONE" },
          CursorLineNr = { bg = "NONE" },
          EndOfBuffer = { bg = "NONE" },

          NormalFloat = { bg = "NONE" },
          FloatBorder = { bg = "NONE" },
          FloatTitle = { bg = "NONE" },

          Pmenu = { bg = "NONE" },
          PmenuSel = { bg = "NONE" },
          PmenuSbar = { bg = "NONE" },
          PmenuThumb = { bg = "NONE" },

          TelescopeNormal = { bg = "NONE" },
          TelescopeBorder = { bg = "NONE" },
          TelescopePromptNormal = { bg = "NONE" },
          TelescopePromptBorder = { bg = "NONE" },
          TelescopeResultsNormal = { bg = "NONE" },
          TelescopeResultsBorder = { bg = "NONE" },
          TelescopePreviewNormal = { bg = "NONE" },
          TelescopePreviewBorder = { bg = "NONE" },

          NeoTreeNormal = { bg = "NONE" },
          NeoTreeNormalNC = { bg = "NONE" },
          NeoTreeEndOfBuffer = { bg = "NONE" },
          NeoTreeFloatNormal = { bg = "NONE" },
          NeoTreeFloatBorder = { bg = "NONE" },

          LazyNormal = { bg = "NONE" },
          LazyButton = { bg = "NONE" },
          LazyButtonActive = { bg = "NONE" },
          LazyH1 = { bg = "NONE" },
          LazySpecial = { bg = "NONE" },
          LazyProgressDone = { bg = "NONE" },
          LazyProgressTodo = { bg = "NONE" },

          MasonNormal = { bg = "NONE" },
          WhichKeyFloat = { bg = "NONE" },
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
          "FloatBorder",
          "FloatTitle",

          "CursorLine",
          "SignColumn",
          "EndOfBuffer",
          "LineNr",
          "CursorLineNr",

          "NeoTreeNormal",
          "NeoTreeNormalNC",
          "NeoTreeEndOfBuffer",
          "NeoTreeFloatNormal",
          "NeoTreeFloatBorder",

          "LazyNormal",
          "LazyButton",
          "LazyButtonActive",
          "LazyH1",
          "LazySpecial",
          "LazyProgressDone",
          "LazyProgressTodo",

          "MasonNormal",
          "WhichKeyFloat",

          "TelescopeNormal",
          "TelescopeBorder",
          "TelescopePromptNormal",
          "TelescopePromptBorder",
          "TelescopeResultsNormal",
          "TelescopeResultsBorder",
          "TelescopePreviewNormal",
          "TelescopePreviewBorder",

          "Pmenu",
          "PmenuSel",
          "PmenuSbar",
          "PmenuThumb",
        },
      })

      require("transparent").clear_prefix("BufferLine")
      require("transparent").clear_prefix("NeoTree")
      require("transparent").clear_prefix("Lazy")
      require("transparent").clear_prefix("Mason")
      require("transparent").clear_prefix("Telescope")
      require("transparent").clear_prefix("Noice")
      require("transparent").clear_prefix("Notify")
    end,
  },
  ]]

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
