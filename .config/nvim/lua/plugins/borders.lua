return {
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
  -- 2. Hover / signatureHelp border via noice (LazyVim uses noice for lsp docs)
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        lsp_doc_border = true,
      },
    },
  },
}
