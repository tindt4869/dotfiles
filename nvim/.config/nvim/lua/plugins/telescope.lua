return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-smart-history.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "kkharji/sqlite.lua",
    },
    config = function()
      local data = assert(vim.fn.stdpath "data") --[[@as string]]

      require("telescope").setup {
        extensions = {
          wrap_results = true,

          fzf = {},
          history = {
            path = vim.fs.joinpath(data, "telescope_history.sqlite3"),
            limit = 100,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {},
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "smart_history")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
      vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
      -- vim.keymap.set("n", "<leader>ft", builtin.git_files)
      -- vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)
      vim.keymap.set("n", "<leader>fa", function()
        ---@diagnostic disable-next-line: param-type-mismatch
        builtin.find_files { cwd = vim.fs.joinpath(vim.fn.stdpath "data", "lazy") }
      end)

      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files { cwd = vim.fn.stdpath "config" }
      end, { desc = "[F]ind files in [N]eovim config folder" })
      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>f/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      -- vim.keymap.set("n", "<leader>fg/", function()
      --   builtin.live_grep {
      --     grep_open_files = true,
      --     prompt_title = "Live Grep in Open Files",
      --   }
      -- end, { desc = "[S]earch [/] in Open Files" })
    end,
  },
}
