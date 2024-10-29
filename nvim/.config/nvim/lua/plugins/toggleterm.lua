return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    local toggleterm = require "toggleterm"

    toggleterm.setup {
      open_mapping = [[<c-\>]],
      hide_number = true,
      start_in_insert = true,
      direction = "float",
    }
    -- function _G.set_terminal_keymaps()
    --   local opts = { buffer = 0 }
    --   vim.keymap.set("t", "C-o", [[<C-\><C-n>]], opts)
    -- end
    --   vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    -- require("toggleterm").setup{}
  end,
}
