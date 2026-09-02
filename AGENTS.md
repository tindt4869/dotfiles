# AGENTS.md — Neovim Configuration

> Tip: for GPU/Vulkan tool build troubleshooting (whisper.cpp, llama.cpp, SPIRV-Headers,
> shared-lib/RUNPATH pitfalls), see `docs/vulkan-build-notes.md`.

This is a personal Neovim config using `vim.pack` (built-in package management). No plugin manager like lazy.nvim.

## Commands

```bash
# Format all Lua files (run from repo root)
stylua .

# Format a single file
stylua lua/plugins/foo.lua
```

There is no test suite, linter, or build step. This is a dotfiles repo — correctness is validated by loading Neovim.

## Code Style

### Formatting
- **4 spaces**, no tabs (`stylua.toml`)
- `no_call_parentheses = true` — omit `()` when passing a single string or table
  ```lua
  require "core.theme"        -- preferred
  require("foo").setup()      -- acceptable when chaining
  ```

### File Naming
- `kebab-case.lua` for all files (e.g., `better-quickfix.lua`, `auto-session.lua`)

### Variable / Function Naming
- `snake_case` for locals: `local compile_cmd`, `local function pack_clean()`
- Short helper names are fine: `local function map(mode, l, r, opts)`

### Imports / Requires
- `init.lua` and `core/` files: `require "module"` (no parens)
- `plugins/` files: both styles exist; prefer no parens for consistency
- Every plugin file must declare its dependencies with `vim.pack.add` before configuring:
  ```lua
  vim.pack.add {
      { src = "https://github.com/owner/repo" },
  }
  require("repo").setup { ... }
  ```

### Table Style
- 4-space indentation, trailing commas
- Use `{ }` (no parens) for `setup` calls with tables:
  ```lua
  require("conform").setup {
      formatters_by_ft = {
          lua = { "stylua" },
      },
  }
  ```

### Keymaps
```lua
vim.keymap.set("n", "<c-j>", "<c-w><c-j>")
vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "LSP Definitions" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump { count = 1, float = true }
end)
```

### Autocommands
```lua
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight yanked text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank { higroup = "IncSearch" }
    end,
})
```

### Error Handling
- Use `pcall` for optional dependencies:
  ```lua
  local status, ts = pcall(require, "nvim-treesitter.config")
  if not status then
      print("Treesitter not found!")
      return
  end
  ```
- Required plugins need no guard.

### Diagnostics / Type Annotations
- Use `---@diagnostic disable-next-line: <rule>` sparingly
- `---@class` annotations for complex configs:
  ```lua
  ---@class snacks.indent.Config
  ---@field enabled? boolean
  ```

### Comments
- Single-line: `-- text` (space after `--`)
- Avoid block comments

## Project Structure

```
init.lua                          # Entry point: options + loads
lua/
  core/                           # Theme, keymaps, autocommands, user commands
  plugins/                        # One file per plugin/plugin group
  utils/                          # Utility modules (e.g. package cleanup)
after/ftplugin/                   # Filetype-specific options
snippets/                         # LuaSnip snippets (cpp.snippets)
```

## Conventions

- **Leader key**: space (`vim.g.mapleader = " "`)
- **Numbers**: relative + absolute (`vim.o.relativenumber = true`)
- **Tabs**: `tabstop = 4` (filetype overrides in `after/ftplugin/`)
- **Borders**: rounded (`vim.o.winborder = "rounded"`)
- **Git commits**: `type(neovim): description` — types: `feat`, `fix`

## Adding a New Plugin

1. Create `lua/plugins/<name>.lua`
2. Add `vim.pack.add { { src = "..." } }` at top
3. Call `require("plugin").setup { ... }`
4. Load it in `init.lua` with `require "plugins.<name>"`

## Existing AI Rules

None. No `.cursorrules`, `.cursor/rules/`, or `.github/copilot-instructions.md` exist.
