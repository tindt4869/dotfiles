vim.pack.add {
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/xeluxee/competitest.nvim" },
    -- { src = "https://github.com/A7lavinraj/assistant.nvim" },
}

require("competitest").setup {
    start_receiving_persistently_on_setup = true,
}

-- require("assistant").setup()
