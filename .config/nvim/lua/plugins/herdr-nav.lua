-- Seamless ctrl+h/j/k/l across herdr panes and Neovim splits.
-- Moves within Neovim windows; at a split edge falls through to herdr.
-- with_tmux = false: herdr is the multiplexer, so skip vim-tmux-navigator.
return {
  "aimdevlee/herdr-nvim-nav",
  config = function()
    require("herdr-nvim-nav").setup({ with_tmux = false })
  end,
}
