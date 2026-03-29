local M = {}

local function binary_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Binaries to check and friendly install hints
local bins = {
  { name = "mmdc", hint = "Mermaid CLI (mmdc) - npm: npm i -g @mermaid-js/mermaid-cli" },
  { name = "magick", hint = "ImageMagick (magick) - macOS: brew install imagemagick" },
  { name = "convert", hint = "ImageMagick convert (legacy name)" },
  { name = "pdflatex", hint = "TeX Live (pdflatex) - macOS: brew install --cask mactex" },
  { name = "tree-sitter", hint = "tree-sitter CLI (required to build parsers): cargo install tree-sitter-cli or brew install tree-sitter" },
  { name = "lazygit", hint = "lazygit - macOS: brew install lazygit" },
  { name = "gs", hint = "Ghostscript (gs) - macOS: brew install ghostscript" },
  { name = "tmux", hint = "tmux - macOS: brew install tmux" },
}

function M.check(opts)
  opts = opts or {}
  local notify_missing = opts.notify_missing ~= false
  local missing = {}
  for _, b in ipairs(bins) do
    if not binary_exists(b.name) then
      table.insert(missing, { name = b.name, hint = b.hint })
    end
  end

  if #missing == 0 then
    if notify_missing then
      vim.notify("All configured external binaries found", vim.log.levels.INFO, { title = "opencode:verify" })
    end
    return true
  end

  local lines = { "Missing external binaries:" }
  for _, m in ipairs(missing) do
    table.insert(lines, string.format("- %s: %s", m.name, m.hint))
  end

  if notify_missing then
    vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "opencode:verify" })
  end

  return false, missing
end

return M
