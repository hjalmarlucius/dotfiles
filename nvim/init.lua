vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode("/")
vim.o.langmap = "ø:"

-- general options
vim.o.shell = "/usr/bin/nu"
vim.g.BASH_Ctrl_j = "off"
vim.g.BASH_Ctrl_l = "off"
vim.opt.clipboard:append("unnamedplus")
vim.o.guicursor = "n-v-c:block-CustomCursor,i:ver100-CustomICursor,n-v-c:blinkon0,i:blinkwait10"
vim.o.cursorline = true
vim.o.list = true
vim.o.listchars = "tab:→ ,trail:·,extends:↷,precedes:↶,nbsp:+"
vim.o.mouse = "a"
vim.o.ruler = false
vim.o.scrolloff = 4
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.o.cmdheight = 0
vim.o.showmode = false
vim.o.sidescrolloff = 8
vim.o.timeoutlen = 500
vim.o.virtualedit = "block"
vim.o.wildmode = "longest:full,full"
vim.o.wrap = false
vim.opt.diffopt:append("linematch:60") -- second stage diff to align lines
vim.opt.diffopt:append("hiddenoff")
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.wildignore:append(
    "blue.vim,darkblue.vim,delek.vim,desert.vim,elflord.vim,evening.vim,habamax.vim,industry.vim,"
        .. "koehler.vim,lunaperche.vim,morning.vim,murphy.vim,pablo.vim,peachpuff.vim,quiet.vim,retrobox.vim,ron.vim,"
        .. "shine.vim,slate.vim,sorbet.vim,torte.vim,unokai.vim,vim.lua,wildcharm.vim,zaibatsu.vim,zellner.vim"
)

-- File History
vim.o.undofile = true
vim.o.undolevels = 100000
vim.o.undoreload = 100000
vim.o.updatetime = 200

-- Tab stop
vim.o.expandtab = true
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true

-- Session options
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

-- Completion Window/Popup settings
vim.o.completeopt = "menu,menuone,popup,fuzzy"
vim.o.pumblend = 10
vim.o.pumheight = 10
vim.o.winminwidth = 5

-- Fold settings
vim.opt.foldlevel = 99
vim.opt.smoothscroll = true
vim.opt.foldmethod = "expr"
vim.opt.foldtext = ""
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Format settings
vim.o.formatoptions = "jroqlnt"

-- Grep settings
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --vimgrep"

-- Search/subsitute settings
vim.o.ignorecase = false
vim.o.inccommand = "nosplit"
vim.o.jumpoptions = "view"
vim.o.smartcase = false

-- Spelling
vim.opt.spelllang = { "en" }

-- Splits
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true

-- Terminal
vim.o.termguicolors = true

-- Status Column
vim.o.number = true
vim.o.relativenumber = true

vim.opt.termguicolors = true
vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    virtual_text = {
        spacing = vim.o.shiftwidth,
        source = "if_many",
        severity = {
            max = vim.diagnostic.severity.WARN,
        },
    },
    signs = false,
    virtual_lines = {
        current_line = true,
        spacing = vim.o.shiftwidth,
        severity = { min = vim.diagnostic.severity.ERROR },
    },
    float = { source = true },
})
vim.lsp.set_log_level(2)

-- ----------------------------------------
-- MAPS
-- ----------------------------------------

local map = vim.keymap.set

