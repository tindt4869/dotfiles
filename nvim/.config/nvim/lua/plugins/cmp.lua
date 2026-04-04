vim.pack.add {
    { src = "https://github.com/L3MON4D3/LuaSnip" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/saghen/blink.cmp" },
}

require("luasnip.loaders.from_snipmate").lazy_load { paths = { "~/.config/nvim/snippets" } }
require("luasnip.loaders.from_vscode").lazy_load()

require("blink.cmp").setup {
    fuzzy = { implementation = "prefer_rust" },
    keymap = { preset = "super-tab" },
    appearance = {
        nerd_font_variant = "normal",
    },
    -- signature = { enabled = true },
    snippets = { preset = "luasnip" },
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
    },
    -- completion = {
    -- 	documentation = {
    -- 		auto_show          = true,
    -- 		auto_show_delay_ms = 2000,
    -- 	}
    -- }
}
