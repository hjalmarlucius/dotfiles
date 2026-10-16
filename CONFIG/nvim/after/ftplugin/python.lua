local bufname = vim.api.nvim_buf_get_name(0)
local filename_arg = bufname ~= "" and ("--stdin-filename " .. vim.fn.shellescape(bufname) .. " ") or ""

-- Indentation & Layout
vim.opt_local.colorcolumn = "100"
vim.opt_local.textwidth = 100
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- Formatting Behavior
vim.opt_local.formatoptions:remove("t") -- Don't autowrap while typing
vim.opt_local.formatoptions:append("j") -- Remove comment markers when joining lines

-- gq Formatters (Ruff fallback, LSP primary)
-- The trailing '-' is required for Ruff to read from stdin
vim.bo.formatprg = "ruff format " .. filename_arg .. "-"
vim.bo.formatexpr = "v:lua.vim.lsp.formatexpr()"
