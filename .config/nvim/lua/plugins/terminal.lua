return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          style = "terminal", -- resolves to float via Snacks.config.style() terminal.lua:32
          position = "float",
          border = "rounded", -- "single"|"double"|"rounded"|"solid"
          wo = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
        },
      },
    },
    keys = {
      -- floating cwd / root (you already have <leader>fT/ft, this adds alternative)
      {
        "<c-t>",
        function()
          Snacks.terminal(nil, { cwd = LazyVim.root() })
        end,
        desc = "Terminal (Root Float)",
        mode = { "n", "t" },
      },
      {
        "<leader>ft",
        function()
          Snacks.terminal(nil, { cwd = LazyVim.root() })
        end,
        desc = "Terminal (Root Dir)",
      },
      {
        "<leader>fT",
        function()
          Snacks.terminal()
        end,
        desc = "Terminal (cwd)",
      },
      -- example dedicated lazygit float
      -- { "<leader>gg", function() Snacks.terminal("lazygit", { cwd = LazyVim.root.git() }) end, desc = "Lazygit Float" },
    },
  },
}
