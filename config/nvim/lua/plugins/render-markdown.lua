-- https://github.com/MeanderingProgrammer/render-markdown.nvim
-- Renders markdown in the buffer on open; the cursor line drops back to raw text for editing.

require("render-markdown").setup {}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.keymap.set("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { buffer = ev.buf, desc = "Toggle Markdown Render" })
  end,
})
