-- https://github.com/neovim/nvim-lspconfig
-- nvim-lspconfig is a "data only" repo, providing basic, default Nvim LSP client configurations for various LSP servers.

-- Servers configured with Neovim's built-in vim.lsp.config / vim.lsp.enable (Nvim 0.11+).
-- nvim-lspconfig only supplies the default cmd/filetypes/root_markers for each server;
-- everything below is merged on top of those defaults.
local servers = {
  "lua_ls",
  "gopls",
  "rust_analyzer", -- installed by rustup
  "pyright",
  "zls", -- installed locally
  "ts_ls", -- TypeScript < 7
  "tsc", -- TypeScript 7+ native server
  "tailwindcss",
  "bashls",
  "cssls",
  "jsonls",
  "html",
  "taplo",
  "yamlls",
  "marksman",
  "oxlint", -- runs the project's node_modules/.bin/oxlint; only attaches where an oxlint config exists
}

local function configure_lsp_config()
  -- Lua
  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        runtime = { version = "Lua 5.4" },
        diagnostics = {
          globals = { "vim", "Snacks" },
        },
      },
    },
  })

  -- Rust
  vim.lsp.config("rust_analyzer", {
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        procMacro = { enable = true },
        checkOnSave = { command = "clippy" },
      },
    },
  })

  -- Python
  vim.lsp.config("pyright", {
    settings = {
      python = {
        analysis = {
          diagnosticSeverityOverrides = {
            -- https://microsoft.github.io/pyright/#/configuration?id=diagnostic-rule-defaults
            reportMissingImports = "error",
            reportUndefinedVariable = "none",
          },
          typeCheckingMode = "off",
        },
      },
    },
  })

  -- TypeScript: pick the server per project from the project's own TypeScript version.
  -- TypeScript 7+ (bos web) has a native language server (`tsc --lsp`) and no longer ships the
  -- tsserver that ts_ls needs; older projects (bos mobile) and loose files use ts_ls, which
  -- falls back to the global TypeScript 6 from mise.
  local function project_typescript(bufnr)
    local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    while dir do
      local pkg = vim.fs.joinpath(dir, "node_modules/typescript/package.json")
      if vim.uv.fs_stat(pkg) then
        local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
        return dir, ok and tonumber(tostring(data.version):match "^(%d+)") or 0
      end
      local parent = vim.fs.dirname(dir)
      dir = parent ~= dir and parent or nil
    end
  end

  local ts_ls_root_dir = vim.lsp.config.ts_ls.root_dir
  vim.lsp.config("ts_ls", {
    root_dir = function(bufnr, on_dir)
      local _, major = project_typescript(bufnr)
      if (major or 0) < 7 then
        ts_ls_root_dir(bufnr, on_dir)
      end
    end,
    -- Outside a project with its own TypeScript, use the global one from mise.
    before_init = function(params)
      local res = vim.system({ "mise", "where", "npm:typescript" }, { text = true }):wait()
      if res.code == 0 then
        params.initializationOptions = params.initializationOptions or {}
        params.initializationOptions.tsserver = {
          fallbackPath = vim.trim(res.stdout) .. "/node_modules/typescript/lib/tsserver.js",
        }
      end
    end,
    settings = {
      completions = {
        completeFunctionCalls = true,
      },
    },
  })

  vim.lsp.config("tsc", {
    root_dir = function(bufnr, on_dir)
      local root, major = project_typescript(bufnr)
      if root and major >= 7 then
        on_dir(root)
      end
    end,
    cmd = function(dispatchers, config)
      local tsc = vim.fs.joinpath(config.root_dir, "node_modules/typescript/bin/tsc")
      return vim.lsp.rpc.start({ tsc, "--lsp", "--stdio" }, dispatchers)
    end,
  })

  -- Tailwind: its defaults now include markdown and many templating languages; keep it to web files.
  vim.lsp.config("tailwindcss", {
    filetypes = {
      "html",
      "css",
      "scss",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
  })

  -- gopls, zls, bashls, cssls, jsonls, html, taplo, yamlls and marksman run on lspconfig's defaults.
  vim.lsp.enable(servers)
end

-- Server binaries are installed and pinned by mise (dotfiles config/mise/config.toml) and
-- found on PATH; nvim-lspconfig supplies their defaults, fidget shows progress.
require("fidget").setup {}
configure_lsp_config()

-- From https://github.com/nvim-lua/kickstart.nvim/blob/a8f539562a8c5d822dd5c0ca1803d963c60ad544/init.lua#L545
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    --map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    -- Native LSP completion. The 'autocomplete' popup (options.lua) already pulls LSP items
    -- through 'omnifunc'; enabling this adds trigger-character popups (`.`, `:` …) and makes
    -- accepting an item (<C-y> / <CR>) expand snippets and apply auto-imports.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method "textDocument/completion" then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
      map("<C-Space>", vim.lsp.completion.get, "Trigger completion", "i")
    end
  end,
})

vim.diagnostic.config {
  -- update_in_insert = true,
  float = {
    focusable = false,
    style = "minimal",
    source = true,
    header = "",
    prefix = "",
  },
}

-- https://github.com/stevearc/conform.nvim
require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    ruby = { "rubocop" },
    rust = { "rustfmt" },
    go = { "goimports" },
    python = { "ruff_format" },
    bash = { "shfmt" },

    -- Frontend: oxfmt from the project's node_modules (falls back to a global `oxfmt`).
    -- Where neither exists, conform skips it and format_on_save falls back to the LSP.
    typescript = { "oxfmt" },
    typescriptreact = { "oxfmt" },
    javascript = { "oxfmt" },
    javascriptreact = { "oxfmt" },
    json = { "oxfmt" },
    jsonc = { "oxfmt" },
    html = { "oxfmt" },
    css = { "oxfmt" },
    scss = { "oxfmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
}

-- https://github.com/mfussenegger/nvim-lint
local lint = require "lint"

lint.linters_by_ft = {
  go = { "golangcilint" },
  lua = { "luac" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = lint_augroup,
  callback = function() lint.try_lint() end,
})

vim.keymap.set("n", "<leader>li", function()
  lint.try_lint()
end, { desc = "Trigger linting for current file" })
