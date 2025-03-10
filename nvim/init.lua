vim.opt.termguicolors = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
map("n", "<leader>e", [[:vnew ~/dotfiles/nvim/init.lua<cr>]], { noremap = true })
map("n", "<leader>ww", [[:cd %:p:h<cr>]], { noremap = true })
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

-- ----------------------------------------
-- PLUGINS
-- ----------------------------------------

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
    spec = {
        -- mini
        {
            "echasnovski/mini.basics",
            opts = {
                options = { basic = true, extra_ui = true },
                mappings = { move_with_alt = true },
            },
        },
        {
            "smoka7/hop.nvim",
            opts = {},
            cmd = {
                "HopWord",
                "HopCamelCase",
                "HopChar1",
                "HopChar2",
                "HopPattern",
                "HopLine",
                "HopLineStart",
                "HopAnywhere",
                "HopNodes",
                "HopPaste",
                "HopYankChar1",
            },
            keys = {
                { "<CR>", "<cmd>HopWord<cr>", mode = { "n", "v" }, silent = true, noremap = true },
                { "<M-CR>", "<cmd>HopAnywhere<cr>", mode = { "n", "v" }, silent = true, noremap = true },
                {
                    "f",
                    function()
                        require("hop").hint_char1({
                            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                            current_line_only = true,
                        })
                    end,
                    mode = { "n", "v", "o" },
                    remap = true,
                },
                {
                    "F",
                    function()
                        require("hop").hint_char1({
                            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                            current_line_only = true,
                        })
                    end,
                    mode = { "n", "v", "o" },
                    remap = true,
                },
                {
                    "t",
                    function()
                        require("hop").hint_char1({
                            direction = require("hop.hint").HintDirection.AFTER_CURSOR,
                            current_line_only = true,
                            hint_offset = -1,
                        })
                    end,
                    mode = { "n", "v", "o" },
                    remap = true,
                },
                {
                    "T",
                    function()
                        require("hop").hint_char1({
                            direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
                            current_line_only = true,
                            hint_offset = 1,
                        })
                    end,
                    mode = { "n", "v", "o" },
                    remap = true,
                },
            },
        },
        {
            "echasnovski/mini.icons",
            opts = {},
        },
        {
            "echasnovski/mini.surround",
            version = false,
            opts = {},
        },
        {
            "echasnovski/mini.bufremove",
            version = false,
            opts = {},
            keys = {
                { "<M-d>", function() require("mini.bufremove").wipeout() end, noremap = true },
                { "<M-D>", function() require("mini.bufremove").wipeout(nil, true) end, noremap = true },
            },
        },
        -- snacks
        {
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
                notifier = { enabled = true },
                indent = { enabled = true },
                quickfile = { enabled = true },
                image = { enabled = true },
            },
        },
        -- file management
        {
            "nvim-neo-tree/neo-tree.nvim",
            version = false,
            cmd = { "Neotree" },
            dependencies = { "nvim-lua/plenary.nvim", "mini.icons", "MunifTanjim/nui.nvim" },
            opts = { hijack_netrw_behavior = "disabled" },
            keys = { { "<C-t>", "<cmd>Neotree<cr>", noremap = true } },
        },
        {
            "stevearc/oil.nvim",
            dependencies = { "mini.icons" },
            cmd = { "Oil" },
            opts = {
                watch_for_changes = true,
                view_options = { show_hidden = true },
            },
            keys = {
                { "<leader>b", "<cmd>Oil .<cr>", noremap = true },
                { "<leader>B", "<cmd>Oil --float .<cr>", noremap = true },
            },
        },
        -- div utils
        "tpope/vim-eunuch", -- Move, Rename etc
        "tpope/vim-sleuth", -- do the right thing with tabstop and softtabstop
        "dhruvasagar/vim-table-mode", -- tables
        "itchyny/vim-qfedit", -- editable quickfix list
        {
            -- keep location upon reopening
            "ethanholz/nvim-lastplace",
            opts = {},
        },
        {
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
        },
        {
            "chomosuke/typst-preview.nvim",
            lazy = false, -- or ft = 'typst'
            version = "1.*",
            opts = {
                debug = true,
                port = 10010,
                dependencies_bin = { ["tinymist"] = "tinymist" },
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
            -- search count > 99
            "kevinhwang91/nvim-hlslens",
            dependencies = { "haya14busa/vim-asterisk" },
            cmd = { "HlSearchLensDisable", "HlSearchLensEnable", "HlSearchLensToggle" },
            opts = { nearest_only = true },
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
        },
        {
            "catgoose/nvim-colorizer.lua",
            event = "BufReadPre",
            opts = { user_default_options = { mode = "virtualtext" } },
        },
        -- theme dark and light
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
        -- theme dark only
        "tomasr/molokai",
        "jnurmine/Zenburn",
        -- status + buffer lines
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "echasnovski/mini.icons", "folke/noice.nvim" },
            opts = {
                options = { theme = "auto", globalstatus = false },
                extensions = { "fugitive" },
                sections = {
                    lualine_a = { { "mode", color = { bg = "goldenrod" } } },
                    lualine_b = { "branch" },
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 1,
                            shorting_target = 0,
                        },
                        { "diff", colored = true },
                    },
                    lualine_x = {
                        { "require('noice').api.status.command.get()" },
                        { "require('noice').api.status.mode.get()" },
                    },
                    lualine_y = { "filetype", "progress" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            file_status = true,
                            path = 1,
                            shorting_target = 0,
                        },
                        { "diff", colored = true },
                    },
                    lualine_x = {},
                    lualine_y = { "filetype", "progress" },
                    lualine_z = { "location" },
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
        },
        -- git related plugins
        {
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
        },
        {
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
                { "<leader>gB", "<cmd>Git blame<cr>" },
                { "<leader>gp", "<cmd>Git! push<cr>" },
                { "<leader>gP", "<cmd>Git! push -f<cr>" },
            },
        },
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
        {
            "lewis6991/gitsigns.nvim",
            opts = {
                signcolumn = true,
                numhl = true,
                linehl = false,
                word_diff = false,
                signs_staged_enable = false,
                on_attach = function(bufnr)
                    local gs = require("gitsigns")

                    local function bmap(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    bmap("n", "<M-,>", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function() gs.next_hunk() end)
                        return "<Ignore>"
                    end, { expr = true })

                    bmap("n", "<M-.>", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function() gs.prev_hunk() end)
                        return "<Ignore>"
                    end, { expr = true })

                    -- Actions
                    bmap("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
                    bmap("v", "<leader>gx", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
                    bmap("n", "<leader>gs", gs.stage_hunk)
                    bmap("n", "<leader>gx", gs.reset_hunk)
                    bmap("n", "<leader>gu", gs.undo_stage_hunk)
                    bmap("n", "<leader>gi", gs.preview_hunk)
                    bmap("n", "<leader>gb", function() gs.blame_line({ full = true }) end)
                    bmap("n", "<leader>gS", gs.stage_buffer)
                    bmap("n", "<leader>gX", gs.reset_buffer)
                    bmap("n", "<leader>td", gs.toggle_deleted)
                    bmap("n", "<leader>tl", gs.toggle_linehl)
                    bmap("n", "<leader>tb", gs.toggle_current_line_blame)
                    bmap("n", "<leader>th", gs.toggle_word_diff)
                    bmap("n", "<leader>tn", gs.toggle_numhl)

                    -- Text object
                    bmap({ "o", "x" }, "ih", "<cmd><C-U>Gitsigns select_hunk<CR>")
                end,
            },
        },
        { -- helplists
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
        },
        {
            -- Fuzzy Finder (files, lsp, etc)
            "nvim-telescope/telescope.nvim",
            version = false,
            dependencies = {
                "sharkdp/fd",
                "nvim-lua/plenary.nvim",
                "nvim-telescope/telescope-live-grep-args.nvim",
            },
            keys = {
                {
                    "<M-F>",
                    function() require("telescope.builtin").find_files({ layout_config = { width = 0.99 } }) end,
                    noremap = true,
                },
                {
                    "<M-f>",
                    function()
                        local cwd = vim.fn.getcwd()
                        vim.fn.system("git rev-parse --is-inside-work-tree")
                        local is_inside_work_tree = vim.v.shell_error == 0
                        local opts = { layout_config = { width = 0.99 } }
                        if is_inside_work_tree then
                            require("telescope.builtin").git_files(opts)
                        else
                            require("telescope.builtin").find_files(opts)
                        end
                    end,
                    noremap = true,
                },
                {
                    "<M-e>",
                    function()
                        require("telescope.builtin").diagnostics({
                            layout_strategy = "vertical",
                            layout_config = { width = 0.99 },
                        })
                    end,
                    noremap = true,
                },
                {
                    "<M-w>",
                    function() require("telescope").extensions.live_grep_args.live_grep_args() end,
                    noremap = true,
                },
                { "<M-y>", function() require("telescope.builtin").filetypes() end, noremap = true },
                { "<M-H>", function() require("telescope.builtin").search_history() end, noremap = true },
                {
                    "<F9>",
                    function()
                        require("telescope.builtin").colorscheme({
                            layout_config = { width = 0.5 },
                            enable_preview = true,
                            ignore_builtins = true,
                        })
                    end,
                    noremap = true,
                },
            },
            config = function()
                -- TODO grep with regex
                local actions = require("telescope.actions")
                require("telescope").setup({
                    defaults = {
                        layout_config = { horizontal = { width = 0.99 } },
                        mappings = {
                            i = {
                                ["<esc>"] = "close",
                                ["<CR>"] = "select_default",
                                ["<C-j>"] = "move_selection_next",
                                ["<C-k>"] = "move_selection_previous",
                                ["<C-b>"] = "preview_scrolling_up",
                                ["<C-f>"] = "preview_scrolling_down",
                                ["<C-s>"] = "select_horizontal",
                                ["<C-v>"] = "select_vertical",
                                ["<C-t>"] = "select_tab",
                                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                                ["<Tab>"] = actions.toggle_selection + actions.move_selection_better,
                                ["<C-q>"] = actions.send_to_loclist + actions.open_loclist,
                                ["<M-q>"] = actions.send_selected_to_loclist + actions.open_loclist,
                                ["<M-p>"] = require("telescope.actions.layout").toggle_preview,
                                ["<PageUp>"] = "results_scrolling_up",
                                ["<PageDown>"] = "results_scrolling_down",
                            },
                            n = { ["<M-p>"] = require("telescope.actions.layout").toggle_preview },
                        },
                        file_ignore_patterns = {},
                        set_env = { ["COLORTERM"] = "truecolor" },
                    },
                })
            end,
        },
        {
            "debugloop/telescope-undo.nvim",
            dependencies = {
                {
                    "nvim-telescope/telescope.nvim",
                    dependencies = { "nvim-lua/plenary.nvim" },
                },
            },
            keys = {
                {
                    "<M-u>",
                    function() require("telescope").extensions.undo.undo() end,
                    desc = "undo history",
                },
            },
            opts = {
                extensions = {
                    undo = {
                        side_by_side = true,
                        vim_diff_opts = { ctxlen = vim.o.scrolloff },
                        entry_format = "state #$ID, $STAT, $TIME",
                        time_format = "%H:%M:%S %m/%d/%Y",
                        saved_only = false,
                        layout_strategy = "vertical",
                        layout_config = { preview_height = 0.6, width = 0.99 },
                    },
                },
            },
            config = function(_, opts)
                -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
                -- configs for us. We won't use data, as everything is in it's own namespace (telescope
                -- defaults, as well as each extension).
                require("telescope").setup(opts)
                require("telescope").load_extension("undo")
            end,
        },
        {
            "kevinhwang91/nvim-ufo",
            dependencies = { "kevinhwang91/promise-async" },
            opts = {
                preview = {
                    mappings = {
                        scrollU = "<C-u>",
                        scrollD = "<C-d>",
                        jumpTop = "[",
                        jumpBot = "]",
                    },
                },
                fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                    local newVirtText = {}
                    local suffix = (" 󰁂 %d "):format(endLnum - lnum)
                    local sufWidth = vim.fn.strdisplaywidth(suffix)
                    local targetWidth = width - sufWidth
                    local curWidth = 0
                    for _, chunk in ipairs(virtText) do
                        local chunkText = chunk[1]
                        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if targetWidth > curWidth + chunkWidth then
                            table.insert(newVirtText, chunk)
                        else
                            chunkText = truncate(chunkText, targetWidth - curWidth)
                            local hlGroup = chunk[2]
                            table.insert(newVirtText, { chunkText, hlGroup })
                            chunkWidth = vim.fn.strdisplaywidth(chunkText)
                            -- str width returned from truncate() may less than 2nd argument, need padding
                            if curWidth + chunkWidth < targetWidth then
                                suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
                            end
                            break
                        end
                        curWidth = curWidth + chunkWidth
                    end
                    table.insert(newVirtText, { suffix, "MoreMsg" })
                    return newVirtText
                end,
            },
            keys = {
                -- zm/M zr/R increase/increase foldlevel (max)
                -- zo/O zc/C open / close fold (max)
                -- za zA switch fold (small/full)
                -- zi toggle folds
                -- zi zj move to next / prev fold
                {
                    "zR",
                    function() require("ufo").openAllFolds() end,
                },
                {
                    "zM",
                    function() require("ufo").closeAllFolds() end,
                },
                {
                    "zm",
                    function() require("ufo").closeFoldsWith() end,
                },
                {
                    "zr",
                    function() require("ufo").openFoldsExceptKinds() end,
                },
            },
            init = function()
                vim.o.foldcolumn = "0"
                vim.o.foldlevel = 99
                vim.o.foldlevelstart = 99
                vim.o.foldenable = true
            end,
        },
        {
            -- Highlight, edit, and navigate code
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
        },
        {
            "windwp/nvim-ts-autotag",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            opts = { filetypes = { "html", "xml" } },
        },
        -- package manager + lsp stuff
        {
            "williamboman/mason.nvim",
            lazy = false,
            opts = {},
            keys = { { "<F2>", "<cmd>Mason<cr>", noremap = true } },
        },
        {
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
        },
        {
            "mhartington/formatter.nvim", -- TODO move to conform
            -- Utilities for creating configurations,
            keys = {
                { "<leader>f", "<cmd>Format<cr>", silent = true, noremap = true },
                { "<leader>F", "<cmd>FormatWrite<cr>", silent = true, noremap = true },
            },
            config = function()
                require("formatter").setup({
                    logging = true,
                    log_level = vim.log.levels.DEBUG,
                    filetype = {
                        python = {
                            function()
                                return {
                                    exe = "ruff",
                                    args = { "check", "--select I,F,UP", "--fix-only", "-" },
                                    stdin = true,
                                }
                            end,
                            function()
                                return {
                                    exe = "ruff",
                                    args = { "format", "-" },
                                    stdin = true,
                                }
                            end,
                        },
                        lua = {
                            function()
                                local util = require("formatter.util")
                                return {
                                    exe = "stylua",
                                    args = {
                                        "--search-parent-directories",
                                        "--indent-type Spaces",
                                        "--collapse-simple-statement Always",
                                        "--stdin-filepath",
                                        util.escape_path(util.get_current_buffer_file_path()),
                                        "--",
                                        "-",
                                    },
                                    stdin = true,
                                }
                            end,
                        },
                        yaml = {
                            function()
                                return {
                                    exe = "yamlfmt",
                                    args = {
                                        "-formatter indentless_arrays=true,retain_line_breaks=true,line_ending=lf,max_line_length=100,pad_line_comments=2",
                                        "-in",
                                    },
                                    stdin = true,
                                }
                            end,
                        },
                        typst = {
                            function()
                                return {
                                    exe = "typstyle",
                                    stdin = true,
                                }
                            end,
                        },
                        typescript = {
                            function()
                                local util = require("formatter.util")
                                return {
                                    exe = "eslint_d",
                                    args = {
                                        "--stdin",
                                        "--debug",
                                        "--stdin-filename",
                                        util.escape_path(util.get_current_buffer_file_path()),
                                        "--fix-to-stdout",
                                    },
                                    stdin = true,
                                    try_node_modules = true,
                                    ignore_exitcode = true,
                                }
                            end,
                        },
                        go = { require("formatter.filetypes.go").gofumpt, require("formatter.filetypes.go").golines },
                        sh = { require("formatter.filetypes.sh").shfmt },
                        javascript = { require("formatter.filetypes.javascript").prettierd },
                        html = { require("formatter.filetypes.html").prettierd },
                        css = { require("formatter.filetypes.css").prettierd },
                        markdown = { require("formatter.filetypes.markdown").prettierd },
                        json = { require("formatter.filetypes.json").jq },
                        ["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
                    },
                })
            end,
        },
        {
            "neovim/nvim-lspconfig",
            lazy = false,
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
                "kevinhwang91/nvim-ufo",
                { "j-hui/fidget.nvim", opts = {} },
            },
            event = { "BufReadPost", "BufNewFile" },
            cmd = { "LspInfo", "LspInstall", "LspUninstall" },
            keys = { { "<F3>", "<cmd>LspInfo<cr>", noremap = true } },
            config = function()
                local on_attach = function(client, bufnr)
                    local bmap = function(mode, keys, func)
                        vim.keymap.set(mode, keys, func, { buffer = bufnr, noremap = true })
                    end
                    -- workspaces
                    bmap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
                    bmap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
                    bmap("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end)
                    -- jump
                    bmap("n", "<M-i>", function() vim.diagnostic.open_float({ source = true }) end)
                    bmap(
                        "n",
                        "<M-n>",
                        function()
                            vim.diagnostic.jump({
                                severity = { min = vim.diagnostic.severity.HINT },
                                float = true,
                                count = 1,
                            })
                        end
                    )
                    bmap(
                        "n",
                        "<M-p>",
                        function()
                            vim.diagnostic.jump({
                                severity = { min = vim.diagnostic.severity.HINT },
                                float = true,
                                count = -1,
                            })
                        end
                    )
                    bmap("n", "gd", vim.lsp.buf.definition)
                    bmap("n", "gD", vim.lsp.buf.type_definition)
                    bmap("n", "gi", vim.lsp.buf.declaration)
                    bmap("n", "gI", vim.lsp.buf.implementation)
                    -- quickfix
                    bmap("n", "gl", vim.diagnostic.setloclist)
                    bmap("n", "gr", vim.lsp.buf.references)
                    -- popups
                    bmap({ "n", "i" }, "<M-x>", vim.lsp.buf.signature_help)
                    -- other
                    bmap("n", "K", function()
                        local winid = require("ufo").peekFoldedLinesUnderCursor()
                        if not winid then vim.lsp.buf.hover() end
                    end)
                    bmap("n", "<M-r>", vim.lsp.buf.rename)
                    bmap("n", "<leader>ca", vim.lsp.buf.code_action)
                end

                local server_configs = {
                    pyright = {
                        python = {
                            analysis = { autoImportCompletions = false, diagnosticMode = "openFilesOnly" },
                        },
                    },
                    lua_ls = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                                -- Make the server aware of Neovim runtime files
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                            telemetry = { enable = false },
                            diagnostics = {
                                -- Get the language server to recognize the `vim` global in init.lua
                                globals = { "vim", "core" },
                            },
                            format = { enable = false },
                        },
                    },
                    html = {
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
                    yamlls = {
                        yaml = {
                            schemas = { kubernetes = "/home/hjalmarlucius/src/hjarl/system/manifests/*.yaml" },
                            -- schemaStore = { enable = false, url = "" },
                        },
                    },
                }

                local capabilities = vim.lsp.protocol.make_client_capabilities()

                local ufo = require("ufo")
                if ufo then
                    capabilities.textDocument.foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true,
                    }
                end

                local mason_lspconfig = require("mason-lspconfig")
                mason_lspconfig.setup({
                    ensure_installed = {
                        "cssls",
                        "html",
                        "jsonls",
                        "yamlls",
                        "bashls",
                        "pyright",
                        "lua_ls",
                    },
                })
                mason_lspconfig.setup_handlers({
                    function(server_name)
                        require("lspconfig")[server_name].setup({
                            capabilities = capabilities,
                            on_attach = on_attach,
                            settings = server_configs[server_name],
                        })
                    end,
                })
            end,
        },
        {
            "folke/noice.nvim",
            event = "VeryLazy",
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
        },
    },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})
