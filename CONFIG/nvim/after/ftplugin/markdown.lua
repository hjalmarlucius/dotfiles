local bufname = vim.api.nvim_buf_get_name(0)
local filename_arg = bufname ~= "" and (" --stdin-filepath " .. vim.fn.shellescape(bufname)) or ""

-- Indentation & Layout
vim.opt_local.colorcolumn = ""
vim.opt_local.wrap = true
vim.opt_local.textwidth = 80
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Formatting Behavior: wrap text, keep comment/quote headers, parse lists
vim.opt_local.formatoptions:append("tqn")

-- gq Formatter: Prettier handles links/parentheses cleanly; par as fallback
if vim.fn.executable("prettier") == 1 then
    vim.bo.formatprg = "prettier --parser markdown" .. filename_arg
elseif vim.fn.executable("par") == 1 then
    vim.bo.formatprg = "par -w80req"
end
