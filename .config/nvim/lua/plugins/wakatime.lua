return {
  "wakatime/vim-wakatime",
  lazy = false,
  opts = {
    status_bar_enabled = true,
  },
  config = function(_, opts)
    require("wakatime").setup(opts)
  end,
}
