local opt = vim.opt
local o = vim.o
local g = vim.g

o.laststatus = 3
o.showmode = false

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "number"

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2
o.scrolloff = 5

opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

-- Numbers
o.number = true
o.numberwidth = 2
o.ruler = false
o.relativenumber = true

-- disable nvim intro
opt.shortmess:append "sI"

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true

-- interval for writing swap file to disk and firing CursorHold (LSP highlights, snacks words)
o.updatetime = 250

-- Rounded borders on every floating window (hover, signature help, diagnostics, pickers).
o.winborder = "rounded"

-- Native completion (Nvim 0.12), replacing nvim-cmp.
-- Insert mode: popup as you type. Sources in priority order: LSP (via 'omnifunc'),
-- current buffer, other windows, other listed buffers. File paths: <C-x><C-f>.
o.autocomplete = true
o.complete = "o^15,.^5,w^5,b^5"
o.completeopt = "menuone,noselect,popup,fuzzy"
o.pumheight = 12

-- Command line: popup suggestions as you type on `:`, `/` and `?` (see :h cmdline-autocompletion).
o.wildmode = "noselect:lastused,full"
o.wildoptions = "pum,fuzzy"
vim.api.nvim_create_autocmd("CmdlineChanged", {
  pattern = { ":", "/", "?" },
  callback = function() vim.fn.wildtrigger() end,
})
-- Keep <Up>/<Down> as history navigation while the popup is open.
vim.keymap.set("c", "<Up>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Up>" or "<Up>" end, { expr = true })
vim.keymap.set("c", "<Down>", function() return vim.fn.wildmenumode() == 1 and "<C-e><Down>" or "<Down>" end, { expr = true })

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
