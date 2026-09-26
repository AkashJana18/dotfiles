-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.guifont = "FiraCode Nerd Font:h20"
vim.opt.autoread = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.swapfile = false
vim.opt.winblend = 0
vim.opt.pumblend = 0

-- Neovim 0.12 natives (keeping lazy.nvim + blink.cmp, so autocomplete stays off)
vim.o.winborder = "rounded" -- default border for hover/signature/diagnostic floats
vim.o.pumborder = "rounded" -- border for completion popup
vim.o.pummaxwidth = 40 -- 0.12: cap completion popup width
vim.opt.completeopt:append({ "nearest", "popup" }) -- nearest: sort by cursor distance; popup: LSP resolve preview
-- vim.o.autocomplete = false -- default; blink.cmp owns autotrigger. Enabling native would double-trigger.
