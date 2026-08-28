return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
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
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          -- Clear the specific faded highlights back to regular text behavior
          vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { link = "Normal" })
          vim.api.nvim_set_hl(0, "SnacksPickerDirIgnored", { link = "Normal" })
          vim.api.nvim_set_hl(0, "NvimTreeGitIgnored", { link = "Normal" })
          vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { link = "Normal" })
        end,
      })
    end,
  },
}
