return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- lualine_z:  + wakatime hh:mm (async, non-blocking)
    local waka = "  0:00"
    local cli = vim.fn.exepath("wakatime-cli")
    if cli == "" then
      cli = "/opt/homebrew/bin/wakatime-cli"
    end
    local function fetch_waka(cb)
      -- use wakatime's cached statusline (non-blocking, already updated every 60s by vim-wakatime)
      local s = ""
      pcall(function()
        s = require("wakatime").statusline()
      end)
      if s and s ~= "" then
        local h = tonumber(s:match("(%d+)%s*hr")) or 0
        local m = tonumber(s:match("(%d+)%s*min")) or 0
        if h > 0 or m > 0 then
          cb(string.format("  %d:%02d", h, m))
          return
        end
        -- fallback: if statusline is text like "2 hrs 14 mins", already handled; if it's "0 secs", show 0:00
        local ok, data = pcall(vim.json.decode, "")
        _ = ok
        _ = data
      end
      -- fallback to direct wakatime-cli if statusline empty (e.g., first run)
      vim.system({ cli, "--today", "--output", "raw-json" }, { text = true }, function(r)
        if r.code == 0 and r.stdout and r.stdout ~= "" then
          local ok, data = pcall(vim.json.decode, r.stdout)
          local d = ok and data and data.data and data.data.grand_total and data.data.grand_total.digital
          if d and d ~= "" then
            cb(" " .. d)
            return
          end
        end
        cb(nil)
      end)
    end
    -- async initial fetch (no block) — wakatime statusline is instant after VeryLazy
    vim.defer_fn(function()
      fetch_waka(function(val)
        if val then
          waka = val
          vim.schedule(function()
            pcall(vim.cmd, "redrawstatus")
          end)
        end
      end)
    end, 800)
    local uv = vim.uv or vim.loop
    local t = uv.new_timer()
    if t then
      t:start(60000, 60000, function()
        fetch_waka(function(val)
          if val and val ~= waka then
            waka = val
            vim.schedule(function()
              vim.cmd("redrawstatus")
            end)
          end
        end)
      end)
    end
    opts.sections.lualine_z = {
      function()
        return waka
      end,
    }

    -- defensive: ensure OG wakatime never reappears (already disabled via ~/.wakatime.cfg)
    local function strip_waka()
      if opts.sections.lualine_x then
        opts.sections.lualine_x = vim.tbl_filter(function(c)
          return not (type(c) == "table" and c.__wakatime_statusline)
        end, opts.sections.lualine_x)
      end
      local ok, ll = pcall(require, "lualine")
      if ok and ll.get_config then
        local cfg = ll.get_config()
        if cfg and cfg.sections and cfg.sections.lualine_x then
          local filtered = vim.tbl_filter(function(c)
            return not (type(c) == "table" and c.__wakatime_statusline)
          end, cfg.sections.lualine_x)
          if #filtered ~= #cfg.sections.lualine_x then
            cfg.sections.lualine_x = filtered
            pcall(function()
              require("lualine").setup(cfg)
            end)
          end
        end
      end
    end
    strip_waka()
    vim.defer_fn(strip_waka, 1500)
    vim.defer_fn(strip_waka, 3500)

    -- lualine_c: diagnostics, filetype icon, filename (no ext), then :cmd / search inline
    opts.sections.lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      {
        "filename",
        symbols = { modified = "", readonly = "", unnamed = "" },
        fmt = function(str)
          return (str:gsub("%.[^%.%s]+$", ""))
        end,
      },
      { "diagnostics" },
    }

    return opts
  end,
}
