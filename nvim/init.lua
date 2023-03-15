vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    -- tpope
    "tpope/vim-sensible", -- sensible default
    "tpope/vim-commentary", -- comment out stuff
    "tpope/vim-surround",
    "tpope/vim-repeat", -- repeat vim-surround with .
    "tpope/vim-eunuch", -- Move, Rename etc
    -- div utils
    "dhruvasagar/vim-table-mode", -- tables
    "itchyny/vim-qfedit", -- editable quickfix list
    {
        -- keep location upon reopening
        "ethanholz/nvim-lastplace",
        config = function()
            require("nvim-lastplace").setup()
        end,
    },
    "numToStr/Comment.nvim", -- 'gc' to comment visual regions/lines
    {
        -- tmux / vim interop
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
            vim.g.tmux_navigator_disable_when_zoomed = 1
            local map = vim.keymap.set
            local opts = { silent = true, noremap = true }
            map("n", "<M-h>", ":TmuxNavigateLeft<cr>", opts)
            map("n", "<M-j>", ":TmuxNavigateDown<cr>", opts)
            map("n", "<M-k>", ":TmuxNavigateUp<cr>", opts)
            map("n", "<M-l>", ":TmuxNavigateRight<cr>", opts)
        end,
    },
    {
        -- Add indentation guides even on blank lines
        "lukas-reineke/indent-blankline.nvim",
        opts = { show_trailing_blankline_indent = false },
    },
    {
        -- live preview of markdown files
        "iamcco/markdown-preview.nvim", -- requires yarn
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        config = function()
            vim.g.mkdp_auto_start = 0 -- auto start on moving into
            vim.g.mkdp_auto_close = 0 -- auto close on moving away
            vim.g.mkdp_open_to_the_world = 1 -- available to others
            vim.g.mkdp_port = 8555
            vim.g.mkdp_echo_preview_url = 1
        end,
    },
    {
        -- better asterisk search
        "haya14busa/vim-asterisk",
        config = function()
            vim.g["asterisk#keeppos"] = 1
            local map = vim.keymap.set
            map("", "*", "<Plug>(asterisk-z*)", {})
            map("", "#", "<Plug>(asterisk-z#)", {})
            map("", "g*", "<Plug>(asterisk-gz*)", {})
            map("", "g#", "<Plug>(asterisk-gz#)", {})
        end,
    },
    {
        -- folder tree
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            -- Unless you are still migrating, remove the deprecated commands from v1.x
            vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
            vim.keymap.set("n", "<C-t>", ":NeoTreeFocusToggle<cr>", { noremap = true })
        end,
    }, -- theme dark and light
    "NLKNguyen/papercolor-theme",
    "junegunn/seoul256.vim",
    "mhartington/oceanic-next",
    "morhetz/gruvbox",
    "sonph/onehalf",
    {
        "Shatur/neovim-ayu",
        config = function()
            vim.g.ayu_extended_palette = 1
        end,
    }, -- theme dark only
    "tomasr/molokai",
    "kdheepak/monochrome.nvim",
    "kcsongor/vim-monochrome-light",
    "jnurmine/Zenburn",
    {
        -- coloring of colornames
        "rrethy/vim-hexokinase",
        build = "cd /home/hjalmarlucius/.local/share/nvim/site/pack/packer/start/vim-hexokinase && make hexokinase",
        config = function()
            vim.g.Hexokinase_highlighters = { "virtual" }
        end,
    },
    {
        -- flashing cursor on move
        "danilamihailov/beacon.nvim",
        init = function()
            vim.api.nvim_exec([[highlight Beacon guibg=white ctermbg=15]], false)
        end,
        config = function()
            vim.g.beacon_size = 40
            vim.g.beacon_minimal_jump = 10
            vim.g.beacon_shrink = 1
        end,
    }, -- status + buffer lines
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "auto", globalstatus = false },
                extensions = { "fugitive" },
                sections = {
                    lualine_a = { "mode" },
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
                    lualine_x = {},
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
            })
        end,
    },
    {
        "akinsho/nvim-bufferline.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({ options = { diagnostics = "nvim_lsp" } })
            local map = vim.keymap.set
            map("n", "<M-J>", ":BufferLineCyclePrev<cr>", { noremap = true, silent = true })
            map("n", "<M-K>", ":BufferLineCycleNext<cr>", { noremap = true, silent = true })
            map("n", "<M-P>", ":BufferLineMovePrev<cr>", { noremap = true, silent = true })
            map("n", "<M-N>", ":BufferLineMoveNext<cr>", { noremap = true, silent = true })
        end,
    }, -- Git related plugins
    {
        "tpope/vim-fugitive",
        config = function()
            local map = vim.keymap.set
            map("", "<C-g>", ":vertical Git<cr>:vertical resize 60<cr>", {})
            map("", "<leader>gB", ":Git blame<cr>", {})
            map("", "<leader>gp", ":Git push<cr>", {})
            map("", "<leader>gP", ":Git push -f<cr>", {})
        end,
    },
    {
        "rbong/vim-flog",
        config = function()
            local map = vim.keymap.set
            map("", "<leader>gg", ":vertical Flogsplit<cr>", {})
            map("", "<leader>gG", ":vertical Flogsplit -path=%<cr>", {})
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signcolumn = true,
                numhl = true,
                linehl = false,
                word_diff = false,
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "<M-,>", function()
                        if vim.wo.diff then
                            return "]c"
                        end
                        vim.schedule(function()
                            gs.next_hunk()
                        end)
                        return "<Ignore>"
                    end, { expr = true })

                    map("n", "<M-.>", function()
                        if vim.wo.diff then
                            return "[c"
                        end
                        vim.schedule(function()
                            gs.prev_hunk()
                        end)
                        return "<Ignore>"
                    end, { expr = true })

                    -- Actions
                    map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>")
                    map({ "n", "v" }, "<leader>gx", ":Gitsigns reset_hunk<CR>")
                    map("n", "<leader>gu", gs.undo_stage_hunk)
                    map("n", "<leader>gi", gs.preview_hunk)
                    map("n", "<leader>gb", function()
                        gs.blame_line({ full = true })
                    end)
                    map("n", "<leader>gd", gs.diffthis)
                    map("n", "<leader>gS", gs.stage_buffer)
                    map("n", "<leader>gX", gs.reset_buffer)
                    map("n", "<leader>td", gs.toggle_deleted)
                    map("n", "<leader>tl", gs.toggle_linehl)
                    map("n", "<leader>tb", gs.toggle_current_line_blame)
                    map("n", "<leader>th", gs.toggle_word_diff)
                    map("n", "<leader>tn", gs.toggle_numhl)

                    -- Text object
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
                end,
            })
        end,
    }, -- helplists
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup({
                signs = true, -- show icons in the signs column
                sign_priority = 8, -- sign priority
                -- keywords recognized as todo comments
                keywords = {
                    ERROR = { icon = " ", color = "error" },
                    WIP = { icon = " ", color = "warning" },
                    TODO = { icon = " ", color = "warning" },
                    PERF = { icon = " ", color = "info" },
                    TEST = { icon = " ", color = "info" },
                    MAYBE = { icon = " ", color = "default" },
                    IDEA = { icon = " ", color = "hint" },
                },
                merge_keywords = false, -- when true, custom keywords will be merged with the defaults
                highlight = { keyword = "bg", pattern = [[<(KEYWORDS)\s*]] },
                search = { pattern = [[\b(KEYWORDS)\b]] },
                colors = {
                    error = { "#E15030" },
                    warning = { "#FBBF24" },
                    info = { "#91BED0" },
                    hint = { "#10B981" },
                    default = { "#91D0C1" },
                },
            })
        end,
    },
    {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-cmdline",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
            })
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
            })
            -- Set configuration for specific filetype.
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({
                    { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
                }, { { name = "buffer" } }),
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } },
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
            })
        end,
    }, -- Fuzzy Finder (files, lsp, etc)
    {
        "nvim-telescope/telescope.nvim",
        version = "*",
        dependencies = {
            "sharkdp/fd",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
        config = function()
            -- TODO grep with regex
            local map = vim.keymap.set
            local opts = { noremap = true }
            local actions = require("telescope.actions")
            map("n", "<M-F>", "<cmd>Telescope find_files<cr>", opts)
            map("n", "<M-f>", "<cmd>Telescope git_files<cr>", opts)
            map("n", "<M-w>", ':lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>', opts)
            map("n", "<M-y>", "<cmd>Telescope filetypes<cr>", opts)
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<esc>"] = actions.close,
                            ["<CR>"] = actions.select_default,
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-b>"] = actions.preview_scrolling_up,
                            ["<C-f>"] = actions.preview_scrolling_down,
                            ["<C-s>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_better,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<PageUp>"] = actions.results_scrolling_up,
                            ["<PageDown>"] = actions.results_scrolling_down,
                        },
                    },
                    file_ignore_patterns = {},
                    set_env = { ["COLORTERM"] = "truecolor" },
                },
            })
        end,
    },
    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        config = function()
            pcall(require("nvim-treesitter.install").update({ with_sync = true }))
            require("nvim-treesitter.configs").setup({
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true, disable = { "python" } },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_decremental = "<M-k>",
                        node_incremental = "<M-j>",
                        scope_incremental = "<M-n>",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = { ["<leader>a"] = "@parameter.inner" },
                        swap_previous = { ["<leader>A"] = "@parameter.inner" },
                    },
                },
            })
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
        end,
    }, -- context while scrolling
    {
        "romgrk/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("treesitter-context").setup({
                enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
                throttle = true, -- Throttles plugin updates (may improve performance)
                max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
                patterns = {
                    default = {
                        "class",
                        "function",
                        "method",
                        -- 'for', -- These won't appear in the context
                        -- 'while',
                        -- 'if',
                        -- 'switch',
                        -- 'case',
                    },
                    -- Example for a specific filetype.
                    -- If a pattern is missing, *open a PR* so everyone can benefit.
                    --   rust = {
                    --       'impl_item',
                    --   },
                },
            })
        end,
    }, -- package manager + lsp stuff
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
    },
    {
        -- autoinstalls stuff specified in null-ls
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = nil,
                automatic_setup = false,
                automatic_installation = true,
            })
            require("mason-null-ls").setup_handlers()
        end,
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            -- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.diagnostics.mypy,
                    null_ls.builtins.diagnostics.eslint_d,
                    null_ls.builtins.formatting.black.with({ extra_args = { "--preview" } }),
                    null_ls.builtins.formatting.eslint_d,
                    null_ls.builtins.formatting.isort,
                    null_ls.builtins.formatting.jq,
                    null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.formatting.shfmt.with({ extra_args = { "--indent", "4" } }),
                    null_ls.builtins.formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),
                    null_ls.builtins.formatting.yamlfmt,
                    null_ls.builtins.formatting.yq,
                },
                -- on_attach = function(client, bufnr)
                --     if client.supports_method("textDocument/formatting") then
                --         vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                --         vim.api.nvim_create_autocmd("BufWritePre", {
                --             group = augroup,
                --             buffer = bufnr,
                --             callback = function()
                --                 vim.lsp.buf.format({ bufnr = bufnr })
                --             end,
                --         })
                --     end
                -- end,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "j-hui/fidget.nvim",
            "folke/neodev.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local on_attach = function(client, bufnr)
                local bmap = function(mode, keys, func)
                    vim.keymap.set(mode, keys, func, { buffer = bufnr, noremap = true })
                end
                vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
                -- workspaces
                bmap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
                bmap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
                bmap("n", "<leader>wl", function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end)
                -- jump
                bmap("n", "<M-i>", function()
                    vim.diagnostic.open_float({ source = true })
                end)
                bmap("n", "<M-n>", function()
                    vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.INFO } })
                end)
                bmap("n", "<M-p>", function()
                    vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.INFO } })
                end)
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
                bmap("n", "K", vim.lsp.buf.hover)
                bmap("n", "<M-r>", vim.lsp.buf.rename)
                bmap("n", "<leader>ca", vim.lsp.buf.code_action)
                vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
                    vim.lsp.buf.format({ timeout_ms = 5000 })
                end, { desc = "Format current buffer with LSP" })
                bmap("n", "<leader>f", ":Format<cr>")
                if
                    client.server_capabilities.documentFormattingProvider
                    or client.server_capabilities.documentRangeFormattingProvider
                then
                    vim.api.nvim_command([[augroup Format]])
                    vim.api.nvim_command([[autocmd! * <buffer>]])
                    vim.api.nvim_command([[autocmd BufWritePre * lua vim.lsp.buf.format({ timeout_ms = 5000 })]])
                    vim.api.nvim_command([[augroup END]])
                end
            end

            local servers = {
                pyright = {
                    python = {
                        analysis = {
                            diagnosticMode = "workspace",
                            logLevel = "Warning",
                            typeCheckingMode = "basic",
                            autoImportCompletions = false,
                            venvPath = ".",
                        },
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
                            -- Get the language server to recognize the `vim` global
                            globals = { "vim" },
                        },
                        format = { -- disable formatting, stylua handles it
                            enable = false,
                        },
                    },
                },
                marksman = {},
                yamlls = {},
                tsserver = {},
                sqlls = {},
                html = {},
                eslint = {},
                dockerls = {},
                cssls = {},
                bashls = {},
            }
            require("fidget").setup()
            require("neodev").setup()

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({
                ensure_installed = vim.tbl_keys(servers),
            })
            mason_lspconfig.setup_handlers({
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                    })
                end,
            })
        end,
    },
    {
        "folke/noice.nvim",
        config = function()
            require("noice").setup({
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = false, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false, -- add a border to hover docs and signature help
                },
                messages = {
                    enabled = false,
                },
            })
        end,
        dependencies = { "MunifTanjim/nui.nvim" },
    },
})

