local opt = vim.opt

-- Save undo history
opt.undofile = true

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.smartcase = true
opt.ignorecase = true

----- Personal Preferences -----
opt.number = true
opt.relativenumber = true

opt.splitbelow = true
opt.splitright = true

-- Keep signcolumn on by default
opt.signcolumn = "yes"

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- ???
opt.shada = { "'10", "<0", "s10", "h" }

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

-- Don't have `o` add a comment
opt.formatoptions:remove "o"
