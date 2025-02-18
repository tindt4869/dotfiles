return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { "rose-pine/neovim", name = "rose-pine" },
  {
    "dgox16/oldworld.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "oldworld"
    end,
  },
  {
    "kvrohit/substrata.nvim",
    config = function()
      -- vim.cmd.colorscheme "substrata"
    end,
  },
  {
    "rjshkhr/shadow.nvim",
    priority = 1000,
    config = function()
      vim.opt.termguicolors = true
      -- vim.cmd.colorscheme "shadow"
    end,
  },
}
