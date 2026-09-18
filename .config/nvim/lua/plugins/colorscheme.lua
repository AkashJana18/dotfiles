return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "zenwritten",
    },
  },
  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
    config = function()
      vim.g.zenbones_darken_comments = 45
      vim.o.background = "dark" -- required for darkness to apply
      vim.g.zenwritten_darkness = "stark" -- stark or "warm"
      vim.g.zenwritten_lightness = "dim" -- bright or dim only if background=light
      vim.g.zenwritten_transparent_background = true
      vim.cmd.colorscheme("zenwritten")
    end,
  },
}
