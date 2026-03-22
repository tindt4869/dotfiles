-- Basic movement keybinds, these make navigating splits easy for me
vim.keymap.set("n", "<c-j>", "<c-w><c-j>")
vim.keymap.set("n", "<c-k>", "<c-w><c-k>")
vim.keymap.set("n", "<c-l>", "<c-w><c-l>")
vim.keymap.set("n", "<c-h>", "<c-w><c-h>")
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "LSP: Open float diagnostic" })

-- There are builtin keymaps for this now, but I like that it shows
-- the float when I navigate to the error - so I override them.
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump { count = 1, float = true }
end)
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump { count = -1, float = true }
end)

-- Sync yank and delete to system clipboard
-- vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
-- vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<CR>')

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-- Toggle hlsearch if it's on, otherwise just do "enter"
vim.keymap.set("n", "<CR>", function()
    if vim.v.hlsearch == 1 then
        vim.cmd.nohlsearch()
        return ""
    else
        return "<CR>"
    end
end, { expr = true })

vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")

-- C++: compile and run in a floating terminal
vim.keymap.set("n", "<leader>r", function()
    local file = vim.fn.expand "%"
    local output = vim.fn.expand "%:r"
    local compile_cmd = string.format("g++ -O3 %s -o %s", file, output)
    local run_cmd = string.format("%s", output)

    -- Using toggleterm.nvim for a clean popup terminal
    vim.cmd(string.format("TermExec cmd='%s && %s'", compile_cmd, run_cmd))
end, { desc = "CP: Compile and Run" })
