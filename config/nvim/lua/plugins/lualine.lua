-- https://github.com/nvim-lualine/lualine.nvim
-- A blazing fast and easy to configure Neovim statusline written in Lua.

require("lualine").setup {
  sections = {
    lualine_c = {
      {
        "filename",
        path = 1,
      },
    },
  },
}
