vim.pack.add {
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/xeluxee/competitest.nvim" },
}

vim.api.nvim_create_user_command("CompetiTest", function()
    require("competitest").setup {
        start_receiving_persistently_on_setup = true,
    }
end, { desc = "Load and start competitest" })
