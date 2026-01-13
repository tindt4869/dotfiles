vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then
			return
		end

		-- if client:supports_method('textDocument/completion') then
		-- 	vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		-- end
		if client:supports_method("textDocument/formatting") then
			-- Format current buffer on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					require("conform").format({ bufnr = args.buf, id = client.id })
				end,
			})
		end

		local opts = { buffer = args.buf }
		-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		-- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		-- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})

vim.cmd("set completeopt+=noselect")
