-- https://github.com/windwp/nvim-autopairs
-- A super powerful autopair plugin for Neovim that supports multiple characters.

local npairs = require "nvim-autopairs"

npairs.setup {
  check_ts = true, -- enable treesitter
  ts_config = {
    lua = { "string" }, -- it will not add a pair on that treesitter node
    javascript = { "template_string" },
  },
  map_cr = false, -- <CR> is mapped below so it also confirms native completion
}

-- <CR>: confirm the selected completion item (expanding snippets / auto-imports);
-- with the popup open but nothing selected, close it and insert a newline;
-- otherwise autopairs' newline (splits `{|}` onto separate lines).
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ "selected" }).selected ~= -1 then
      return npairs.esc "<C-y>"
    end
    return npairs.esc "<C-e>" .. npairs.autopairs_cr()
  end
  return npairs.autopairs_cr()
end, { expr = true, replace_keycodes = false, desc = "Confirm completion / autopairs newline" })

