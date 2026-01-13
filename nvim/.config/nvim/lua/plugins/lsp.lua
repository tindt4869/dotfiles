vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/williamboman/mason.nvim" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/b0o/SchemaStore.nvim" },
})

require("mason").setup()
require("fidget").setup()

local servers = { "clangd", "lua_ls", "pyright", "gopls", "vtsls", "jsonls", "yamlls" }

local config = {
	jsonls = {
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	},
	yamlls = {
		settings = {
			yaml = {
				schemaStore = { enable = false, url = "" },
				schemas = require("schemastore").yaml.schemas(),
			},
		},
	},
	clangd = {
		init_options = { clangdFileStatus = true },
		filetypes = { "c", "cpp" },
		format = { enable = true },
	},
	gopls = {
		settings = {
			gopls = {
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
			},
		},
	},
	pylsp = {
		settings = {
			pylsp = {
				plugins = {
					pyflakes = { enabled = false },
					pycodestyle = { enabled = false },
					autopep8 = { enabled = false },
					yapf = { enabled = false },
					mccabe = { enabled = false },
					pylsp_mypy = { enabled = false },
					pylsp_black = { enabled = false },
					pylsp_isort = { enabled = false },
				},
			},
		},
	},
}

for _, server in ipairs(servers) do
	vim.lsp.enable(server)

	local conf = config[server]

	if conf then
		vim.lsp.config(server, conf)
	end
end

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
