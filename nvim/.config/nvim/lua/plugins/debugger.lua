vim.pack.add {
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
}

local dap = require "dap"
local dapui = require "dapui"

dapui.setup()
require("nvim-dap-virtual-text").setup()

dap.adapters.python = {
    type = "executable",
    command = "python",
    args = { "-m", "debugpy.adapter" },
}

dap.configurations.python = {
    {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            local venv = cwd .. "/venv/bin/python"
            if vim.fn.executable(venv) == 1 then
                return venv
            end
            return "python"
        end,
    },
    {
        type = "python",
        request = "launch",
        name = "Run current script with args",
        program = "${file}",
        args = function()
            local args_str = vim.fn.input "Arguments: "
            return vim.split(args_str, "%s+", { trimempty = true })
        end,
        pythonPath = function()
            local cwd = vim.fn.getcwd()
            local venv = cwd .. "/venv/bin/python"
            if vim.fn.executable(venv) == 1 then
                return venv
            end
            return "python"
        end,
    },
}

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP Continue" })
vim.keymap.set("n", "<leader>dso", dap.step_over, { desc = "DAP Step Over" })
vim.keymap.set("n", "<leader>dsi", dap.step_into, { desc = "DAP Step Into" })
vim.keymap.set("n", "<leader>dout", dap.step_out, { desc = "DAP Step Out" })
vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "DAP Terminate" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "DAP Toggle UI" })
