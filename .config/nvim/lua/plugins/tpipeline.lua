return {
  {
    "vimpostor/vim-tpipeline",
    init = function()
      vim.opt.termguicolors = true

      if vim.env.TMUX then
        vim.opt.laststatus = 0
        vim.opt.showmode = false
        vim.opt.showtabline = 0
      end
    end,
  },
}
