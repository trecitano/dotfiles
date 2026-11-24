require "mappings"
require "options"

-- Plugins are managed by Neovim's built-in vim.pack (:h vim.pack).
--   Update:  :lua vim.pack.update()   (review, then :write to apply or :quit to discard)
--   Remove:  delete the line below, :restart, then :lua vim.pack.del({ "name" })
-- Installed revisions are pinned in nvim-pack-lock.json — keep it in git.

-- Build hooks. Registered before vim.pack.add() so they also run on first install.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd "nvim-treesitter"
      end
      vim.cmd "TSUpdate"
    end
  end,
})

local gh = function(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  -- UI
  { src = gh "catppuccin/nvim", name = "catppuccin" },
  gh "nvim-tree/nvim-web-devicons",
  gh "folke/snacks.nvim",
  gh "nvim-lualine/lualine.nvim",
  gh "folke/which-key.nvim",
  gh "folke/trouble.nvim",
  gh "j-hui/fidget.nvim",
  gh "rmagatti/auto-session",

  -- Editing
  { src = gh "nvim-treesitter/nvim-treesitter", version = "main" },
  gh "windwp/nvim-ts-autotag",
  gh "windwp/nvim-autopairs",
  gh "MeanderingProgrammer/render-markdown.nvim",

  -- LSP, formatting, linting
  gh "neovim/nvim-lspconfig",
  gh "stevearc/conform.nvim",
  gh "mfussenegger/nvim-lint",
}, { confirm = false })

-- Plugin configuration, one file per plugin under lua/plugins/.
require "plugins.catppuccin"
require "plugins.snacks"
require "plugins.auto-session"
require "plugins.lualine"
require "plugins.which-key"
require "plugins.trouble"
require "plugins.nvim-treesitter"
require "plugins.autopairs"
require "plugins.render-markdown"
require "plugins.lsp"
