vim.pack.add {
    { src = "http://github.com/stevearc/conform.nvim" },
}

local function js_formatter(bufnr)
    if require("conform").get_formatter_info("biome", bufnr).available then
        return { "biome" }
    else
        return { "prettierd", "prettier", stop_after_first = true }
    end
end

require("conform").setup {
    formatters_by_ft = {
        lua = { "stylua" },
        svelte = js_formatter,
        astro = js_formatter,
        javascript = js_formatter,
        typescript = js_formatter,
        javascriptreact = js_formatter,
        typescriptreact = js_formatter,
        css = js_formatter,
        scss = js_formatter,
        json = {},
        graphql = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        erb = { "htmlbeautifier" },
        html = { "htmlbeautifier" },
        bash = { "beautysh" },
        proto = { "buf" },
        rust = { "rustfmt" },
        yaml = { "yamlfix" },
        toml = { "taplo" },
        sh = { "shellcheck" },
        go = { "gofmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        python = { "black" },
    },
    format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
    end,
}
