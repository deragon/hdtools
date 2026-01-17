-- Disable auto-formatting for bash/shell and python files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh", "python" },
  callback = function(event)
    vim.b[event.buf].autoformat = false
  end,
})

return {}
