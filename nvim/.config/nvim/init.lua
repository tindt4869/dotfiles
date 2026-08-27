vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.o.pumborder = "rounded"
vim.o.cursorline = false
vim.o.timeoutlen = 1000

require "core.autocommands"
require "core.usercommands"
require "core.keymaps"
require "core.magic"
require "core.theme"

require "plugins.lsp"
require "plugins.fzf-lua"
require "plugins.conform"
require "plugins.treesitter"
require "plugins.mini"
require "plugins.cmp"
require "plugins.oil"
require "plugins.trouble"
require "plugins.gitsigns"
require "plugins.toggleterm"
-- require("plugins.better-quickfix")
-- require "plugins.bento"
require "plugins.ufo"
require "plugins.sessions"
require "plugins.indent"
require "utils.packageutils"
vim.pack.add {
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
}
require("render-markdown").setup {}

require "plugins.competi-test"
require "plugins.debugger"
