vim.opt.termguicolors = true
vim.g.mapleader = vim.keycode("<space>")
vim.g.maplocalleader = vim.keycode(",")

-- ----------------------------------------
-- SETTINGS
-- ----------------------------------------

-- system
vim.o.shell = "/usr/bin/bash"
vim.o.fileencodings = "utf-8,ucs-bom,gb18030,gbk,gb2312,cp936"
vim.o.fileformats = "unix"
vim.o.swapfile = false
vim.g.BASH_Ctrl_j = "off"
vim.g.BASH_Ctrl_l = "off"
-- TODO remove <cr> in commands

-- undo
vim.o.undolevels = 100000
vim.o.undoreload = 100000

-- buffer
vim.o.hidden = true -- Enable background buffers
vim.o.number = false
vim.o.relativenumber = false
vim.o.cursorline = false
vim.o.switchbuf = "useopen" -- Use existing window if buffer is already open

-- diffs
vim.o.diffopt = "internal,filler,closeoff,hiddenoff,vertical,algorithm:patience"

-- tabs
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.shiftround = true -- Round indent
vim.o.tabstop = 4 -- Number of spaces tabs count for
vim.o.shiftwidth = 4 -- Size of an indent
vim.o.listchars = "tab:→ ,trail:·,extends:↷,precedes:↶,nbsp:+"
vim.o.list = true -- Show listchars

-- search
vim.opt.smartcase = false
vim.opt.ignorecase = false
vim.opt.wildmode = { "full" } -- Command-line completion mode
vim.opt.wildignore = vim.opt.wildignore
    + { "*swp", "*.class", "*.pyc", "*.png", "*.jpg", "*.gif", "*.zip", "*/tmp/*", "*.o", ".obj", "*.so" }

-- folding
vim.o.foldenable = true -- enable fold
vim.o.foldlevel = 99 -- start editing with all folds opened
vim.o.foldmethod = "expr" -- use tree-sitter for folding method
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- cursor
vim.o.scrolloff = 5 -- Lines of context
vim.o.scrolljump = 1 -- Lines to scroll when cursor leaves screen
vim.o.sidescrolloff = 4 -- Columns of context
vim.o.showmatch = true -- Show matching brackets / parentheses

-- editing
vim.o.langmap = "å(,¨),ø:,æ^,+$"
vim.opt.clipboard = vim.opt.clipboard + { "unnamedplus" }

vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
vim.opt.iskeyword = vim.opt.iskeyword - { "." }

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "quickfix" },
    callback = function() vim.keymap.set("n", "<cr>", "<cr>", { buffer = true }) end,
})

-- ----------------------------------------
-- MAPS
-- ----------------------------------------

local map = vim.keymap.set
map("n", "Q", "", { noremap = true })
map("n", "q:", "", { noremap = true })

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
map("n", "<leader>ww", [[:cd %:p:h<cr>]], { noremap = true }) -- change workspace
map("n", "<esc><esc>", "<cmd>noh<cr>", { silent = true, noremap = true })
map("", "<F12>", "<esc>", { silent = true, noremap = true })

