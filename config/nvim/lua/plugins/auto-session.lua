-- https://github.com/rmagatti/auto-session

---@module "auto-session"
---@type AutoSession.Config
require("auto-session").setup {
  suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
  -- log_level = 'debug',
}
