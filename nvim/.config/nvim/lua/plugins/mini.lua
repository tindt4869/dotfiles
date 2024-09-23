return {
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.ai").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.move").setup()
      require("mini.indentscope").setup {
        symbol = "▏",
      }
    end,
  },
}
