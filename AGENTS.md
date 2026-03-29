Purpose
-------
This file documents how autonomous agents (and humans) should interact with this Neovim configuration repository.
Include commands for building, linting and testing, and a compact style guide so agents make consistent edits.

Quick facts
-----------
- Repo type: Neovim config written in Lua (runtime path: `init.lua`, `lua/` folder).
- Main entry: `init.lua` (workspace root).
- Plugin configs live under `lua/plugins/` (examples: `formatter.lua`, `copilot.lua`).

Run / Build / Lint / Test
-------------------------
Notes: this repo contains editor config only — there is no compilation step. The commands below are recommended tools used by contributors.

- Format all Lua files (project root):

```sh
# Install stylua if missing: https://github.com/JohnnyMorganz/StyLua
stylua .
```

- Format a single file:

```sh
stylua path/to/file.lua
```

- Lint Lua files with luacheck (recommended):

```sh
# Install luacheck (LuaRocks): luarocks install luacheck
luacheck . --std lua52
```

- Run the config (headless) to validate startup (useful after edits):

```sh
# Run Neovim once with this config to surface runtime errors
nvim --headless -u init.lua -c 'quit'
```

- Quick binary verification (optional)

```sh
# Verify common external binaries used by the config (mermaid, imagemagick, tex, tree-sitter, lazygit, ghostscript):
# You can also run this check from inside Neovim if the `opencode` plugin is loaded:
# lua require('opencode.verify').check()
command -v mmdc || echo "mmdc (mermaid-cli) missing"
command -v magick || command -v convert || echo "ImageMagick missing (magick/convert)"
command -v pdflatex || echo "pdflatex (TeX) missing"
command -v tree-sitter || echo "tree-sitter CLI missing (required for building parsers)"
command -v lazygit || echo "lazygit missing"
```

- Run a single Lua test (busted)

```sh
# If you add tests using busted (common Lua test runner)
busted path/to/test_file.lua
busted --filter "describe name or it name"
```

- Run a single Python test (if the repo adds Python components)

```sh
pytest tests/test_module.py::test_name
# or use -k to match substring
pytest -k test_name
```

If a test framework does not exist yet
- Add `busted` for Lua tests and put tests under a `tests/` folder; example single-test command above.

Cursor & Copilot rules
----------------------
- Cursor rules: none detected in `.cursor/rules/` or `.cursorrules` in this repository. If such files are added, mirror their rules here.
- Copilot: this repo enables `github/copilot.vim` with these custom mappings: see `lua/plugins/copilot.lua`.
  - Acceptance mapping: Ctrl-j (`imap <silent><script><expr> <C-j> copilot#Accept("<Tab>")`).
  - Tab is intentionally not used for Copilot (`g:copilot_no_tab_map = v:true`).
  - Agents should respect the local key mapping convention when editing plugin config.

Code Style Guidelines
---------------------
General
- Language: Lua (Neovim runtime). Prefer idiomatic Lua + Neovim APIs (`vim.*`).
- Files: keep small focused modules under `lua/`; plugin specs under `lua/plugins/`.
- Line length: prefer <= 100 characters for readability in terminals.
- Encoding: UTF-8, but favor ASCII for source unless you need localized strings.

Formatting
- Use `stylua` as the canonical formatter for Lua files. Configure `.stylua.toml` if you need repo-specific rules.
- Remove trailing whitespace; ensure newline at EOF.
- Indentation: 2 spaces (stylua default).

Imports / requires
- Keep `require()` calls at the top of the module or inside the `config = function()` for plugin setups.
- Use guarded requires for optional modules/plugins:

```lua
local ok, mod = pcall(require, "plugin_name")
if not ok then
  vim.notify("plugin_name not available", vim.log.levels.WARN)
  return
end
```

- Prefer local binding for required modules to avoid global lookups:

```lua
local util = require('formatter.util')
```

Naming conventions
- Files / modules: use snake_case (e.g. `plugins/formatter.lua`).
- Local variables & functions: snake_case (e.g. `local my_var`, `local function do_setup()`).
- Module tables exported as a plugin spec or library may be PascalCase or snake_case, but be consistent within the repo.
- Constants: ALL_CAPS (rare in Lua configs, but acceptable for true constants).

Functions / returns
- Prefer short functions; keep side-effecting code inside `config = function()` for plugin specifications.
- Modules should return a single table when they are libraries; plugin spec files typically `return { ... }` (see `lua/plugins/*.lua`).

Types and annotations
- Lua is dynamically typed; when you need to communicate types to editors/agents use EmmyLua annotations:

```lua
--- @param buf number
--- @return string
local function name_of(buf)
  -- body
end
```

- When using Neovim LSP or sumneko/EmmyLua, these annotations improve completion and static checking.

Error handling and logging
- Fail safely for optional components: use `pcall(require, ...)` and return early when a plugin is missing.
- For runtime errors surfaced to users, prefer `vim.notify(msg, level)` where `level` is `vim.log.levels.*`.
- Do not use raw `print()` for user-facing messages in plugin/config code — use `vim.notify` or `vim.api.nvim_echo`.
- For assertions during development use `assert(condition, "message")`.

Plugin configuration patterns
- Use the existing table-of-tables pattern used by lazy/plugin managers. Example from this repo:

```lua
return {
  {
    "mhartington/formatter.nvim",
    config = function()
      -- plugin setup code
    end,
  },
}
```

- Keep configuration deterministic and idempotent: calling `config()` multiple times should not produce different results.

Tests and CI hints
- There is no CI configuration in this repo. If you add CI, include steps for:
  1) running `stylua --check` or similar format verification,
  2) running `luacheck`,
  3) running `busted` for Lua unit tests.

Editing and PR guidance for agents
- Make minimal focused changes in a single commit (if you are asked to commit).
- When editing plugin configs, preserve existing patterns (table layout and returned structures) used in `lua/plugins/`.
- If you add a new dependency/tool, add short install notes to this file.

Files of interest
- `init.lua` — main entry point (root).
- `lua/plugins/formatter.lua` — formatter plugin config (stylua, clang-format, python config).
- `lua/plugins/copilot.lua` — copilot mappings and behavior.

Next steps (recommended)
1. Add a `.stylua.toml` with consistent formatting options (if you want repo-specific style).
2. Add `luacheck` config (`.luacheckrc`) to lock lint rules.
3. If tests are desired, add `busted` with a `tests/` folder and examples showing how to run a single test.

Contact
- If an automated agent is confused, prefer safe defaults: do not touch unknown files, run `stylua` before committing, and fail loudly (notify) when a required plugin is missing.
