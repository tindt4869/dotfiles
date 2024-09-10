return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd.colorscheme "tokyonight-night"
    end,
  },
  { "rose-pine/neovim", name = "rose-pine" },
  {
    "maxmx03/fluoromachine.nvim",
    -- config = function()
    --   local fm = require "fluoromachine"
    --   fm.setup { glow = true, theme = "fluoromachine" }
    -- end,
  },
}
