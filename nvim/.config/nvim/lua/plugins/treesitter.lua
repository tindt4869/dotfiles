return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "master",
  main = "nvim-treesitter.configs", -- Set main module to use for opts
  init = function(plugin)
    -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
    -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
    -- no longer trigger the **nvim-treesitter** module to be loaded in time.
    -- Luckily, the only things that those plugins need are the custom queries, which we make available
    -- during startup.
    require("lazy.core.loader").add_to_rtp(plugin)
    require "nvim-treesitter.query_predicates"
  end,
  opts = {
    ensure_install = {
      "lua",
      "python",
      "javascript",
      "typescript",
      "vimdoc",
      "vim",
      "regex",
      "sql",
      "dockerfile",
      "toml",
      "json",
      "go",
      "gitignore",
      "yaml",
      "make",
      "cmake",
      "markdown",
      "markdown_inline",
      "bash",
      "tsx",
      "css",
      "html",
    },
    -- Autoinstall languages that are not installed
    auto_install = false,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --   If you are experiencing weird indenting issues, add the language to
      --   the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { "ruby" },
    },
    indent = { enable = true, disable = { "ruby " } },
  },
  -- There are additional nvim-treesitter modules that yuou can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --     - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --     - Show your current context:  https://github.com/nvim-treesitter/nvim-treesitter-context
  --     - Treesitter + textobjects:  https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
