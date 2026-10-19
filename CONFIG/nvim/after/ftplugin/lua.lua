-- Indentation & Layout
vim.opt_local.colorcolumn = "120"
vim.opt_local.textwidth = 120
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true

-- Formatting Behavior
vim.opt_local.formatoptions:remove("t") -- Don't autowrap while typing
vim.opt_local.formatoptions:append("j") -- Remove comment markers when joining lines
