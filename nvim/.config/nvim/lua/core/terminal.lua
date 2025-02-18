local set = vim.opt_local

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", {}),
  callback = function()
    set.number = false
    set.relativenumber = false
    set.scrolloff = 0

    vim.bo.filetype = "terminal"
    vim.cmd ":startinsert"
  end,
})

-- Easily hit escape in terminal mode.
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- Open a terminal at the bottom of the screen with a fixed height.
local openBototmTerm = function(cmd)
  vim.cmd.new()
  vim.cmd.wincmd "J"
  vim.api.nvim_win_set_height(0, 12)
  vim.wo.winfixheight = true
  vim.cmd.term()

  if cmd ~= nil then
    vim.cmd("term " .. cmd)
  else
    vim.cmd.term()
  end
end

vim.keymap.set("n", ",st", function()
  openBototmTerm()
end)

vim.keymap.set("n", ",sa", function()
  local filedir = vim.fn.expand "%:p:h"
  local filename = vim.fn.expand "%:t:r"
  vim.cmd.new()
  vim.cmd.wincmd "J"
  vim.api.nvim_win_set_height(0, 12)
  local cmd = "cd " .. filedir .. " && g++ " .. filename .. ".cpp -o " .. filename .. " && ./" .. filename
  vim.cmd("term " .. cmd)
  -- vim.api.nvim_feedkeys("i", "n", false)
end)

vim.keymap.set("n", ",ss", function()
  local filedir = vim.fn.expand "%:p:h"
  local filename = vim.fn.expand "%:t:r"

  vim.cmd.new()
  vim.cmd.wincmd "J"
  vim.api.nvim_win_set_height(0, 12)

  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local job_id = vim.fn.termopen(vim.o.shell, {
    on_exit = function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end,
  })

  vim.api.nvim_win_set_buf(win, buf)

  local cmd = "cd " .. filedir .. " && g++ " .. filename .. ".cpp -o " .. filename .. " && ./" .. filename
  -- local cmd = "g++ ./main.cpp -o main && ./main"

  -- Send the command to the terminal
  vim.defer_fn(function()
    vim.api.nvim_chan_send(job_id, cmd .. "\n")
  end, 150) -- delay to ensure terminal is ready
end)
