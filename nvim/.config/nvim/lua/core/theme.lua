local hooks = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind

    print(name)

    -- Run build script after plugin's code has changed
    if name == "suannhai.nvim" and (kind == "install" or kind == "update") then
        vim.system({ "python3", "scripts/sync-palettes.py" }, { cwd = ev.data.path }):wait()
    end
end

vim.api.nvim_create_autocmd("PackChanged", { callback = hooks })

vim.pack.add {
    -- { src = "https://github.com/rose-pine/neovim" },
    --{ src = "https://github.com/serhez/teide.nvim" },
    { src = "https://github.com/tindt4869/nvim-moegi.git" },
    { src = "https://github.com/WeiTing1991/suannhai.nvim" },
}

-- require("rose-pine").setup {
--     styles = {
--         italic = false,
--         transparency = true,
--     },
-- }

-- vim.cmd.colorscheme "rose-pine"
-- vim.cmd.colorscheme("teide-light")

-- require("moegi").setup {
--     variant = "space",
--     transparent = false,
--     dim_inactive = false,
--     styles = {
--         comments = { italic = false },
--     },
--     plugins = true,
-- }
-- vim.cmd.colorscheme "moegi"

require("suannhai").setup {
    transparent = false,
    on_colors = function(color) end,
    on_highlights = function(hl, colors) end,
    plugins = {
        all = true,
        auto = true,
    },
}
-- vim.cmd.colorscheme "suannhai-shironeri"
vim.cmd.colorscheme "suannhai-lam-ni"
