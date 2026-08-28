return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = true,
        open = true,
        preset = {
          header = [[
 █████╗ ██╗  ██╗ █████╗ ██╗   ██╗███████╗██████╗ ███████╗███████╗██╗     ██╗██╗   ██╗███████╗    
██╔══██╗██║ ██╔╝██╔══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔════╝██║     ██║██║   ██║██╔════╝    
███████║█████╔╝ ███████║██║   ██║█████╗  ██████╔╝███████╗█████╗  ██║     ██║██║   ██║█████╗      
██╔══██║██╔═██╗ ██╔══██║╚██╗ ██╔╝██╔══╝  ██╔══██╗╚════██║██╔══╝  ██║     ██║╚██╗ ██╔╝██╔══╝      
██║  ██║██║  ██╗██║  ██║ ╚████╔╝ ███████╗██║  ██║███████║███████╗███████╗██║ ╚████╔╝ ███████╗    
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝  ╚══════╝    
                                                                                                   
like • share • subscribe
]],
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          function()
            return {
              align = "center",
              padding = 1,
              text = "\n\n\n\nThe best way to predict the future is to invent it.  — Alan Kay",
            }
          end,
        },
      },
    },
  },
}
