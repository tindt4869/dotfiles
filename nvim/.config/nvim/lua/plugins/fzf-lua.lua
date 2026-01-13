vim.pack.add({
	{ src = "https://github.com/ibhagwan/fzf-lua" },
})

local fzf = require("fzf-lua")

---@diagnostic disable-next-line: unused-local
local ui_modern_float = {
	height = 0.85, -- 85% of screen height
	width = 0.80, -- 80% of screen width
	row = 0.35, -- vertical position
	col = 0.50, -- horizontal position
	border = "rounded", -- options: 'single', 'double', 'rounded', 'thick'
	preview = {
		layout = "vertical", -- 'vertical' puts preview on top, 'horizontal' on right
		vertical = "down:50%", -- preview takes 45% of the bottom space
	},
}

local ui_slim_dropdown = {
	split = "belowright new", -- opens in a split if you prefer, OR:
	height = 0.40, -- shorter window
	width = 1.00, -- full width
	row = 0, -- top of the screen
	col = 0,
	border = { " ", " ", " ", " ", " ", " ", " ", " " }, -- borderless look
	preview = { layout = "horizontal", horizontal = "right:50%" },
}

fzf.setup({
	fzf_opts = { ["--layout"] = "reverse" },
	fzf_colors = {
		["fg"] = { "fg", "CursorLine" },
		["bg"] = { "bg", "Normal" },
		["hl"] = { "fg", "TelescopeMatching" }, -- Match color
		["info"] = { "fg", "Conditional" },
		["prompt"] = { "fg", "Function" },
		["pointer"] = { "fg", "Exception" },
		["marker"] = { "fg", "Keyword" },
		["spinner"] = { "fg", "Label" },
		["header"] = { "fg", "Comment" },
		["gutter"] = { "bg", "Normal" },
	},
	files = {
		-- --hidden: find dotfiles
		-- --exclude: .git: don't index the git folder itself
		fd_opts = "--type f --hidden --exclude .git",
	},
	grep = {
		-- --hidden: search inside dotfiles
		-- --smart-case: case insensitive unless you use a capital letter
		rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -e",
		cwd = vim.fn.getcwd(),
	},
	lsp = {
		code_actions = {
			previewer = false,
		},
	},
	winopts = ui_slim_dropdown,
})

vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Fzf Files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Fzf Live Grep" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "Fzf Word under cursor" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Fzf Buffers" })
vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Fzf Help" })
vim.keymap.set("n", "<leader>fz", fzf.grep_curbuf, { desc = "Fzf Current Buffer" })
vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "Fzf Resume last search" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "Fzf Keymaps" })

-- Keymap to search ONLY hidden files
vim.keymap.set("n", "<leader>f.", function()
	fzf.files({
		-- We use fd to find only files starting with a dot
		-- '^\.' is a regex for "starts with a dot"
		fd_opts = "--type f --hidden --no-ignore --glob '.*'",
		prompt = "Hidden Files> ",
	})
end, { desc = "Fzf Hidden Files" })

-- Git
-- Search only changed files (staged or unstaged)
vim.keymap.set("n", "<leader>gs", fzf.git_status, { desc = "Git Status" })
-- Search through the git commit history
vim.keymap.set("n", "<leader>gc", fzf.git_commits, { desc = "Git Commits" })

-- LSP
-- Go to definitions
fzf.register_ui_select()
vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "LSP Definitions" })
-- Show all references to a function/variable
vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "LSP References" })
-- Show code actions (fix errors, etc)
vim.keymap.set("n", "<leader>ca", fzf.lsp_code_actions, { desc = "LSP Code Actions" })
