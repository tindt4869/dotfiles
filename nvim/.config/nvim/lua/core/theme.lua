vim.pack.add {
    { src = "https://github.com/rose-pine/neovim" },
    --{ src = "https://github.com/serhez/teide.nvim" },
}

require("rose-pine").setup {
    styles = {
        italic = false,
        transparency = true,
    },
}

vim.cmd.colorscheme "rose-pine"
-- vim.cmd.colorscheme("teide-light")
