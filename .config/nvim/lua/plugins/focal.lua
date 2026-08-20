return {
  {
    "hmdfrds/focal.nvim",
    event = "VeryLazy",
    dependencies = { "3rd/image.nvim" },
    opts = {
      min_width = 10,
      min_height = 5,
      max_width_percent = 50,
      max_height_percent = 50,
      max_file_size_mb = 5,
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "FocalFloat", { default = true, bg = "#7c6f64", fg = "#111111" })

      local img = nil
      local tmpfile = nil
      local setup_done = false
      local function ensure_image_setup()
        if setup_done then
          return true
        end
        local ok, api = pcall(require, "image")
        if not ok then
          return false
        end
        if type(api.setup) == "function" then
          pcall(api.setup, {})
        end
        setup_done = true
        return true
      end
      local function clear()
        if img then
          pcall(img.clear, img)
          img = nil
        end
        if tmpfile then
          os.remove(tmpfile)
          tmpfile = nil
        end
      end

      require("focal").register_renderer({
        name = "svg (image.nvim)",
        extensions = { "svg", "svgz" },
        priority = 110,
        needs_terminal = false,
        is_available = function()
          return vim.fn.executable("magick") == 1
        end,
        get_geometry = function(_, _, env)
          return { width = env.max_width, height = env.max_height }
        end,
        render = function(ctx, done)
          local ok, api = pcall(require, "image")
          if not ok then
            done(false)
            return
          end
          if not ensure_image_setup() then
            done(false)
            return
          end
          tmpfile = vim.fn.tempname() .. ".png"
          vim.fn.system({ "magick", ctx.path, "-background", "none", "-density", "144", "-strip", tmpfile })
          if not vim.uv.fs_stat(tmpfile) then
            done(false)
            return
          end
          local i_ok, im = pcall(api.from_file, tmpfile, { id = tmpfile .. "-focal-svg" })
          if not i_ok then
            done(false)
            return
          end
          img = im
          img.buffer = ctx.buf
          img.window = ctx.win
          img.max_height_window_percentage = 100
          img.max_width_window_percentage = 100
          local r_ok, err = pcall(img.render, img, { x = 0, y = 0, width = ctx.geometry.width, height = ctx.geometry.height })
          if not r_ok then
            vim.notify("[focal] svg render failed: " .. tostring(err), vim.log.levels.DEBUG)
            done(false)
            return
          end
          if img.is_rendered then
            local fit = nil
            if img.rendered_geometry then
              local rw = img.rendered_geometry.width
              local rh = img.rendered_geometry.height
              if rw and rh and rw > 0 and rh > 0 then
                fit = { width = rw, height = rh }
              end
            end
            done(true, { fit = fit })
          else
            done(false)
          end
        end,
        clear = clear,
        cleanup = clear,
      })

      require("focal").setup(opts)
    end,
  },
}