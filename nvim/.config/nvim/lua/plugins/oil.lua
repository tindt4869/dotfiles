vim.pack.add({
	{ src = "https://github.com/stevearc/oil.nvim" },
})

vim.keymap.set("n", "<leader>-", require("oil").toggle_float)

require("oil").setup({
	columns = {
		"permissions",
		"icon",
	},
	view_options = {
		show_hidden = true
	}
})
