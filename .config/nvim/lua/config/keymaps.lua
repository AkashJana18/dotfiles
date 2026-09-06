-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<D-a>", "ggVG", { desc = "Select all" })

-- Diagnostics / error navigation
vim.api.nvim_create_user_command("Compile", function()
  vim.opt.makeprg = "cargo build"
  vim.cmd("make")
  vim.cmd("copen")
end, { desc = "Cargo build → quickfix", nargs = 0 })

vim.keymap.set("n", "en", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "ep", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })

vim.keymap.set("n", "ed", function()
  vim.diagnostic.open_float()
end, { desc = "Line diagnostics" })

vim.keymap.set("n", "el", function()
  vim.diagnostic.setloclist()
end, { desc = "Diagnostics → loclist" })

vim.keymap.set("n", "et", function()
  if Snacks and Snacks.picker and Snacks.picker.diagnostics then
    Snacks.picker.diagnostics()
  else
    vim.diagnostic.setqflist()
    vim.cmd("copen")
  end
end, { desc = "Diagnostics (Snacks picker)" })

vim.keymap.set("n", "ef", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { desc = "Diagnostics → quickfix" })