-- better esc
map({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <alt> hjkl keys
map("n", "<M-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<M-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<M-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<M-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> hjkl keys
map("n", "<C-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Up" })

-- https://github.com/mhinz/vim-galore#tips-1
-- smarter next/prev in command line
map("n", "<c-n>", "wildmenumode() ? '<c-n>' : '<down>'", { expr = true, desc = "Next" })
map("n", "<c-p>", "wildmenumode() ? '<c-p>' : '<up>'", { expr = true, desc = "Prev" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "x", "n", "s" }, "<leader>ww", "<cmd>w<cr><esc>", { desc = "Save File" })

-- quit
map("n", "<leader>qq", "<cmd>q<cr>", { desc = "Close Window" })
map("n", "<leader>qa", "<cmd>qa<cr>", { desc = "Quit All" })
map("n", "<leader>qA", "<cmd>qa!<cr>", { desc = "Quit All" })
map("n", "<leader>wq", "<cmd>wq<cr>", { desc = "Write And Close Window" })
map("n", "<leader>wQ", "<cmd>wqa<cr>", { desc = "Write And Quit All" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- new file
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "New File" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
    vim.treesitter.inspect_tree()
    vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- Terminal Mappings
map("n", "<C-/>", "<cmd>terminal<cr>", { desc = "Show Terminal" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("n", "<C-_>", "<cmd>terminal<cr>", { desc = "which_key_ignore" })
map("t", "<C-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
map("n", "<M-v>", "<cmd>vsplit<cr>", { desc = "Split Window Right", remap = true })
map("n", "<M-s>", "<cmd>split<cr>", { desc = "Split Window Below", remap = true })
map("n", "<M-V>", "<cmd>vnew<cr>", { desc = "New Window Right", remap = true })
map("n", "<M-S>", "<cmd>new<cr>", { desc = "New Window Below", remap = true })

-- buffers
map("n", "<M-K>", "<cmd>bprev<cr>")
map("n", "<M-J>", "<cmd>bnext<cr>")

-- quickfix window
map("n", "<C-p>", "<cmd>lprev<cr>")
map("n", "<C-n>", "<cmd>lnext<cr>")

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>n", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>p", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- other
map("n", "<leader>cw", [[:cd %:p:h<cr>]], { desc = "Set Workspace To Buffer Path" })
map("n", "<leader>o", "m`o<Esc>``", { desc = "Insert Newline" })
map("n", "\\", "n.", { noremap = true, silent = true, desc = "Repeat And Goto Next" })
map("n", "<F2>", "<cmd>Lazy<cr>", { desc = "Lazy" })
map(
    "n",
    "<F5>",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update / Refresh Buffers" }
)

-- LSP
map("n", "<leader>ld", "<cmd>e ~/.local/state/nvim/lsp.log<cr>")
map("n", "<leader>lc", "<cmd>checkhealth<cr>")
local diagnostic_goto = function(count, severity)
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function() vim.diagnostic.jump({ severity, count = count }) end
end
map("n", "<M-i>", function() vim.diagnostic.open_float({ source = true }) end)
map("n", "<M-n>", diagnostic_goto(1), { desc = "Next Diagnostic" })
map("n", "<M-p>", diagnostic_goto(-1), { desc = "Prev Diagnostic" })
map("n", "[e", diagnostic_goto(-1, "ERROR"), { desc = "Prev Error" })
map("n", "[w", diagnostic_goto(-1, "WARN"), { desc = "Prev Warning" })
map("n", "]e", diagnostic_goto(1, "ERROR"), { desc = "Next Error" })
map("n", "]w", diagnostic_goto(1, "WARN"), { desc = "Next Warning" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "gD", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
map("n", "gi", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
map("n", "gl", vim.diagnostic.setloclist, { desc = "Diagnostics to Location List" })
map("n", "gr", function() vim.lsp.buf.references({ includeDeclaration = false }) end, { desc = "Goto References" })
map({ "n", "i" }, "<M-x>", vim.lsp.buf.signature_help)
map("n", "K", vim.lsp.buf.hover)
map("n", "<M-r>", vim.lsp.buf.rename)
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
-- replaced by Trouble
-- map("n", "<leader>cs", vim.lsp.buf.document_symbol, { desc = "Document Symbols" })
-- map("n", "<leader>cw", vim.lsp.buf.workspace_symbol, { desc = "Workspace Symbols" })

-- ----------------------------------------
-- AUTOCMD
-- ----------------------------------------

-- auto reload files
vim.api.nvim_create_autocmd("FocusGained", {
    desc = "Reload files from disk when we focus vim",
    pattern = "*",
    command = "if getcmdwintype() == '' | checktime | endif",
})
vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Every time we enter an unmodified buffer, check if it changed on disk",
    pattern = "*",
    command = "if &buftype == '' && !&modified && expand('%') != '' | exec 'checktime ' . expand('<abuf>') | endif",
})
-- Close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
    pattern = {
        "PlenaryTestPopup",
        "checkhealth",
        "floggraph",
        "fugitive",
        "git",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "notify",
        "oil",
        "qf",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, { buffer = event.buf, silent = true, desc = "Quit Buffer" })
        end)
    end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- ----------------------------------------
-- USER COMMANDS
-- ----------------------------------------

vim.api.nvim_create_user_command("ConvertEOL", function(opts)
    local fmt = opts.args
    if fmt ~= "unix" and fmt ~= "dos" and fmt ~= "mac" then
        vim.notify("Unsupported file format: " .. fmt, vim.log.levels.ERROR, {
            title = "ConvertEOL",
        })
    end
    vim.bo.fileformat = fmt
    vim.cmd([[write]])
    vim.notify("File converted to: " .. fmt, vim.log.levels.INFO, {
        title = "ConvertEOL",
    })
end, { nargs = 1 })

-- fix diff colors on some color schemes
-- https://codeyarns.com/tech/2011-07-29-vim-chart-of-color-names.html
vim.api.nvim_create_user_command("FixColors", function()
    vim.api.nvim_set_hl(0, "CustomCursor", { fg = "salmon1", bg = "cyan" })
    vim.api.nvim_set_hl(0, "CustomICursor", { fg = "salmon1", bg = "cyan" })
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "salmon4" })
end, {})

-- ----------------------------------------
-- SPECS
-- ----------------------------------------

local function makespecs_themes()
    return {
        "NLKNguyen/papercolor-theme",
        "junegunn/seoul256.vim",
        "mcauley-penney/phobos-anomaly.nvim",
        "folke/tokyonight.nvim",
        { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false },
        {
            "uloco/bluloco.nvim",
            lazy = false,
            dependencies = { "rktjmp/lush.nvim" },
            opts = {},
        },
        {
            "mhartington/oceanic-next",
            config = function()
                local customthemegroup = vim.api.nvim_create_augroup("customthemegroup", {})
                vim.api.nvim_create_autocmd("ColorScheme", {
                    pattern = { "OceanicNext" },
                    group = customthemegroup,
                    callback = function()
                        vim.api.nvim_set_hl(0, "DiffAdded", { default = false, link = "DiffAdd" })
                        vim.api.nvim_set_hl(0, "DiffRemoved", { default = false, link = "DiffDelete" })
                        vim.api.nvim_set_hl(0, "Normal", {})
                        vim.api.nvim_set_hl(0, "LineNr", {})
                        vim.api.nvim_set_hl(0, "SignColumn", {})
                        vim.api.nvim_set_hl(0, "EndOfBuffer", {})
                    end,
                })
            end,
        },
        "morhetz/gruvbox",
        {
            "catppuccin/nvim",
            name = "catppuccin",
            -- opts = { integrations = { grug_far = true, mason = true, noice = true, snacks = true, which_key = true } },
        },
        {
            "Shatur/neovim-ayu",
            init = function() vim.g.ayu_extended_palette = 1 end,
        },
        "tomasr/molokai",
        "jnurmine/Zenburn",
    }
end

local function makespec_lspconfig()
    return {
        "neovim/nvim-lspconfig",
        lazy = false,
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "LspInfo", "LspRestart", "LspStart", "LspStop" },
        keys = { { "<F4>", "<cmd>LspInfo<cr>", noremap = true } },
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.tinymist.setup({})
            lspconfig.bashls.setup({})
            lspconfig.nushell.setup({})
            lspconfig.lua_ls.setup({
                cmd = { "lua-language-server" },
                settings = {
                    Lua = {
                        workspace = {
                            checkThirdParty = false,
                            library = { vim.env.VIMRUNTIME },
                        },
                        telemetry = { enable = false },
                        diagnostics = { globals = { "vim" } },
                        format = { enable = false },
                        runtime = { version = "LuaJIT" },
                    },
                },
            })
            lspconfig.clangd.setup({
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=llvm",
                },
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
            })
            lspconfig.html.setup({
                cmd = { "vscode-html-language-server", "--stdio" },
                settings = {
                    html = {
                        format = {
                            templating = true,
                            wrapLineLength = 120,
                            wrapAttributes = "auto",
                        },
                        hover = { documentation = true, references = true },
                    },
                },
            })
            lspconfig.yamlls.setup({
                settings = {
                    yaml = {
                        schemas = { kubernetes = "/home/hjalmarlucius/src/hjarl/system/manifests/*.yaml" },
                        -- schemaStore = { enable = false, url = "" },
                    },
                },
            })
            lspconfig.pyright.setup({
                cmd = { "pyright-langserver", "--stdio", "--threads", "20" },
                filetypes = { "python" },
                settings = {
                    python = {
                        analysis = {
                            -- logLevel = "Trace",
                            autoImportCompletions = false,
                            diagnosticMode = "workspace",
                            useLibraryCodeForTypes = true,
                            logTypeEvaluationTime = true,
                            typeEvaluationTimeThreshold = 2000,
                        },
                    },
                },
            })
            lspconfig.vtsls.setup({
                settings = {
                    complete_function_calls = true,
                    vtsls = {
                        enableMoveToFileCodeAction = true,
                        autoUseWorkspaceTsdk = true,
                        experimental = {
                            maxInlayHintLength = 30,
                            completion = {
                                enableServerSideFuzzyMatch = true,
                            },
                        },
                    },
                    javascript = {
                        updateImportsOnFileMove = { enabled = "always" },
                        suggest = {
                            completeFunctionCalls = true,
                        },
                        inlayHints = {
                            enumMemberValues = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            variableTypes = { enabled = false },
                        },
                    },
                    typescript = {
                        updateImportsOnFileMove = { enabled = "always" },
                        suggest = {
                            completeFunctionCalls = true,
                        },
                        inlayHints = {
                            enumMemberValues = { enabled = true },
                            functionLikeReturnTypes = { enabled = true },
                            parameterNames = { enabled = "literals" },
                            parameterTypes = { enabled = true },
                            propertyDeclarationTypes = { enabled = true },
                            variableTypes = { enabled = false },
                        },
                    },
                },
            })
        end,
    }
end

local function makespec_lualine()
    return {
        "nvim-lualine/lualine.nvim",
        dependencies = { "echasnovski/mini.icons", "folke/noice.nvim" },
        opts = {
            options = { theme = "auto", globalstatus = false },
            extensions = { "fugitive", "neo-tree", "lazy" },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {},
                lualine_c = { { "filename", path = 1, shorting_target = 0 } },
                lualine_x = {
                    -- { 'require("noice").api.status.message.get()', color = { fg = "#99c794" } },  -- gets too obtrusive
                    { 'require("noice").api.status.mode.get()', color = "lualine_a_command" },
                    { 'require("noice").api.status.command.get()', color = "lualine_a_command" },
                },
                lualine_y = {
                    "encoding",
                    "filetype",
                    { "location", separator = "of", padding = { left = 1, right = 1 } },
                    "vim.api.nvim_buf_line_count(0)",
                },
                lualine_z = { { function() return " " .. os.date("%R") end } },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    { "filename", file_status = true, path = 1, shorting_target = 0 },
                },
                lualine_x = {},
                lualine_y = {
                    { "location", separator = "of", padding = { left = 1, right = 1 } },
                    "vim.api.nvim_buf_line_count(0)",
                },
                lualine_z = {},
            },
            tabline = {
                lualine_a = {
                    {
                        "buffers",
                        symbols = { alternate_file = "" },
                        buffers_color = { active = "lualine_a_command" },
                    },
                },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {
                    {
                        "tabs",
                        mode = 2,
                        tabs_color = { active = "lualine_a_command" },
                    },
                },
            },
        },
    }
end

local function makespec_oil()
    return {
        "stevearc/oil.nvim",
        dependencies = { "mini.icons" },
        cmd = { "Oil" },
        lazy = false,
        opts = {
            default_file_explorer = true,
            watch_for_changes = true,
            view_options = { show_hidden = true },
            columns = { "icon", "permissions", "size", "mtime" },
        },
        keys = {
            { "<leader>fE", "<cmd>Oil .<cr>", desc = "Oil Explorer (buffer)" },
            { "<leader>fe", "<cmd>Oil --float .<cr>", desc = "Oil Explorer (float)" },
        },
        init = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "OilActionsPost",
                callback = function(event)
                    if event.data.actions.type == "move" then
                        Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                    end
                end,
            })
        end,
    }
