return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    opts = {},
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup {
        dark_variant = "moon",
        disable_italics = false,
        styles = {
          bold = true,
          italic = false,
          transparency = true,
        },
      }
      -- vim.cmd.colorscheme "rose-pine"
    end,
  },
  {
    "dgox16/oldworld.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme "oldworld"
    end,
  },
  {
    "kvrohit/substrata.nvim",
    config = function()
      -- vim.opt.background = "light"
      -- vim.opt.termguicolors = true
      -- vim.cmd.colorscheme "substrata"
    end,
  },
  {
    "rjshkhr/shadow.nvim",
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme "shadow"
    end,
  },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup {
        transparent = true,
        italic_comments = true,
        hide_fillchars = false,
        borderless_telescope = false,
        terminal_colors = true,
        theme = {
          variant = "auto",
        },
        extensions = {
          telescope = true,
          mini = true,
        },
      }

      vim.cmd.colorscheme "cyberdream"
    end,
  },
  {
    "mawkler/modicator.nvim",
    dependencies = "scottmckendry/cyberdream.nvim",
    init = function()
      -- These are required for Modicator to work
      vim.o.cursorline = false
      vim.o.number = true
      vim.o.termguicolors = true
    end,
    opts = {
      show_warning = true,
    },
  },
}
