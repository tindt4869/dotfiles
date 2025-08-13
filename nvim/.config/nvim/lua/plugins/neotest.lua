return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      -- "nvim-neotest/nvim-nio",
      -- "antoinemadec/FixCursorHold.nvim",
      -- Adapters
      "haydenmeade/neotest-jest",
      "marilari88/neotest-vitest",
    },
    keys = {
      -- {
      --   "<leader>tw",
      --   "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<cr>",
      --   desc = "Run Watch",
      -- },
      -- { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Test Files (Neotest)",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest (Neotest)",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last (Neotest)",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary (Neotest)",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open { enter = true, auto_close = true }
        end,
        desc = "Show Output (Neotest)",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel (Neotest)",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop (Neotest)",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand "%")
        end,
        desc = "Toggle Watch (Neotest)",
      },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup {
        ---@diagnostic disable-next-line: missing-fields
        discovery = {
          enabled = false,
        },
        adapters = {
          require "neotest-jest" {
            jest_test_discovery = false,
            jestCommand = "npx run test --",
            -- jestConfigFile = "custom.jest.config.ts",
            env = { CI = false },
            cwd = function()
              return vim.fn.getcwd()
            end,
          },
          require "neotest-vitest",
        },
      }
    end,
  },
}