-- <Tab> to navigate the completion menu
map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true, noremap = true })
map("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true, noremap = true })
vim.opt.pumheight = 0

-- CURSOR
-- stay visual when indenting
map({ "n", "v" }, "-", "_", { noremap = true })
map("v", "v", "<esc>", { noremap = true })
map("v", "<Tab>", ">gv", { noremap = true })
map("v", "<S-Tab>", "<gv", { noremap = true })
map("n", "<leader>o", "m`o<Esc>``", { noremap = true }) -- Insert a newline in normal mode
-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
-- repeat and next
map("n", "\\", "n.", { noremap = true, silent = true })

-- WINDOWS / BUFFERS
-- make splits and tabs
map("n", "<M-V>", "<cmd>vnew<cr>", { noremap = true })
map("n", "<M-S>", "<cmd>new<cr>", { noremap = true })
map("n", "<M-v>", "<cmd>vsplit<cr>", { noremap = true })
map("n", "<M-s>", "<cmd>split<cr>", { noremap = true })
map("n", "<M-t>", "<cmd>tabe %<cr>", { noremap = true })
map("n", "<M-T>", "<cmd>tabnew<cr>", { noremap = true })
-- buffers and tabs
map("n", "<M-K>", "<cmd>bprev<cr>", { noremap = true })
map("n", "<M-J>", "<cmd>bnext<cr>", { noremap = true })
map("n", "<M-H>", "<cmd>tabprev<cr>", { noremap = true })
map("n", "<M-L>", "<cmd>tabnext<cr>", { noremap = true })
-- resize windows with hjkl
map("n", "<C-h>", "5<C-w><", { noremap = true })
map("n", "<C-j>", "5<C-w>-", { noremap = true })
map("n", "<C-k>", "5<C-w>+", { noremap = true })
map("n", "<C-l>", "5<C-w>>", { noremap = true })
-- Move Lines
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Up" })
-- quickfix window
map("n", "<C-p>", "<cmd>lprev<cr>", { noremap = true })
map("n", "<C-n>", "<cmd>lnext<cr>", { noremap = true })
--- F keys
map("n", "<F1>", "<cmd>Lazy<cr>", { noremap = true })
map("n", "<F5>", "<cmd>checkt<cr>", { noremap = true })

-- VISUALS
vim.o.guicursor = "n-v-c:block-CustomCursor,i:ver100-CustomICursor,n-v-c:blinkon0,i:blinkwait10"
-- https://codeyarns.com/tech/2011-07-29-vim-chart-of-color-names.html
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_set_hl(0, "CustomCursor", { fg = "salmon1", bg = "cyan" })
        vim.api.nvim_set_hl(0, "CustomICursor", { fg = "salmon1", bg = "cyan" })
        vim.api.nvim_set_hl(0, "ColorColumn", { bg = "salmon4" })
    end,
})

-- reload
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

-- ----------------------------------------
-- LSP
-- ----------------------------------------

