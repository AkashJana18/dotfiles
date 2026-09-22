return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = false,
            ignored = false,
            -- narrow the explorer window:
            layout = {
              preset = "sidebar",
              layout = {
                width = 26,
                min_width = 26,
              },
            },
          },
        },
      },
    },
    -- init = function()
    --   local function undim()
    --     vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "Normal" })
    --     vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { link = "Normal" })
    --   end
    --   vim.api.nvim_create_autocmd("ColorScheme", {
    --     pattern = "*",
    --     callback = undim,
    --   })
    --   undim()
    --   vim.defer_fn(undim, 100)
    -- end,
  },
}
