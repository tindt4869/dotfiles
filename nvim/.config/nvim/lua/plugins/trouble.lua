vim.pack.add({
	{ src = "https://github.com/folke/trouble.nvim" },
})

vim.keymap.set("n", "<leader>q", ":Trouble diagnostics toggle<CR>")

require("trouble").setup({})