local function lspsetup()
    vim.lsp.set_log_level(2)
    vim.keymap.set("n", "<leader>ll", "<cmd>e ~/.local/state/nvim/lsp.log<cr>", { noremap = true })
    local lspgroup = vim.api.nvim_create_augroup("lsp", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = lspgroup,
        callback = function(ev)
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
            local diag = vim.diagnostic
            local severity = diag.severity.HINT
            local keyspec = {
                -- workspaces
                -- { "<leader>wa", vim.lsp.buf.add_workspace_folder },
                -- { "<leader>wr", vim.lsp.buf.remove_workspace_folder },
                -- { "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end },
                -- jump
                { "<M-i>", function() diag.open_float({ source = true }) end },
                { "<M-n>", function() diag.jump({ severity = { min = severity }, float = true, count = 1 }) end },
                { "<M-p>", function() diag.jump({ severity = { min = severity }, float = true, count = -1 }) end },
                { "gd", vim.lsp.buf.definition },
                { "gD", vim.lsp.buf.type_definition },
                { "gi", vim.lsp.buf.declaration },
                { "gI", vim.lsp.buf.implementation },
                -- quickfix
                { "gl", diag.setloclist },
                { "gr", function() vim.lsp.buf.references({ includeDeclaration = false }) end },
                -- popups
                { "<M-x>", vim.lsp.buf.signature_help, { "n", "i" } },
                -- symbols
                -- { "<leader>ds", vim.lsp.buf.document_symbol },
                -- { "<leader>ws", vim.lsp.buf.workspace_symbol },
                -- other
                { "K", vim.lsp.buf.hover },
                { "<M-r>", vim.lsp.buf.rename },
                { "<leader>ca", vim.lsp.buf.code_action, { "n", "x" } },
            }
            for _, key in ipairs(keyspec) do
                vim.keymap.set(key[3] or { "n" }, key[1], key[2], { buffer = ev.buf })
            end
        end,
    })
    vim.api.nvim_create_user_command("LspStop", function(kwargs)
        local name = kwargs.fargs[1]
        for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
            client:stop()
        end
    end, {
        nargs = "?",
        complete = function()
            return vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients())
        end,
    })

    vim.api.nvim_create_user_command("LspRestart", function(kwargs)
        local name = kwargs.fargs[1]
        for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
            local bufs = vim.lsp.get_buffers_by_client_id(client.id)
            client:stop()
            vim.wait(30000, function() return vim.lsp.get_client_by_id(client.id) == nil end)
            local client_id = vim.lsp.start(client.config, { attach = nil })
            if client_id then
                for _, buf in ipairs(bufs) do
                    vim.lsp.buf_attach_client(buf, client_id)
                end
            end
        end
    end, {
        nargs = "?",
        complete = function()
            return vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients())
        end,
    })
    vim.api.nvim_create_autocmd("LspProgress", {
        group = lspgroup,
        callback = function(args)
            local function is_blocking()
                local mode = vim.api.nvim_get_mode()
                for _, m in ipairs({ "ic", "ix", "c", "no", "r%?", "rm" }) do
                    if mode.mode:find(m) == 1 then return true end
                end
                return mode.blocking
            end
            local update_delay_ms = 300
            local last_update = 0
            local current_time = vim.uv.now()
            if is_blocking() or (current_time - last_update) < update_delay_ms then return end
            last_update = current_time

            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local value = args.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin"|"report"|"end"}]]
            if not client or type(value) ~= "table" then return end
            local progress = vim.defaulttable()
            local p = progress[client.id]

            for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == args.data.params.token then
                    p[1] = {
                        token = args.data.params.token,
                        msg = ("[%3d%%] %s%s"):format(
                            value.kind == "end" and 100 or value.percentage or 100,
                            value.title or "",
                            value.message and (" **%s**"):format(value.message) or ""
                        ),
                        done = value.kind == "end",
                    }
                    break
                end
            end

            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v) return table.insert(msg, v.msg) or not v.done end, p)

            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(table.concat(msg, "\n"), "info", {
                id = "lsp_progress",
                title = client.name,
                timeout = 1200,
                level = 5000,
                width = { min = 50, max = 50 },
                opts = function(notif)
                    ---@diagnostic disable-next-line: missing-fields
                    notif.icon = #progress[client.id] == 0 and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end,
    })

    vim.lsp.config("*", { root_markers = { ".git" } })
    vim.lsp.config["lua_ls"] = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
            ".luarc.json",
            ".luarc.jsonc",
            ".stylua.toml",
            "stylua.toml",
            ".git",
        },
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
    }
    vim.lsp.enable("lua_ls")
    vim.lsp.config["pyright"] = {
        cmd = { "pyright-langserver", "--stdio", "--threads", "20" },
        filetypes = { "python" },
        root_markers = {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "pyrightconfig.json",
            ".git",
        },
        settings = {
            python = {
                analysis = {
                    -- logLevel = "Trace",
                    autoImportCompletions = false,
                    diagnosticMode = "openFilesOnly",
                    useLibraryCodeForTypes = false,
                    -- logTypeEvaluationTime = true,
                    -- typeEvaluationTimeThreshold = 5000,
                },
            },
        },
    }
    vim.lsp.enable("pyright")
    vim.lsp.config["html"] = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        settings = {
            html = {
                format = {
                    templating = true,
                    wrapLineLength = 120,
                    wrapAttributes = "auto",
                },
                hover = {
                    documentation = true,
                    references = true,
                },
            },
        },
    }
    vim.lsp.enable("html")
    vim.lsp.config["yaml"] = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml" },
        settings = {
            yaml = {
                schemas = { kubernetes = "/home/hjalmarlucius/src/hjarl/system/manifests/*.yaml" },
                -- schemaStore = { enable = false, url = "" },
            },
        },
    }
    vim.lsp.enable("yaml")
    vim.lsp.config["typst"] = {
        cmd = { "tinymist" },
        filetypes = { "typst" },
        settings = {},
    }
    vim.lsp.enable("typst")
    vim.lsp.config["bash"] = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "bash", "sh" },
    }
    vim.lsp.enable("bash")
    vim.lsp.config["js"] = {
        cmd = { "vtsls", "--stdio" },
        root_markers = { ".git", "package.json", "tsconfig.json", "jsconfig.json" },
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },
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
    }
    vim.lsp.enable("js")
