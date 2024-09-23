local set = vim.keymap.set
local k = vim.keycode
local opts = { noremap = true, silent = true }

-- Disable the spacebar key's default behavior in Normal and Visual modes
set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Basic movement keybinds, these make navigating splits easy for me
set("n", "<c-j>", "<c-w><c-j>")
set("n", "<c-k>", "<c-w><c-k>")
set("n", "<c-l>", "<c-w><c-l>")
set("n", "<c-h>", "<c-w><c-h>")

-- set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
-- set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- delete single character without copying into register
set("n", "x", '"_x', opts)

-- keep last yanked when pasting
set("v", "p", '"_dP', opts)

-- Toggle hlsearch if it's on, otherwise just do "enter"
set("n", "<CR>", function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.v.hlsearch == 1 then
    vim.cmd.nohl()
    return ""
  else
    return k "<CR>"
  end
end, { expr = true })

set("n", "<Esc>", function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.v.hlsearch == 1 then
    vim.cmd.nohl()
    return ""
  else
    return k "<CR>"
  end
end, { expr = true })

-- Normally these are not good mappings, but I have left/right on my thumb
-- cluster, so navigating tabs is quite easy this way.
set("n", "<left>", "gT")
set("n", "<right>", "gt")

-- There are builtin keymaps for this now, but I like that it shows
-- the float when I navigate to the error - so I override them.
set("n", "]d", vim.diagnostic.goto_next)
set("n", "[d", vim.diagnostic.goto_prev)

-- These mappings control the size of splits (height/width)
set("n", "<M-,>", "<c-w>5<")
set("n", "<M-.>", "<c-w>5>")
set("n", "<M-t>", "<C-W>+")
set("n", "<M-s>", "<C-W>-")

-- Move line up/down
set("n", "<M-j>", function()
  if vim.opt.diff:get() then
    vim.cmd [[normal! ]c]]
  else
    vim.cmd [[m .+1<CR>==]]
  end
end)
set("n", "<M-k>", function()
  if vim.opt.diff:get() then
    vim.cmd [[normal! [c]]
  else
    vim.cmd [[m .-2<CR>==]]
  end
end)

-- Toggle inline hint
set("n", "<space>tt", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { desc = "Toggle inline hint" })

-- Toggle diagnostics
set("n", "<leader>tdv", "<cmd>DiagnosticsToggleVirtualText<CR>", { desc = "Toggle diagnostics virtual text" })
set("n", "<leader>td", "<cmd>DiagnosticsToggle<CR>", { desc = "Toggle diagnostics" })

-- Toggle comment
set("n", "<space>/", ":normal gcc<CR><DOWN>", { desc = "Toggle comment line" })
-- <Esc> - exists visual mode.
-- :normal executes keystrokes in normal mode.
-- gv - restores selection.
-- gc - toggles comment
-- <CR> sends the command
set("v", "<space>/", "<Esc>:normal gvgc<CR>", { desc = "Toggle comment block" })

-- Buffers
set("n", "<Tab>", ":bnext<CR>", opts)
set("n", "<S-Tab>", ":bprevious<CR>", opts)
set("n", "<leader>c", ":bdelete<CR>", opts) -- close buffer
set("n", "<leader>b", "<cmd> enew <CR>", opts) -- new buffer

-- Toggle line wrapping
set("n", "<leader>lw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrapping" })
