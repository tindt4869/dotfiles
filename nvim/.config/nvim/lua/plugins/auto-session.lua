vim.pack.add {
    { src = "https://github.com/rmagatti/auto-session" },
}

require("auto-session").setup {
    log_level = "error",
    auto_session_suppress_dirs = { "~/", "~/Downloads/", "/" },

    auto_session_enable_last_session = false,
    auto_session_root_dir = vim.fn.stdpath "data" .. "/sessions/",
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_use_git_branch = nil,
}

-- function SessionStatus()
--     local name = require("auto-session.lib").current_session_name()
--     if name ~= "" then
--         return " [Session: " .. name .. "]"
--     end
--     return ""
-- end
--
-- -- Append it to your existing statusline
-- vim.opt.statusline:append "%{luaeval('SessionStatus()')}"
