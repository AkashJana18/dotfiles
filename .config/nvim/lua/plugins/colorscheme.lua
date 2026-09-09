return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    priority = 1000,
    lazy = false,
    opts = {
      terminal_colors = true,
      contrast = "hard", -- hard/soft or "" for default
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
  },
}
