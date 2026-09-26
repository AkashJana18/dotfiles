-- Diagnostic display: no inline virtual text along the lines,
-- keep underline and sign-column symbols.
return {
  "LazyVim/LazyVim",
  opts = {
    diagnostics = { virtual_text = false },
  },
}
