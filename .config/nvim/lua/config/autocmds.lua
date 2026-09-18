-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Global tint disable + border title in borders.lua
-- Disable ALL bg tints that make floats/diagnostic lines look muddy
local function _clear_bg(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  if hl.bg ~= nil then
    -- keep all attrs except bg, force transparent
    local new = {}
    for k, v in pairs(hl) do
      if k ~= "bg" then
        new[k] = v
      end
    end
    new.bg = "NONE"
    vim.api.nvim_set_hl(0, name, new)
  end
end

local function _disable_tint()
  -- floats: make bg transparent (inherits Normal #1d2021) so no lighter tint
  vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FocalFloat", { link = "Normal" })
  vim.api.nvim_set_hl(0, "FocalBorder", { bg = "NONE" })
  -- make empty statusline transparent so snacks_dashboard (where lualine is
  -- disabled via disabled_filetypes) shows no visible bar instead of a solid
  -- dark strip. Lualine sections keep their own bg, so normal buffers still
  -- show lualine; only the empty statusline becomes invisible.
  vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineTerm", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineTermNC", { bg = "NONE" })
  for _, sev in ipairs({ "Error", "Warn", "Info", "Hint", "Ok" }) do
    _clear_bg("DiagnosticFloating" .. sev)
    _clear_bg("DiagnosticVirtualText" .. sev)
    _clear_bg("DiagnosticSign" .. sev)
  end
  vim.opt.winblend = 0
  vim.opt.pumblend = 0
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = _disable_tint,
})

-- autocmds.lua itself is loaded on VeryLazy, so the User VeryLazy event that
-- triggered its load has already fired -- calling directly + defer covers it
_disable_tint()
vim.defer_fn(_disable_tint, 100)
vim.defer_fn(_disable_tint, 500)

-- Transparent statusline handles the empty bar on snacks_dashboard without
-- juggling laststatus (which races with LazyVim's lualine VeryLazy restore).
-- The bar stays at laststatus=3 but becomes invisible when lualine is disabled
-- (dashboard), while lualine sections still render with their own bg on normal buffers.
