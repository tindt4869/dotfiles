vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.signcolumn = "yes"
vim.o.winborder = "rounded"
vim.o.pumborder = "rounded"
vim.o.lazyredraw = true
vim.o.cursorline = false

require("core.theme")
require("core.autocommands")
require("core.usercommands")
require("core.keymaps")
require("core.magic")

require("plugins.lsp")
require("plugins.fzf-lua")
require("plugins.conform")
require("plugins.treesitter")
require("plugins.mini")
require("plugins.cmp")
require("plugins.oil")
require("plugins.trouble")
require("plugins.gitsigns")
require("plugins.toggleterm")
-- require("plugins.better-quickfix")
require("plugins.bento")
require("plugins.ufo")
require("utils.packageutils")
vim.pack.add({
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})
require("render-markdown").setup({})