end
lspsetup()

-- ----------------------------------------
-- SPECS
-- ----------------------------------------

local function makespecs_themes()
    return {
        "NLKNguyen/papercolor-theme",
        "junegunn/seoul256.vim",
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
            "sonph/onehalf",
            lazy = false,
            config = function(plugin) vim.opt.rtp:append(plugin.dir .. "/vim") end,
        },
        {
            "catppuccin/nvim",
            lazy = false,
            name = "catppuccin",
            priority = 1000,
            config = function() vim.cmd([[colorscheme catppuccin-mocha]]) end,
        },
        {
            "Shatur/neovim-ayu",
            init = function() vim.g.ayu_extended_palette = 1 end,
        },
        "tomasr/molokai",
        "jnurmine/Zenburn",
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
                lualine_c = {
                    { "filename", file_status = true, path = 1, shorting_target = 0 },
                    { "filetype", icon_only = true, separator = " ", padding = { left = 1, right = 0 } },
                },
                lualine_x = {
                    { 'require("noice").api.status.message.get_hl()' },
                    { 'require("noice").api.status.command.get()', color = { fg = "#ff9e64" } },
                    { 'require("noice").api.status.mode.get()', color = { fg = "#ff9e64" } },
                },
                lualine_y = { "progress", "location" },
                lualine_z = { { function() return " " .. os.date("%R") end } },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    { "filename", file_status = true, path = 1, shorting_target = 0 },
                    { "filetype", icon_only = true, separator = " ", padding = { left = 1, right = 0 } },
                },
                lualine_x = {},
                lualine_y = { "progress", "location" },
                lualine_z = {},
            },
            tabline = {
                lualine_a = {
                    {
                        "buffers",
                        symbols = { alternate_file = "" },
                        buffers_color = {
                            active = { bg = "goldenrod" },
                        },
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
                        tabs_color = {
                            active = { bg = "goldenrod" },
                        },
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
        opts = {
            watch_for_changes = true,
            view_options = { show_hidden = true },
        },
        keys = {
            { "<leader>e", "<cmd>Oil .<cr>", noremap = true },
            { "<leader>E", "<cmd>Oil --float .<cr>", noremap = true },
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
    return {
        {
            "nvim-neo-tree/neo-tree.nvim",
            version = false,
            cmd = { "Neotree" },
            dependencies = { "nvim-lua/plenary.nvim", "mini.icons", "MunifTanjim/nui.nvim" },
            opts = { hijack_netrw_behavior = "disabled" },
            keys = { { "<C-t>", "<cmd>Neotree<cr>", noremap = true } },
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
                { "<leader>gl", "<cmd>vertical Flogsplit -path=%<cr>" },
                { "<leader>gL", "<cmd>vertical Flogsplit<cr>" },
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
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", noremap = true },
            { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", noremap = true },
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
                    vim.opt.foldmethod = "syntax"
                    vim.opt.foldlevel = 0
                end,
            })
        end,
        keys = {
            { "<C-g>", "<cmd>vertical Git<cr>" },
            { "<leader>gp", "<cmd>Git! push<cr>" },
            { "<leader>gP", "<cmd>Git! push -f<cr>" },
        },
    }
end

local function makespec_gitsigns()
    local function on_gitsigns_attach(bufnr)
        local gs = require("gitsigns")
        local function next_hunk()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
        end
        local function prev_hunk()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
        end

        local function bmap(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        bmap("n", "<M-,>", next_hunk, { expr = true })
        bmap("n", "<M-.>", prev_hunk, { expr = true })

        -- Actions
        bmap("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
        bmap("v", "<leader>gx", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
        bmap("n", "<leader>gs", gs.stage_hunk)
        bmap("n", "<leader>gx", gs.reset_hunk)
        bmap("n", "<leader>gu", gs.undo_stage_hunk)
        bmap("n", "<leader>gi", gs.preview_hunk)
        bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end)
        bmap("n", "<leader>gB", gs.blame)
        bmap("n", "<leader>gS", gs.stage_buffer)
        bmap("n", "<leader>gX", gs.reset_buffer)
        bmap("n", "<leader>td", gs.toggle_deleted)
        bmap("n", "<leader>tl", gs.toggle_linehl)
        bmap("n", "<leader>tb", gs.toggle_current_line_blame)
        bmap("n", "<leader>th", gs.toggle_word_diff)
        bmap("n", "<leader>tn", gs.toggle_numhl)

        -- Text object
        bmap({ "o", "x" }, "ih", "<cmd><C-U>Gitsigns select_hunk<CR>")
    end

    return {
        "lewis6991/gitsigns.nvim",
        opts = {
            signcolumn = true,
            numhl = true,
            linehl = false,
            word_diff = false,
            signs_staged_enable = false,
            on_attach = on_gitsigns_attach,
            -- extra thin lines
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "▎" },
                topdelete = { text = "▎" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            signs_staged = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "▎" },
                topdelete = { text = "▎" },
                changedelete = { text = "▎" },
            },
        },
    }
end

local function makespec_snacks()
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
        },
        -- stylua: ignore
        keys = {
            { "<leader>R", function() Snacks.rename.rename_file() end, desc = "Rename File" },
            { "<M-d>", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
            { "<leader>G", function() Snacks.lazygit() end, desc = "Launch Lazygit" },
            { "<leader>.", function() Snacks.scratch.open() end, desc = "Scratch Buffer" },
            -- find
            { "<M-f>", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
            { "<M-F>", function() Snacks.picker.files() end, desc = "Find Files" },
            { "<M-b>", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
            { "<leader>d", function() Snacks.picker.files({ cwd = "/home/hjalmarlucius/dotfiles" }) end, desc = "Find Config" },
            { "<leader>n", function() Snacks.picker.files({ cwd = "/home/hjalmarlucius/notes" }) end, desc = "Find Note", },
            -- search
            { "<F4>", function() Snacks.picker.help() end, desc = "Help Pages" },
            { "<F9>", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
            { "<M-w>", function() Snacks.picker.grep() end, desc = "Grep" },
            { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" }, },
            { "<leader>/", function() Snacks.picker.search_history() end, desc = "Search History" },
            { "<leader>b", function() Snacks.picker.lines() end, desc = "Grep Buffer" },
            { "<leader>B", function() Snacks.picker.grep_buffers() end, desc = "Grep Buffers" },
            { "<leader>D", function() Snacks.picker.grep({ cwd = "/home/hjalmarlucius/dotfiles" }) end, desc = "Find Config Content" },
            { "<leader>N", function() Snacks.picker.grep({ cwd = "/home/hjalmarlucius/notes" }) end, desc = "Find Notes Content", },
            { "<leader>i", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
            { "<leader>l", function() Snacks.picker.loclist() end, desc = "Location List" },
            { "<leader>h", function() Snacks.picker.notifications() end, desc = "Notification History" },
            { "<leader>p", function() Snacks.picker.projects() end, desc = "Find Projects" },
            { "<leader>q", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
            { "<leader>ø", function() Snacks.picker.command_history() end, desc = "Command History" },
            { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
            { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
            { "<leader>u", function() Snacks.picker.undo() end, desc = "Undo History" },
        },
    }
end

local function makespecs_mini()
    return {
        {
            "echasnovski/mini.basics",
            opts = { options = { basic = true, extra_ui = true }, mappings = { move_with_alt = true } },
        },
        { "echasnovski/mini.icons", opts = {} },
        { "echasnovski/mini.surround", version = false, opts = {} },
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
            highlight = { keyword = "bg", pattern = [[.*<(KEYWORDS)\s*:]] },
            search = { pattern = [[\b(KEYWORDS)\b]] },
            colors = {
                error = { "#ba1a1a" },
                warning = { "#FFC107" },
                info = { "#91BED0" },
                hint = { "#10B981" },
                default = { "#91D0C1" },
            },
        },
        keys = { { "<F6>", "<cmd>TodoQuickFix<cr>", noremap = true } },
    }
end

local function makespec_tmuxnav()
    return {
        -- tmux / vim interop
        "alexghergh/nvim-tmux-navigation",
        config = function()
            require("nvim-tmux-navigation").setup({
                disable_when_zoomed = true, -- defaults to false
                keybindings = {
                    left = "<M-h>",
                    down = "<M-j>",
                    up = "<M-k>",
                    right = "<M-l>",
                    last_active = "<M-\\>",
                },
            })
        end,
    }
end

local function makespec_mason()
    return {
        "williamboman/mason.nvim",
        lazy = false,
        opts = {},
        keys = { { "<F2>", "<cmd>Mason<cr>", noremap = true } },
    }
end

local function makespec_flash()
    return {
        "folke/flash.nvim",
        opts = {},
        keys = {
            { "<cr>", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            {
                "<M-cr>",
                mode = { "n", "o", "x" },
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter",
            },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            {
                "R",
                mode = { "o", "x" },
                function() require("flash").treesitter_search() end,
                desc = "Treesitter Search",
            },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
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
                "<leader>r",
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
                    "python",
                    "regex",
                    "vimdoc",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true, disable = { "python" }, additional_vim_regex_highlighting = { "python" } },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_decremental = "<M-k>",
                        node_incremental = "<M-j>",
                        scope_incremental = "<M-n>",
                    },
                },
            },
        },
        config = function() vim.opt.foldexpr = "nvim_treesitter#foldexpr()" end,
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
            {
                "n",
                [[n<Cmd>lua require('hlslens').start()<CR>]],
                mode = { "n", "x" },
                noremap = true,
                silent = true,
            },
            {
                "N",
                [[N<Cmd>lua require('hlslens').start()<CR>]],
                mode = { "n", "x" },
                noremap = true,
                silent = true,
            },
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
            { "<leader>f", function() require("conform").format() end, silent = true, noremap = true },
            { "<leader>lf", "<cmd>e ~/.local/state/nvim/conform.log<cr>", noremap = true },
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
                yaml = { "yamlfix", "yamlfmt" },
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
                    append_args = {
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
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {
            cmdline = { enabled = true, view = "cmdline_popup" },
            messages = {
                enabled = true, -- enables the Noice messages UI
                view = "mini", -- default view for messages
                view_error = "notify", -- view for errors
                view_warn = "mini", -- view for warnings
                view_history = "popup", -- view for :messages
                view_search = false,
            },
            popupmenu = { enabled = true },
            notify = { enabled = true, view = "mini" },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
                progress = { enabled = false },
                hover = { enabled = true },
                signature = { enabled = true, auto_open = { enabled = true, throttle = 0 } },
                message = { enabled = true, view = "notify" },
                documentation = { view = "hover" },
            },
            -- you can enable a preset for easier configuration
            presets = {
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
            },
            routes = {
                { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
                { filter = { kind = "", min_height = 2 }, view = "split" },
            },
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
    makespec_snacks(),
    makespec_conform(), -- autoformat
    makespec_treesitter(),
    makespec_todocomments(),
    makespec_autotag(),
    makespec_lint(),
    makespec_mason(),
    -- navigation
    makespec_tmuxnav(),
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
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})
