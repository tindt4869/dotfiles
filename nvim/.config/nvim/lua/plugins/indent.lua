vim.pack.add {
    { src = "https://github.com/folke/snacks.nvim" },
}

require("snacks").setup {
    -- hahah
    ---@class snacks.indent.Config
    ---@field enabled? boolean
    indent = {
        indent = {
            enabled = false,
            char = "▏",
            only_scope = false,
            only_current = false,
            hl = "FloatBorder",
        },
        chunk = {
            enabled = true,
            only_scope = true,
            only_current = false,
            hl = "IblScope",
            char = {
                -- corner_top = "┌",
                -- corner_bottom = "└",
                corner_top = "╭",
                corner_bottom = "╰",
                horizontal = "─",
                vertical = "│",
                arrow = "",
            },
        },
    },
}
