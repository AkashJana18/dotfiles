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

vim.keymap.set("n", "<leader>xa", function()
  local vt = vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = not vt })
end, { desc = "Toggle diagnostic virtual text" })

-- 0.12 natives: opt-in plugins ship under pack/dist/opt, packadd once so
-- :Undotree / :DiffTool are always available (:lsp is builtin, no packadd needed).
pcall(vim.cmd.packadd, "nvim.undotree")
pcall(vim.cmd.packadd, "nvim.difftool")

vim.keymap.set("n", "<leader>fu", function()
  -- packadd here (not just top-level) so the map works even if startup-time
  -- packadd was skipped or failed; cheap and idempotent after first load.
  vim.cmd.packadd("nvim.undotree")
  vim.cmd.Undotree()
end, { desc = "Undo tree (native 0.12)" })
vim.keymap.set("n", "<leader>fD", function()
  vim.cmd.packadd("nvim.difftool")
  local left = vim.fn.input("DiffTool left: ", "", "file")
  if left == "" then
    return
  end
  local right = vim.fn.input("DiffTool right: ", "", "file")
  if right == "" then
    return
  end
  vim.cmd("DiffTool " .. vim.fn.fnameescape(left) .. " " .. vim.fn.fnameescape(right))
end, { desc = "DiffTool (native 0.12)" })
-- Bare :lsp needs a subcommand (enable|disable|restart|stop), so this map goes
-- to the informative view instead: per-buffer LSP features + clients.
vim.keymap.set("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP status (native health)" })
-- Native defaults worth knowing (no mapping needed): v_an/v_in treesitter or
-- LSP selectionRange, grt type-definition, grx codelens-run, gx documentLink.

-- Headless one-line code explanations: no opencode UI, comment inserted inline.
-- Reuses one opencode session per project (see lua/opencode-comment.lua).
vim.keymap.set("x", "<leader>ce", function()
  require("opencode-comment").explain()
end, { desc = "Explain selection as comment" })
vim.api.nvim_create_user_command("OpencodeCommentNewSession", function()
  require("opencode-comment").new_session()
end, { desc = "Reset opencode-comment session for this project" })
