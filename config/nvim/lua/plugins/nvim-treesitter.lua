-- https://github.com/nvim-treesitter/nvim-treesitter (main branch)
-- Installs tree-sitter parsers and queries. Highlighting, folding and incremental selection
-- (visual mode: `an` outwards, `in` inwards, `]n` / `[n` siblings) are built into Neovim 0.12.
-- Needs the `tree-sitter` CLI (brew install tree-sitter-cli);
-- init.lua runs :TSUpdate after each plugin update.

local ensure_installed = {
  "json",
  "lua",
  "c",
  "zig",
  "rust",
  "ruby",
  "go",
  "dockerfile",
  "tsx",
  "javascript",
  "typescript",
  "html",
  "css",
  "markdown",
  "markdown_inline",
}

local ts = require "nvim-treesitter"
ts.install(ensure_installed)

local function attach(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

-- Start treesitter for every buffer that has a parser, installing missing parsers on
-- first use (replaces master's `highlight`, `indent` and `auto_install` options).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match)
    if not lang then
      return
    end
    if vim.treesitter.language.add(lang) then
      attach(event.buf, lang)
    elseif vim.tbl_contains(ts.get_available(), lang) then
      ts.install(lang):await(function()
        attach(event.buf, lang)
      end)
    end
  end,
})

-- https://github.com/windwp/nvim-ts-autotag
require("nvim-ts-autotag").setup {}