-- ----------------------------------------
-- SETTINGS
-- ----------------------------------------

-- system
vim.o.shell = "/usr/bin/bash"
vim.o.fileencodings = "utf-8,ucs-bom,gb18030,gbk,gb2312,cp936"
vim.o.fileformats = "unix"
vim.o.swapfile = false
vim.o.backup = false
vim.o.updatetime = 300
vim.o.timeoutlen = 200
vim.g.BASH_Ctrl_j = "off"
vim.g.BASH_Ctrl_l = "off"

-- looks
vim.o.cmdheight = 1
-- vim.o.background = "dark"
vim.o.listchars = "tab:→ ,trail:·,extends:↷,precedes:↶,nbsp:+,eol:↵"
vim.o.list = true -- Show listchars
vim.o.showtabline = 2
vim.o.laststatus = 2

-- colors
vim.o.termguicolors = true
vim.g.seoul256_background = 233
vim.cmd("colorscheme seoul256")

-- undo
vim.o.undodir = "/home/hjalmarlucius/.cache/vim/undo"
vim.o.undofile = true
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- window
vim.o.splitbelow = true -- Put new windows below current
vim.o.splitright = true -- Put new windows right of current

-- buffer
vim.o.hidden = true -- Enable background buffers
vim.o.wrap = false -- Disable line wrap
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Relative line numbers
vim.o.cursorline = false -- Highlight current line
vim.o.switchbuf = "useopen" -- Use existing window if buffer is already open
vim.o.colorcolumn = "88"

