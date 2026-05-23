vim.pack.add { { src = "https://github.com/akinsho/toggleterm.nvim" } }

require("toggleterm").setup {
    open_mapping = [[<c-\>]],
    direction = "float",
    float_opts = {
        border = "rounded",
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.8),
    },
}

local Terminal = require("toggleterm.terminal").Terminal

local cpp_term = nil

local function run_cpp()
    if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
        vim.notify("Not a C/C++ file", vim.log.levels.WARN)
        return
    end
    vim.cmd "silent! write"
    local filepath = vim.fn.expand "%:p"
    local filename = vim.fn.expand "%:t:r"
    local pid = vim.fn.getpid()
    local tmpbin = string.format("/tmp/nvim_cpp_%s_%d", filename, pid)
    local script = string.format("/tmp/nvim_cpp_run_%d.sh", pid)
    local f = io.open(script, "w")
    if not f then
        vim.notify("Failed to create temp script", vim.log.levels.ERROR)
        return
    end
    local filename_ext = vim.fn.expand "%:t"
    f:write(table.concat({
        "#!/bin/bash",
        string.format('trap \'rm -f "%s" "%s"\' EXIT', script, tmpbin),
        string.format(
            "printf '\\n\\033[1;36m▶\\033[0m \\033[1;37m%s\\033[0m \\033[90m── \\033[2m%%s\\033[0m\\n\\n' \"$(date +%%T)\"",
            filename_ext
        ),
        "printf '\\033[33m● Compiling...\\033[0m'",
        string.format('compile_out=$(g++ -std=c++17 "%s" -o "%s" 2>&1)', filepath, tmpbin),
        "compile_exit=$?",
        "if [ $compile_exit -eq 0 ]; then",
        " printf '\\r\\033[32m✓ Compiled \\033[0m\\n\\n'",
        " printf '\\033[36m▸\\033[0m \\033[90moutput\\033[0m\\n\\n'",
        string.format(' "%s"', tmpbin),
        " run_exit=$?",
        " if [ $run_exit -eq 0 ]; then",
        " printf '\\n\\033[32m✓ exited %d\\033[0m\\n\\n' \"$run_exit\"",
        " else",
        " printf '\\n\\033[31m✗ exited %d\\033[0m\\n\\n' \"$run_exit\"",
        " fi",
        "else",
        " printf '\\r\\033[31m✗ Build failed \\033[0m\\n\\n'",
        " printf '%s\\n' \"$compile_out\"",
        " printf '\\n'",
        "fi",
    }, "\n") .. "\n")
    f:close()
    if cpp_term == nil then
        cpp_term = Terminal:new { direction = "float", close_on_exit = false }
    end
    if not cpp_term:is_open() then
        cpp_term:open()
    end
    cpp_term:send("bash " .. script)
end
vim.keymap.set("n", "<leader>cr", run_cpp, { desc = "C++: Compile and run" })
