return {
  -- NOTE: vim.o.winborder="rounded" (options.lua, 0.12 native) is the global
  -- fallback for hover/signatureHelp/diagnostics. Below keeps LazyVim-specific
  -- extras winborder can't express: float title/source/scope/max_width + noice docs.
  -- 1. Diagnostic floating window: add rounded border + beautify
  --    (your screenshot: Diagnostics: ... had no border)
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        float = {
          border = "rounded",
          header = "", -- or false to suppress inside "Diagnostics:" default
          prefix = " ",
          source = "if_many",
          scope = "cursor",
          max_width = 80,
          wrap = true,
          title = " Diagnostics ",
          title_pos = "left",
          shadow = false,
          -- footer = " [code] ", footer_pos="right" -- optional
        },
      },
    },
  },
  -- 2. hover border via noice (signaturehelp moved to blink.cmp below so the
  -- express overload float stays compact and doesn't cover the line being typed)
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
      lsp = {
        signature = { enabled = false },
      },
    },
  },
  -- 3. compact signature-help via blink.cmp (single active signature, tries
  -- above cursor first, scrolls instead of growing to 20x120 like noice)
  {
    "saghen/blink.cmp",
    opts = {
      signature = {
        enabled = true,
        window = {
          -- max_width = 60,
          -- max_height = 10,
          show_documentation = true,
          direction_priority = { "n", "s" },
        },
      },
    },
  },
}
