-- Native session management (Nvim 0.12), replaces auto-session.nvim.
-- Auto-restores on bare `nvim` start, auto-saves on exit.
-- Bonus: since loading sets v:this_session, `ZR` / `:restart` restore it too.

local dir = vim.fn.stdpath "data" .. "/sessions"
vim.fn.mkdir(dir, "p")

local home = vim.fs.normalize(vim.env.HOME)
local suppressed_dirs = {
    [home] = true,
    [home .. "/Downloads"] = true,
    ["/"] = true,
}

local function session_path(name)
    name = name or (vim.fn.getcwd():gsub("/", "%%"))
    return ("%s/%s.vim"):format(dir, name)
end

local function session_names()
    local names = {}
    for _, file in ipairs(vim.fn.readdir(dir)) do
        local base = file:match "^(.*)%.vim$"
        if base then
            names[#names + 1] = base
        end
    end
    return names
end

local function save_session(name)
    local path = session_path(name)
    vim.cmd("mksession! " .. vim.fn.fnameescape(path))
    return path
end

local function load_session(path)
    vim.cmd("source " .. vim.fn.fnameescape(path))
    -- Drop leftover unnamed empty buffers from before the load
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
            buf ~= vim.api.nvim_get_current_buf()
            and vim.api.nvim_buf_is_valid(buf)
            and vim.api.nvim_buf_get_name(buf) == ""
            and vim.bo[buf].buftype == ""
            and not vim.bo[buf].modified
        then
            vim.api.nvim_buf_delete(buf, {})
        end
    end
end

local group = vim.api.nvim_create_augroup("native-sessions", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    nested = true,
    desc = "Restore session when started without file arguments",
    callback = function()
        if vim.fn.argc() > 0 or suppressed_dirs[vim.fn.getcwd()] then
            return
        end
        local path = session_path()
        if not vim.uv.fs_stat(path) then
            return
        end
        local ok, err = pcall(load_session, path)
        if not ok then
            vim.notify("Failed to restore session: " .. err, vim.log.levels.WARN)
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    desc = "Save session for the current working directory",
    callback = function()
        if suppressed_dirs[vim.fn.getcwd()] then
            return
        end
        save_session()
    end,
})

local name_opts = {
    nargs = "?",
    complete = function()
        return session_names()
    end,
}

vim.api.nvim_create_user_command("SessionSave", function(opts)
    vim.notify("Saved session " .. save_session(opts.args ~= "" and opts.args or nil))
end, { nargs = "?", desc = "Save session (default: cwd)" })

vim.api.nvim_create_user_command("SessionLoad", function(opts)
    local path = session_path(opts.args ~= "" and opts.args or nil)
    if not vim.uv.fs_stat(path) then
        vim.notify("No such session: " .. path, vim.log.levels.WARN)
        return
    end
    load_session(path)
end, name_opts)

vim.api.nvim_create_user_command("SessionDelete", function(opts)
    local path = session_path(opts.args ~= "" and opts.args or nil)
    if not vim.uv.fs_stat(path) then
        vim.notify("No such session: " .. path, vim.log.levels.WARN)
        return
    end
    os.remove(path)
    vim.notify("Deleted session " .. path)
end, name_opts)

local fzf = require "fzf-lua"

vim.keymap.set("n", "<leader>fs", function()
    -- Display paths decoded (% -> /); encode back on selection
    local entries = vim.iter(session_names())
        :map(function(name)
            return (name:gsub("%%", "/"))
        end)
        :totable()
    fzf.fzf_exec(entries, {
        prompt = "Sessions> ",
        actions = {
            ["default"] = function(selected)
                load_session(session_path((selected[1]:gsub("/", "%%"))))
            end,
        },
    })
end, { desc = "Fzf Sessions" })
