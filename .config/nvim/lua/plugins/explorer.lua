return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
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
