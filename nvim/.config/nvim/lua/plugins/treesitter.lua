vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local status, ts = pcall(require, "nvim-treesitter.config")
if not status then
	print("Treesitter not found!")
	return
end

ts.setup({
	ensure_install = {
		"lua",
		"python",
		"javascript",
		"typescript",
		"vimdoc",
		"vim",
		"regex",
		"sql",
		"dockerfile",
		"json",
		"toml",
		"yaml",
		"go",
		"gitignore",
		"make",
		"cmake",
		"markdown",
		"markdown_inline",
		"bash",
		"tsx",
		"css",
		"html",
	},
	-- Autoinstall languages that are not installed
	auto_install = false,
	highlight = {
		enable = true,
		-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
		--   If you are experiencing weird indenting issues, add the language to
		--   the list of additional_vim_regex_highlighting and disabled languages for indent.
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = false, disable = { "ruby " } },
})