-- diffs
vim.o.diffopt = "internal,filler,closeoff,hiddenoff,vertical,algorithm:patience"

-- tabs
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.smartindent = false -- Avoid fucking with comment indents
vim.o.shiftround = true -- Round indent
vim.o.tabstop = 4 -- Number of spaces tabs count for
vim.o.shiftwidth = 4 -- Size of an indent
vim.o.breakindent = true -- line breaks follow indents

-- search
vim.o.ignorecase = false -- Ignore case
vim.o.smartcase = false -- Do not ignore case with capitals
vim.o.wildignorecase = true
vim.opt.wildmode = { "full" } -- Command-line completion mode
vim.opt.wildignore = vim.opt.wildignore
    + {
        "*swp",
        "*.class",
        "*.pyc",
        "*.png",
        "*.jpg",
        "*.gif",
        "*.zip",
        "*/tmp/*",
        "*.o",
        ".obj",
        "*.so",
    }

-- cursor
vim.o.scrolloff = 5 -- Lines of context
vim.o.scrolljump = 1 -- Lines to scroll when cursor leaves screen
vim.o.sidescrolloff = 4 -- Columns of context
vim.o.showmatch = true -- Show matching brackets / parentheses

-- editing
vim.o.timeoutlen = 500 -- How long to wait during key combo
vim.o.langmap = "å(,¨),Å{,^},Ø\\;,ø:,æ^,+$"
vim.opt.clipboard = vim.opt.clipboard + { "unnamedplus" }

