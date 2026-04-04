vim.opt_local.shiftwidth = 4

-- local function get_workspace_libs()
-- 	local libs = vim.api.nvim_get_runtime_file("", true)
--
-- 	table.insert(libs, vim.fn.expand("$VIMRUNTIME/lua"))
-- 	table.insert(libs, vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"))
-- 	table.insert(libs, vim.fn.stdpath("config"))
-- 	table.insert(libs, vim.fn.stdpath("config") .. "/lua")
--
-- 	return libs
-- end

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            workspace = {
                -- library = get_workspace_libs(),
                checkThirdParty = false, -- Prevents annoying "Do you want to configure your workspace" popups
            },
            diagnostics = {
                globals = { "vim", "use", "M" },
            },
            runtime = {
                version = "LuaJIT",
                -- path = (function()
                -- 	local p = vim.split(package.path, ";")
                -- 	table.insert(p, "lua/?.lua")
                -- 	table.insert(p, "lua/?/init.lua")
                -- 	return p
                -- end)()
            },
            hint = { enable = true },
        },
    },
})
