return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require "conform"
    conform.setup {
      formatters_by_ft = {
        lua = { "stylua" },
        svelte = { { "prettierd", "prettier", stop_after_first = true } },
        astro = { { "prettierd", "prettier", stop_after_first = true } },
        javascript = { { "prettierd", "prettier", stop_after_first = true } },
        typescript = { { "prettierd", "prettier", stop_after_first = true } },
        javascriptreact = { { "prettierd", "prettier", stop_after_first = true } },
        typescriptreact = { { "prettierd", "prettier", stop_after_first = true } },
        json = { { "prettierd", "prettier", stop_after_first = true } },
        graphql = { { "prettierd", "prettier", stop_after_first = true } },
        markdown = { { "prettierd", "prettier", stop_after_first = true } },
        erb = { "htmlbeautifier" },
        html = { "htmlbeautifier" },
        bash = { "beautysh" },
        proto = { "buf" },
        rust = { "rustfmt" },
        yaml = { "yamlfix" },
        toml = { "taplo" },
        css = { { "prettierd", "prettier", stop_after_first = true } },
        scss = { { "prettierd", "prettier", stop_after_first = true } },
        sh = { "shellcheck" },
        go = { "gofmt" },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
    }

    vim.keymap.set({ "n", "v" }, "<leader>l", function()
      conform.format {
        lsp_callback = true,
        async = true,
        timeout_ms = 1000,
      }
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
