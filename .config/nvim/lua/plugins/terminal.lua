local float = {
  style = "terminal",
  position = "float",
  border = "single",
  width = 0.8,
  height = 0.8,
  backdrop = 60,
  wo = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
}

return {
  {
    "folke/snacks.nvim",
    opts = {},
    keys = {
      {
        "<c-t>",
        function()
          Snacks.terminal(nil, { cwd = LazyVim.root(), win = float })
        end,
        desc = "Terminal (Root Float)",
        mode = { "n", "t" },
      },
      {
        "<leader>ft",
        function()
          Snacks.terminal(nil, { cwd = LazyVim.root(), win = float })
        end,
        desc = "Terminal (Root Dir)",
      },
      {
        "<leader>fT",
        function()
          Snacks.terminal(nil, { win = float })
        end,
        desc = "Terminal (cwd)",
      },
    },
  },
}