end

local function makespec_neotree()
    local function copy_path(state)
        -- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
        -- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
        local node = state.tree:get_node()
        local filepath = node:get_id()
        local filename = node.name
        local modify = vim.fn.fnamemodify

        local results = {
            filepath,
            modify(filepath, ":."),
            modify(filepath, ":~"),
            filename,
            modify(filename, ":r"),
            modify(filename, ":e"),
        }

        vim.ui.select({
            "1. Absolute path: " .. results[1],
            "2. Path relative to CWD: " .. results[2],
            "3. Path relative to HOME: " .. results[3],
            "4. Filename: " .. results[4],
            "5. Filename without extension: " .. results[5],
            "6. Extension of the filename: " .. results[6],
        }, { prompt = "Choose to copy to clipboard:" }, function(choice)
            if choice then
                local i = tonumber(choice:sub(1, 1))
                if i then
                    local result = results[i]
                    vim.fn.setreg("+", result)
                    vim.notify("Copied: " .. result)
                else
                    vim.notify("Invalid selection")
                end
            else
                vim.notify("Selection cancelled")
            end
        end)
    end
    return {
        {
            "nvim-neo-tree/neo-tree.nvim",
            version = false,
            cmd = { "Neotree" },
            dependencies = { "nvim-lua/plenary.nvim", "mini.icons", "MunifTanjim/nui.nvim" },
            opts = {
                hijack_netrw_behavior = "disabled",
                close_if_last_window = true,
                filesystem = {
                    filtered_items = { hide_gitignored = false },
                    follow_current_file = { enabled = false },
                },
                commands = {
                    system_open = function(state)
                        local node = state.tree:get_node()
                        local path = node:get_id()
                        -- macOs: open file in default application in the background.
                        -- vim.fn.jobstart({ "xdg-open", "-g", path }, { detach = true })
                        -- Linux: open file in default application
                        vim.fn.jobstart({ "xdg-open", path }, { detach = true })
                    end,
                },
                window = {
                    mappings = {
                        ["O"] = "system_open",
                        ["Y"] = copy_path,
                        ["h"] = function(state)
                            local node = state.tree:get_node()
                            if node.type == "directory" and node:is_expanded() then
                                require("neo-tree.sources.filesystem").toggle_directory(state, node)
                            else
                                require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
                            end
                        end,
                        ["l"] = function(state)
                            local node = state.tree:get_node()
                            if node.type == "directory" then
                                if not node:is_expanded() then
                                    require("neo-tree.sources.filesystem").toggle_directory(state, node)
                                elseif node:has_children() then
                                    require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
                                end
                            end
                        end,
                    },
                },
            },
            keys = { { "<leader>ff", "<cmd>Neotree<cr>", desc = "Neotree Explorer (sidebar)" } },
        },
    }
