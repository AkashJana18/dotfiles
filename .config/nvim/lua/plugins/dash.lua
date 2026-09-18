-- seed RNG once so dashboard quotes vary across sessions/restarts
pcall(function()
  math.randomseed(os.time() + vim.loop.hrtime())
  -- discard first few values (LuaJIT quirk)
  math.random()
  math.random()
  math.random()
end)

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = true,
        open = true,
        preset = {
          header = [[
 █████╗ ██╗  ██╗ █████╗ ███████╗██╗  ██╗     ██████╗ ██████╗ ██████╗ ███████╗███████╗
██╔══██╗██║ ██╔╝██╔══██╗██╔════╝██║  ██║    ██╔════╝██╔═══██╗██╔══██╗██╔════╝██╔════╝
███████║█████╔╝ ███████║███████╗███████║    ██║     ██║   ██║██║  ██║█████╗  ███████╗
██╔══██║██╔═██╗ ██╔══██║╚════██║██╔══██║    ██║     ██║   ██║██║  ██║██╔══╝  ╚════██║
██║  ██║██║  ██╗██║  ██║███████║██║  ██║    ╚██████╗╚██████╔╝██████╔╝███████╗███████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚══════╝
                                                                                     
                                                                                                   
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
            local quotes = {
              "The best way to predict the future is to invent it.  — Alan Kay",
              "Talk is cheap. Show me the code.  — Linus Torvalds",
              "Programs must be written for people to read, and only incidentally for machines to execute.  — Harold Abelson",
              "Simplicity is the soul of efficiency.  — Austin Freeman",
              "First, solve the problem. Then, write the code.  — John Johnson",
              "Code is like humor. When you have to explain it, it's bad.  — Cory House",
              "Fix the cause, not the symptom.  — Steve Maguire",
              "Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away.  — Antoine de Saint-Exupéry",
              "Stay hungry, stay foolish.  — Steve Jobs",
              "The only way to learn a new programming language is by writing programs in it.  — Dennis Ritchie",
              "Controlling complexity is the essence of computer programming.  — Brian Kernighan",
              "Make it work, make it right, make it fast.  — Kent Beck",
            }
            local quote = quotes[math.random(#quotes)]
            -- split long quotes into two centered lines at the space nearest the middle
            if #quote > 65 then
              local mid = math.floor(#quote / 2)
              local best, best_dist = nil, math.huge
              for i = 1, #quote do
                if quote:sub(i, i) == " " then
                  local dist = math.abs(i - mid)
                  -- avoid splitting too close to the ends
                  if dist < best_dist and i > 25 and i < #quote - 25 then
                    best, best_dist = i, dist
                  end
                end
              end
              if best then
                quote = quote:sub(1, best - 1) .. "\n" .. quote:sub(best + 1)
              end
            end
            return {
              align = "center",
              padding = 1,
              text = "\n\n\n\n" .. quote,
            }
          end,
        },
      },
    },
  },
}
