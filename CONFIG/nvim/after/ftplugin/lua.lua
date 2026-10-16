local bufname = vim.api.nvim_buf_get_name(0)
local filename_arg = bufname ~= "" and ("--stdin-filepath " .. vim.fn.shellescape(bufname) .. " ") or ""

-- Indentation & Layout
vim.opt_local.colorcolumn = "120"
vim.opt_local.textwidth = 120
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- Formatting Behavior
vim.opt_local.formatoptions:remove("t")
vim.opt_local.formatoptions:append("j")

-- gq Formatters (StyLua fallback, LSP primary)
vim.bo.formatprg = "stylua " .. filename_arg .. "-"
vim.bo.formatexpr = "v:lua.vim.lsp.formatexpr()"