end

local function makespecs_previewers()
    return {
        {
            "chomosuke/typst-preview.nvim",
            lazy = false, -- or ft = 'typst'
            version = "1.*",
            opts = {
                -- debug = true,
                port = 10010,
                dependencies_bin = { ["tinymist"] = "tinymist" },
                follow_cursor = false,
                invert_colors = "auto",
                get_root = function(filename)
                    local root = os.getenv("TYPST_ROOT")
                    if root then return root end
                    local dir0 = vim.fn.fnamemodify(filename, ":p:h")
                    local dir = dir0
                    for _ = 1, 10 do
                        if vim.fn.isdirectory(dir .. "/.git/") ~= 0 or vim.fn.filereadable(dir .. "/.git") ~= 0 then
                            print("root dir: " .. dir)
                            return dir
                        end
                        dir = vim.fn.fnamemodify(dir, ":p:h:h")
                    end
                    return dir0
                end,
            },
        },
        {
            -- live preview of markdown files
            "iamcco/markdown-preview.nvim", -- requires yarn
            cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
            ft = { "markdown" },
            build = function() vim.fn["mkdp#util#install"]() end,
            init = function()
                vim.g.mkdp_auto_start = 0 -- auto start on moving into
                vim.g.mkdp_auto_close = 0 -- auto close on moving away
                vim.g.mkdp_open_to_the_world = 1 -- available to others
                vim.g.mkdp_port = 10010
                vim.g.mkdp_echo_preview_url = 1
                vim.g.mkdp_preview_options = { disable_sync_scroll = 1 }
            end,
        },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
            opts = {
                code = { sign = false, width = "block", right_pad = 1 },
                header = { sign = false, icons = {} },
                checkbox = { enabled = false },
            },
            ft = { "markdown" },
            config = function(_, opts)
                require("render-markdown").setup(opts)
                Snacks.toggle({
                    name = "Render Markdown",
                    get = function() return require("render-markdown.state").enabled end,
                    set = function(enabled)
                        local m = require("render-markdown")
                        if enabled then
                            m.enable()
                        else
                            m.disable()
                        end
                    end,
                }):map("<leader>um")
            end,
        },
    }
end

local function makespec_vimflog()
    return {
        {
            "rbong/vim-flog",
            dependencies = { "tpope/vim-fugitive" },
            cmd = { "Flog", "Flogsplit", "Floggit" },
            config = function()
                vim.g.flog_permanent_default_opts = {
                    -- format = "%ad [%h] {%an}%d %s",
                    format = "%ad [%h]%d %s",
                    date = "short",
                }
            end,
            keys = {
                { "<leader>gf", "<cmd>vertical Flogsplit -path=%<cr>", desc = "Git Flog File" },
                { "<leader>gc", "<cmd>vertical Flogsplit<cr>", desc = "Git Flog" },
            },
        },
    }
end
local function makespec_diffview()
    return {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewToggleFiles",
            "DiffviewFocusFiles",
            "DiffviewRefresh",
            "DiffviewFileHistory",
        },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView Tab" },
            { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History Tab" },
        },
    }
end
local function makespec_fugitive()
    return {
        "tpope/vim-fugitive",
        cmd = {
            "Git",
            "Gedit",
            "Gdiffsplit",
            "Gread",
            "Gwrite",
            "Ggrep",
            "Glgrep",
            "Gmove",
            "GRename",
            "GDelete",
            "GRemove",
            "Gdelete",
            "GUnlink",
            "GBrowse",
        },
        config = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = { "FugitiveCommit", "BufReadPost" },
                callback = function()
                    vim.opt_local.foldmethod = "syntax"
                    vim.opt_local.foldlevel = 0
                end,
            })
        end,
        keys = {
            { "<leader>gg", "<cmd>vertical Git<cr>", desc = "Fugitive" },
            { "<leader>gp", "<cmd>Git push<cr>", desc = "Git Push" },
            { "<leader>gP", "<cmd>Git push -f<cr>", desc = "Git Force Push" },
        },
    }