-- folding (also see treesitter)
-- zm/M zr/R increase/increase foldlevel (max)
-- zo/O zc/C open / close fold (max)
-- za zA switch fold (small/full)
-- zi toggle folds
-- zi zj move to next / prev fold
vim.o.foldenable = false
vim.o.foldmethod = "expr"

vim.o.completeopt = "menu,menuone,noinsert"

-- ----------------------------------------
-- AUTOCOMMANDS
-- ----------------------------------------
local cmd = vim.cmd

vim.api.nvim_command([[augroup MYAU]])
vim.api.nvim_command([[autocmd!]])
vim.api.nvim_command([[autocmd BufWritePre * %s/\s\+$//e]])
vim.api.nvim_command([[autocmd FileType python setlocal indentkeys-=<:>]])
vim.api.nvim_command([[autocmd BufReadPost quickfix nmap <buffer> <cr> <cr>]])
vim.api.nvim_command([[augroup END]])

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})
-- ----------------------------------------
-- MAPS
-- ----------------------------------------

local map = vim.keymap.set
map("n", "Q", "", { noremap = true })
map("n", "q:", "", { noremap = true })

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
map("n", "<leader>e", [[:vnew ~/dotfiles/nvim/init.lua<cr>]], { noremap = true })
map("n", "<leader>ww", [[:cd %:p:h<cN>]], { noremap = true })
map("n", "<esc><esc>", ":noh<cr>", { silent = true, noremap = true })
map("", "<F12>", "<esc>", { silent = true, noremap = true })

-- <Tab> to navigate the completion menu
map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true, noremap = true })
map("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true, noremap = true })

-- CURSOR
-- stay visual when indenting
map("n", "-", "_", { noremap = true })
map("v", "v", "<esc>", { noremap = true })
map("v", "<Tab>", ">gv", { noremap = true })
map("v", "<S-Tab>", "<gv", { noremap = true })
map("n", "<leader>o", "m`o<Esc>``", { noremap = true }) -- Insert a newline in normal mode
-- repeat and next
map("n", "\\", "n.", { noremap = true })

-- WINDOWS / BUFFERS
-- make splits and tabs
map("n", "<M-V>", ":vnew<cr>", { noremap = true })
map("n", "<M-S>", ":new<cr>", { noremap = true })
map("n", "<M-v>", ":vsplit<cr>", { noremap = true })
map("n", "<M-s>", ":split<cr>", { noremap = true })
map("n", "<M-t>", ":tabe %<cr>", { noremap = true })
map("n", "<M-T>", ":tabnew<cr>", { noremap = true })
-- buffers and tabs
map("n", "<M-J>", ":bprev<cr>", { noremap = true })
map("n", "<M-K>", ":bnext<cr>", { noremap = true })
map("n", "<M-H>", ":tabprev<cr>", { noremap = true })
map("n", "<M-L>", ":tabnext<cr>", { noremap = true })
-- resize windows with hjkl
map("n", "<C-h>", "5<C-w><", { noremap = true })
map("n", "<C-j>", "5<C-w>-", { noremap = true })
map("n", "<C-k>", "5<C-w>+", { noremap = true })
map("n", "<C-l>", "5<C-w>>", { noremap = true })
-- quickfix window
map("n", "<C-p>", ":cp<cr>", { noremap = true })
map("n", "<C-n>", ":cn<cr>", { noremap = true })
-- remove buffer
map("n", "<M-d>", ":bprev<bar>:bd#<cr>", { noremap = true })
map("n", "<M-D>", ":bprev<bar>:bd!#<cr>", { noremap = true })
--- F keys
map("n", "<F1>", ":Lazy<cr>", { noremap = true })
map("n", "<F2>", ":Mason<cr>", { noremap = true })
map("n", "<F3>", ":LspInfo<cr>", { noremap = true })
map("n", "<F4>", ":NullLsInfo<cr>", { noremap = true })
map("n", "<F5>", ":checkt<cr>", { noremap = true })
map("n", "<F6>", ":TodoQuickFix<cr>", { noremap = true })
map("n", "<F9>", '<cmd>lua require("telescope.builtin").colorscheme({enable_preview=1})<cr>', { noremap = true })

-- shit HACK
map("n", "<leader>b", ":!blackdoc %<cr>", { noremap = true })
