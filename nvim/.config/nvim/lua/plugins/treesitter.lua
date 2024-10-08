return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "main",
  main = "nvim-treesitter.configs", -- Set main module to use for opts
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