end

local function makespec_gitsigns()
    local function on_gitsigns_attach(bufnr)
        local gs = require("gitsigns")
        local function next_hunk()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gs.nav_hunk("next")
            end
        end
        local function prev_hunk()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gs.nav_hunk("prev")
            end
        end

        local function bmap(l, r, desc, mode) vim.keymap.set(mode or "n", l, r, { buffer = bufnr, desc = desc }) end

        -- Navigation
        bmap("<M-,>", next_hunk, "Prev Hunk")
        bmap("<M-.>", prev_hunk, "Next Hunk")
        bmap("[h", prev_hunk, "Prev Hunk")
        bmap("]h", next_hunk, "Next Hunk")

        -- Blame
        bmap("<leader>gB", gs.blame, "Blame Buffer")
        bmap("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")

        -- Hunk
        bmap("<leader>gI", gs.preview_hunk_inline, "Preview Hunk Inline")
        bmap("<leader>gi", gs.preview_hunk, "Preview Hunk")
        bmap("<leader>gq", gs.setqflist, "File Hunks to QuickFix")
        bmap("<leader>gQ", function() gs.setqflist("all") end, "All Hunks to QuickFix")
        bmap("<leader>gx", gs.reset_hunk, "Reset Hunk")
        bmap("<leader>gx", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset Hunk", "v")
        bmap("<leader>gR", gs.reset_buffer, "Reset Buffer")
        bmap("<leader>gs", gs.stage_hunk, "Stage Hunk")
        bmap("<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage Hunk", "v")
        bmap("<leader>gS", gs.stage_buffer, "Stage Buffer")
        bmap("<leader>gv", gs.select_hunk, "Select Hunk", { "n", "v" })

        -- Toggles
        bmap("<leader>gtw", gs.toggle_word_diff, "Toggle Diff Word Colors")
        bmap("<leader>gtl", gs.toggle_linehl, "Toggle Diff Line Highlight")
        bmap("<leader>gtb", gs.toggle_current_line_blame, "Toggle Line Blame")
        bmap("<leader>gtn", gs.toggle_numhl, "Toggle Diff Line Number Highlight")

        -- Text object, e.g. for dih to delete hunk
        bmap("ih", "<cmd>Gitsigns select_hunk<CR>", "Select Hunk", { "o", "x" })
    end

    return {
        "lewis6991/gitsigns.nvim",
        opts = {
            signcolumn = true,
            numhl = false,
            linehl = false,
            word_diff = false,
            signs_staged_enable = true,
            on_attach = on_gitsigns_attach,
        },
    }
end

local function makespec_orgmode()
    return {
        "nvim-orgmode/orgmode",
        event = "VeryLazy",
        config = function()
            -- Setup orgmode
            require("orgmode").setup({
                org_agenda_files = "~/notes/orgfiles/**/*",
                org_default_notes_file = "~/notes/orgfiles/refile.org",
            })
        end,
    }
end

local function makespec_whichkey()
    return {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            defaults = {},
            spec = {
                {
                    mode = { "n", "v" },
                    { "<leader>c", group = "code/content" },
                    { "<leader>f", group = "file/find" },
                    { "<leader>g", group = "git" },
                    { "<leader>gt", group = "toggles" },
                    { "<leader>l", group = "logs" },
                    { "<leader>p", group = "autoformat" },
                    { "<leader>q", group = "quit" },
                    { "<leader>s", group = "search" },
                    { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
                    { "[", group = "prev" },
                    { "]", group = "next" },
                    { "g", group = "goto" },
                    { "gs", group = "surround" },
                    { "z", group = "fold" },
                    { "<leader><tab>", group = "tabs" },
                    {
                        "<leader>w",
                        group = "windows",
                        proxy = "<c-w>",
                        expand = function() return require("which-key.extras").expand.win() end,
                    },
                    -- better descriptions
                    { "gx", desc = "Open with system app" },
                },
            },
        },
        keys = {
            {
                "<leader>?",
                function() require("which-key").show({ global = false }) end,
                desc = "Buffer Keymaps (which-key)",
            },
            {
                "<c-w><space>",
                function() require("which-key").show({ keys = "<c-w>", loop = true }) end,
                desc = "Window Hydra Mode (which-key)",
            },
        },
    }
end

local function makespec_lazydev()
    return {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "snacks.nvim", words = { "Snacks" } },
                { path = "lazy.nvim", words = { "LazyVim" } },
            },
        },
    }
end

