vim.pack.add {
    { src = "https://github.com/serhez/bento.nvim" },
}

require("bento").setup {
    max_open_buffers = 5,
    ui = {
        mode = "floating",
        floating = {
            position = "middle-right",
            offset_x = 0,
            offset_y = 0,
            dash_char = "─",
            label_padding = 1,
            minimal_menu = "full", -- nil | "dashed" | "filename" | "full"
            max_rendered_buffers = 5,
        },
        tabline = {
            left_page_symbol = "❮", -- Symbol shown when previous buffers exist
            right_page_symbol = "❯", -- Symbol shown when more buffers exist
            separator_symbol = "│", -- Separator between buffer components
        },
    },
    highlights = {
        current = "Bold", -- Current buffer filename (in last editor window)
        active = "Normal", -- Active buffers visible in other windows
        inactive = "Comment", -- Inactive/hidden buffer filenames
        modified = "DiagnosticWarn", -- Modified/unsaved buffer filenames and dashes
        inactive_dash = "Comment", -- Inactive buffer dashes in collapsed state
        previous = "Search", -- Label for previous buffer (main_keymap label)
        label_open = "DiagnosticVirtualTextHint", -- Labels in open action mode
        label_delete = "DiagnosticVirtualTextError", -- Labels in delete action mode
        label_vsplit = "DiagnosticVirtualTextInfo", -- Labels in vertical split mode
        label_split = "DiagnosticVirtualTextInfo", -- Labels in horizontal split mode
        label_lock = "DiagnosticVirtualTextWarn", -- Labels in lock action mode
        label_minimal = "Visual", -- Labels in collapsed "full" mode
        window_bg = "BentoNormal", -- Menu window background
        page_indicator = "Comment", -- Pagination indicators (● ○ ○ for floating, ❮/❯ for tabline)
        separator = "Normal", -- Separator between buffer components in tabline
    },
}