local function makespec_snacks()
    local function term_nav(dir)
        ---@param self snacks.terminal
        return function(self)
            return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function() vim.cmd.wincmd(dir) end)
        end
    end
    return {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            bigfile = {
                enabled = true,
                notify = true, -- show notification when big file detected
                size = 1.5 * 1024 * 1024, -- 1.5MB
                line_length = 1000, -- average line length (useful for minified files)
                -- Enable or disable features when big file detected
                ---@param ctx {buf: number, ft:string}
                setup = function(ctx)
                    if vim.fn.exists(":NoMatchParen") ~= 0 then vim.cmd([[NoMatchParen]]) end
                    Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
                    vim.schedule(function()
                        if vim.api.nvim_buf_is_valid(ctx.buf) then vim.bo[ctx.buf].syntax = ctx.ft end
                    end)
                end,
            },
            bufdelete = { enabled = true },
            debug = { enabled = true },
            image = { enabled = true },
            indent = { enabled = true },
            lazygit = { enabled = vim.fn.has("lazygit") == 1 },
            notifier = {
                enabled = true,
                style = "minimal",
                refresh = 500,
                top_down = false,
            },
            ---@class snacks.picker
            picker = {
                formatters = { file = { filename_first = true } },
                win = { preview = { wo = { statuscolumn = "" } } },
            },
            quickfile = { enabled = true },
            rename = { enabled = true },
            scope = { enabled = true },
            terminal = {
                win = {
                    keys = {
                        nav_h = { "<M-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
                        nav_j = { "<M-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
                        nav_k = { "<M-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
                        nav_l = { "<M-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
                    },
                },
            },
            toggle = { enabled = true },
            words = { enabled = true },
            styles = {
                lazygit = {
                    width = 0,
                    height = 0,
                },
            },
        },
        -- stylua: ignore
        keys = {
            { "<leader>fr", function() Snacks.rename.rename_file() end, desc = "Rename File" },
            { "<M-d>", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
            { "<leader>qd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
            { "<leader>gl", function() Snacks.lazygit() end, desc = "Launch Lazygit" },
            { "<leader>.", function() Snacks.scratch.open() end, desc = "Scratch Buffer" },
            -- find
            { "<M-f>", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
            { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
            { "<leader>fa", function() Snacks.picker.files() end, desc = "Find Files" },
            { "<leader>fc", function() Snacks.picker.files({ cwd = "/home/hjalmarlucius/dotfiles", title="Find Configs" }) end, desc = "Find Config" },
            { "<leader>fn", function() Snacks.picker.files({ cwd = "/home/hjalmarlucius/notes", title="Find Notes" }) end, desc = "Find Note", },
            -- logs
            { "<leader>ll", function() Snacks.picker.notifications() end, desc = "Notification History" },
            -- code
            { "<leader>cS", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
            -- replaced by Trouble
            -- { "<leader>cW", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
            -- { "<leader>cd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
            -- terminal
            { "<C-/>", function() Snacks.terminal.toggle() end, desc = "Snacks Terminal", mode={"n", "t"} },
            { "<C-_>", function() Snacks.terminal.toggle() end, desc = "which_key_ignore", mode={'n', "t"} },
            -- search
            { "<F1>", function() Snacks.picker.help() end, desc = "Help Pages" },
            { "<F9>", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
            { "<M-/>", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" }, },
            { "<leader>/", function() Snacks.picker.search_history() end, desc = "Search History" },
            { "<leader>;", function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Buffers" },
            { "<leader>sb", function() Snacks.picker.lines() end, desc = "Grep Buffer" },
            { "<leader>sc", function() Snacks.picker.grep({ cwd = "/home/hjalmarlucius/dotfiles", title="Grep Configs" }) end, desc = "Grep Configs" },
            { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
            { "<leader>sn", function() Snacks.picker.grep({ cwd = "/home/hjalmarlucius/notes", title="Grep Notes" }) end, desc = "Grep Notes", },
            { "<leader>sp", function() Snacks.picker.projects() end, desc = "Find Projects" },
            { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
            { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },
        },
        init = function()
            -- stylua: ignore
            vim.api.nvim_create_autocmd("User", {
                pattern = "VeryLazy",
                callback = function()
                    -- Setup some globals for debugging (lazy-loaded)
                    _G.dd = function(...) Snacks.debug.inspect(...) end
                    _G.bt = function() Snacks.debug.backtrace() end
                    vim.print = _G.dd -- Override print to use snacks for `:=` command

                    Snacks.toggle.indent():map("<leader>u<tab>")
                    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
                    Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
                    Snacks.toggle.diagnostics():map("<leader>ud")
                    Snacks.toggle.dim():map("<leader>uD")
                    Snacks.toggle.inlay_hints():map("<leader>ui")
                    Snacks.toggle.line_number():map("<leader>ul")
                    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
                    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
                    Snacks.toggle.treesitter():map("<leader>ut")
                    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
                end,
            })
        end,
    }
end

local function makespecs_mini()
    return {
        {
            "echasnovski/mini.basics",
            opts = { options = { basic = true, extra_ui = true }, mappings = { move_with_alt = true } },
        },
        { "echasnovski/mini.icons", opts = {} },
        {
            "echasnovski/mini.surround",
            version = false,
            opts = {
                mappings = {
                    add = "yu", -- Add surrounding in Normal and Visual modes
                    delete = "du", -- Delete surrounding
                    find = "]u", -- Find surrounding (to the right)
                    find_left = "[u", -- Find surrounding (to the left)
                    highlight = "<leader>uu", -- Highlight surrounding
                    replace = "cu", -- Replace surrounding
                    update_n_lines = "", -- Update `n_lines`
                },
            },
        },
    }
end

local function makespec_trouble()
    return {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        opts = {
            modes = {
                lsp = { win = { position = "right", size = 100 } },
                diagnostics = { win = { position = "right", size = 100 } },
                symbols = { win = { position = "right", size = 100 } },
                loclist = { win = { position = "right", size = 100 } },
                qflist = { win = { position = "right", size = 100 } },
            },
        },
        keys = {
            { "<leader>cc", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
            { "<leader>cd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
            { "<leader>cr", "<cmd>Trouble lsp_references toggle<cr>", desc = "References" },
            { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Document Symbols" },
            { "<leader>ca", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/..." },
            { "<leader>cl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
            { "<leader>cq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
            {
                "[x",
                function()
                    if require("trouble").is_open() then
                        require("trouble").prev({ skip_groups = true, jump = true })
                    else
                        local ok, err = pcall(vim.cmd.cprev)
                        if not ok then vim.notify(err, vim.log.levels.ERROR) end
                    end
                end,
                desc = "Previous Trouble/Quickfix Item",
            },
            {
                "]x",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    else
                        local ok, err = pcall(vim.cmd.cnext)
                        if not ok then vim.notify(err, vim.log.levels.ERROR) end
                    end
                end,
                desc = "Next Trouble/Quickfix Item",
            },
        },
        specs = {
            "folke/snacks.nvim",
            opts = function(_, opts)
                return vim.tbl_deep_extend("force", opts or {}, {
                    picker = {
                        actions = require("trouble.sources.snacks").actions,
                        win = { input = { keys = { ["<c-t>"] = { "trouble_open", mode = { "n", "i" } } } } },
                    },
                })
            end,
        },
    }
end
local function makespec_todocomments()
    return {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        opts = {
            signs = true, -- show icons in the signs column
            sign_priority = 8, -- sign priority
            keywords = {
                MAYBE = { icon = " " },
                PERF = { icon = " " },
                FIX = { icon = " ", color = "error", alt = { "BUG" } },
                TODO = { icon = " ", color = "info" },
                HACK = { icon = " ", color = "warning" },
                WARN = { icon = " ", color = "warning" },
                NOTE = { icon = " ", color = "hint" },
                TEST = { icon = "⏲ ", color = "test" },
            },
            merge_keywords = false, -- when true, custom keywords will be merged with the defaults
            highlight = { keyword = "bg", pattern = [[.*<(KEYWORDS)\s*]] },
            search = { pattern = [[\b(KEYWORDS)\b]] },
            colors = {
                error = { "#ba1a1a" },
                warning = { "#FFC107" },
                info = { "#91BED0" },
                hint = { "#10B981" },
                default = { "#91D0C1" },
            },
        },
        keys = {
            { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
            { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
            { "<leader>ct", "<cmd>Trouble todo toggle<cr>", desc = "Comments list" },
            {
                "<leader>cT",
                "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
                desc = "Todo/Fix/Fixme list",
            },
            { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
            {
                "<leader>sT",
                function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end,
                desc = "Todo/Fix/Fixme",
            },
        },
    }
end

local function makespec_smartsplits()
    return {
        "mrjones2014/smart-splits.nvim",
        lazy = false,
        -- stylua: ignore
        keys = {
            { "<M-h>", function() require("smart-splits").move_cursor_left() end, { desc = "Go to Left Window", remap = true } },
            { "<M-j>", function() require("smart-splits").move_cursor_down() end, { desc = "Go to Left Window", remap = true } },
            { "<M-k>", function() require("smart-splits").move_cursor_up() end, { desc = "Go to Left Window", remap = true } },
            { "<M-l>", function() require("smart-splits").move_cursor_right() end, { desc = "Go to Left Window", remap = true } },
            { "<M-\\>", function() require("smart-splits").move_cursor_previous() end, { desc = "Go to Previous Window", remap = true } },
            { "<C-h>", function() require("smart-splits").resize_left() end, { desc = "Resize Window Left", remap = true } },
            { "<C-j>", function() require("smart-splits").resize_down() end, { desc = "Resize Window Down", remap = true } },
            { "<C-k>", function() require("smart-splits").resize_up() end, { desc = "Resize Window Up", remap = true } },
            { "<C-l>", function() require("smart-splits").resize_right() end, { desc = "Resize Window Right", remap = true } },
            { "<leader><leader>h", function() require("smart-splits").swap_buf_left() end, { desc = "Swap Buffer Left", remap = true } },
            { "<leader><leader>j", function() require("smart-splits").swap_buf_down() end, { desc = "Swap Buffer Down", remap = true } },
            { "<leader><leader>k", function() require("smart-splits").swap_buf_up() end, { desc = "Swap Buffer Up", remap = true } },
            { "<leader><leader>l", function() require("smart-splits").swap_buf_right() end, { desc = "Swap Buffer Right", remap = true } },
        },
    }
end

local function makespec_mason()
    return {
        "williamboman/mason.nvim",
        lazy = false,
        opts = {},
        keys = { { "<F3>", "<cmd>Mason<cr>", desc = "Mason" } },
    }
end

local function makespec_flash()
    return {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            search = {
                mode = "exact",
                exclude = {
                    "notify",
                    "noice",
                    "flash_prompt",
                    function(win) return not vim.api.nvim_win_get_config(win).focusable end,
                },
            },
            label = { uppercase = false },
            jump = { autojump = false },
            modes = {
                search = { enabled = true },
                char = {
                    jump = { autojump = true },
                    char_actions = function(motion)
                        return {
                            [";"] = "next", -- set to `right` to always go right
                            [","] = "prev", -- set to `left` to always go left
                            [motion:lower()] = "next",
                            [motion:upper()] = "prev",
                        }
                    end,
                },
            },
        },
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        },
        specs = {
            {
                "folke/snacks.nvim",
                opts = {
                    picker = {
                        win = {
                            input = { keys = { ["<a-s>"] = { "flash", mode = { "n", "i" } }, ["s"] = { "flash" } } },
                        },
                        actions = {
                            flash = function(picker)
                                require("flash").jump({
                                    pattern = "^",
                                    label = { after = { 0, 0 } },
                                    search = {
                                        mode = "search",
                                        exclude = {
                                            function(win)
                                                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype
                                                    ~= "snacks_picker_list"
                                            end,
                                        },
                                    },
                                    action = function(match)
                                        local idx = picker.list:row2idx(match.pos[1])
                                        picker.list:_move(idx, true, true)
                                    end,
                                })
                            end,
                        },
                    },
                },
            },
        },
    }
end

local function makespec_grugfar()
    return {
        "MagicDuck/grug-far.nvim",
        opts = { headerMaxWidth = 80 },
        cmd = "GrugFar",
        keys = {
            {
                "<leader>sr",
                function()
                    local grug = require("grug-far")
                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    grug.open({
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace",
            },
        },
    }
end

local function makespec_treesitter()
    return {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            {
                ensure_installed = {
                    "bash",
                    "c",
                    "cpp",
                    "git_rebase",
                    "gitcommit",
                    "lua",
                    "nu",
                    "python",
                    "regex",
                    "vimdoc",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true, disable = { "python" }, additional_vim_regex_highlighting = { "python" } },
                -- incremental_selection done by flash plugin
            },
        },
        init = function() vim.opt.foldexpr = "nvim_treesitter#foldexpr()" end,
    }
end

local function makespec_hlslens()
    return {
        -- search count > 99
        "kevinhwang91/nvim-hlslens",
        dependencies = { "haya14busa/vim-asterisk" },
        cmd = { "HlSearchLensDisable", "HlSearchLensEnable", "HlSearchLensToggle" },
        opts = { nearest_only = true, nearest_float_when = "never" },
        keys = {
            { "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, {} },
            { "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, {} },
            { "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, {} },
            { "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, {} },
            { "n", [[n<Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, noremap = true, silent = true },
            { "N", [[N<Cmd>lua require('hlslens').start()<CR>]], mode = { "n", "x" }, noremap = true, silent = true },
        },
        init = function() vim.g["asterisk#keeppos"] = 1 end,
    }
end

local function makespec_autotag()
    return {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        opts = { filetypes = { "html", "xml" } },
    }
end

local function makespec_lint()
    return {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                html = { "tidy", "eslint_d" },
                go = { "golangcilint" },
                sh = { "shellcheck" },
            }
            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                callback = function() require("lint").try_lint() end,
            })
        end,
    }
end

local function makespec_conform()
    return {
        "stevearc/conform.nvim",
        lazy = true,
        cmd = { "ConformInfo" },
        keys = {
            { "<leader>p", function() require("conform").format() end, silent = true, desc = "Autoformat" },
            { "<leader>lp", "<cmd>e ~/.local/state/nvim/conform.log<cr>", desc = "Conform log" },
        },
        opts = {
            formatters_by_ft = {
                ["_"] = { "trim_whitespace" },
                css = { "prettierd", "prettier", stop_after_first = true },
                go = { "gofumpt", "golines" },
                html = { "prettierd", "prettier", stop_after_first = true },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                json = { "jq" },
                lua = { "stylua" },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                typescript = { "eslint_d" },
                typst = { "typstyle" },
                yaml = { "yamlfmt" },
            },
            default_format_opts = {
                timeout_ms = 3000,
                lsp_format = "fallback",
            },
            formatters = {
                javascript = { require_cwd = true },
                stylua = { append_args = { "--indent-type", "Spaces", "--collapse-simple-statement", "Always" } },
                ruff_fix = { append_args = { "--select", "I,F,UP" } },
                yamlfmt = {
                    prepend_args = {
                        "-formatter",
                        "indentless_arrays=true,retain_line_breaks=true,line_ending=lf,max_line_length=100,pad_line_comments=2",
                    },
                },
            },
        },
    }
end

local function makespec_noice()
    return {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
        opts = {
            messages = {
                enabled = true,
                view = "notify",
                view_error = "notify",
                view_warn = "notify",
                view_history = "popup",
                view_search = false,
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
                signature = { enabled = true, auto_open = { enabled = false, throttle = 50 } },
            },
            presets = {
                command_palette = true,
                long_message_to_split = true,
            },
            routes = {
                { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
                { filter = { kind = "", min_height = 2 }, view = "split" },
            },
        },
        keys = {
            { "<leader>lx", function() require("noice").cmd("dismiss") end, desc = "Noice dismiss" },
            { "<leader>lh", function() require("noice").cmd("all") end, desc = "Noice history" },
            { "<leader>ls", function() require("noice").cmd("stats") end, desc = "Noice stats" },
            { "<leader>un", function() require("noice").cmd("enable") end, desc = "Enable Noice" },
            { "<leader>uN", function() require("noice").cmd("disable") end, desc = "Disable Noice" },
        },
    }
end

-- ----------------------------------------
-- LAZY
-- ----------------------------------------

local lazyspecs = {
    "dhruvasagar/vim-table-mode", -- tables
    "itchyny/vim-qfedit", -- editable quickfix list
    { "ethanholz/nvim-lastplace", opts = {} }, -- keep location upon reopening
    "tpope/vim-eunuch", -- Move, Rename etc
    "tpope/vim-sleuth", -- do the right thing with tabstop and softtabstop
    "mbbill/undotree",
}
for _, spec in ipairs({
    makespec_lazydev(), -- nvim lsp helpers
    makespec_snacks(),
    makespec_conform(), -- autoformat
    makespec_lspconfig(),
    makespec_treesitter(),
    makespec_todocomments(),
    makespec_trouble(),
    makespec_autotag(),
    makespec_lint(),
    makespec_mason(),
    makespec_orgmode(),
    -- navigation
    makespec_whichkey(),
    makespec_smartsplits(),
    makespec_hlslens(),
    makespec_flash(),
    makespec_grugfar(),
    -- visuals
    makespec_lualine(),
    makespec_noice(),
    -- file browsers
    makespec_neotree(),
    makespec_oil(),
    -- git
    makespec_gitsigns(),
    makespec_fugitive(),
    makespec_diffview(),
    makespec_vimflog(),
}) do
    table.insert(lazyspecs, spec)
end
for _, specs in ipairs({
    makespecs_themes(),
    makespecs_mini(),
    makespecs_previewers(),
}) do
    for _, spec in ipairs(specs) do
        table.insert(lazyspecs, spec)
    end
end
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    spec = lazyspecs,
    checker = { enabled = true },
})
vim.cmd("colorscheme bluloco-dark")
