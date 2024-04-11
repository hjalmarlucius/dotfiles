vim.opt.termguicolors = true
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
    -- mini
    {
        "echasnovski/mini.basics",
        config = function()
            require("mini.basics").setup({
                options = {
                    basic = true,
                    extra_ui = true,
                },
                mappings = {
                    move_with_alt = true,
                },
            })
        end,
    },
    {
        "echasnovski/mini.base16",
        config = function()
            require("mini.base16").setup({
                palette = {
                    base00 = "#112641",
                    base01 = "#3a475e",
                    base02 = "#606b81",
                    base03 = "#8691a7",
                    base04 = "#d5dc81",
                    base05 = "#e2e98f",
                    base06 = "#eff69c",
                    base07 = "#fcffaa",
                    base08 = "#ffcfa0",
                    base09 = "#cc7e46",
                    base0A = "#46a436",
                    base0B = "#9ff895",
                    base0C = "#ca6ecf",
                    base0D = "#42f7ff",
                    base0E = "#ffc4ff",
                    base0F = "#00a5c5",
                },
                use_cterm = true,
                plugins = {
                    default = false,
                    ["echasnovski/mini.nvim"] = true,
                },
            })
        end,
    },
    {
        "echasnovski/mini.comment",
        config = function()
            require("mini.comment").setup({})
        end,
    },
    {
        "phaazon/hop.nvim",
        config = function()
            require("hop").setup({
                require("hop.highlight").insert_highlights(),
            })
            local map = vim.keymap.set
            local opts = { silent = true, noremap = true }
            map({ "n", "v" }, "<CR>", "<cmd>HopWord<cr>", opts)
        end,
    },
    {
        "echasnovski/mini.surround",
        version = false,
        config = function()
            require("mini.surround").setup()
        end,
    },
    {
        "echasnovski/mini.bufremove",
        config = function()
            local bufremove = require("mini.bufremove")
            bufremove.setup()
            local map = vim.keymap.set
            -- remove buffer
            map("n", "<M-d>", function()
                bufremove.wipeout()
            end, { noremap = true })
            map("n", "<M-D>", function()
                bufremove.wipeout(nil, true)
            end, { noremap = true })
        end,
    },
    -- div utils
    "tpope/vim-eunuch", -- Move, Rename etc
    "dhruvasagar/vim-table-mode", -- tables
    "itchyny/vim-qfedit", -- editable quickfix list
    "mbbill/undotree",
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup({ timeout = 2500, stages = "fade", render = "compact" })
        end,
    },
    {
        -- keep location upon reopening
        "ethanholz/nvim-lastplace",
        config = function()
            require("nvim-lastplace").setup()
        end,
    },
    {
        -- tmux / vim interop
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.g.tmux_navigator_no_mappings = 1
            vim.g.tmux_navigator_disable_when_zoomed = 1
            local map = vim.keymap.set
            local opts = { silent = true, noremap = true }
            map("n", "<M-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
            map("n", "<M-j>", "<cmd>TmuxNavigateDown<cr>", opts)
            map("n", "<M-k>", "<cmd>TmuxNavigateUp<cr>", opts)
            map("n", "<M-l>", "<cmd>TmuxNavigateRight<cr>", opts)
        end,
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
            vim.g.mkdp_port = 10010
            vim.g.mkdp_echo_preview_url = 1
        end,
    },
    {
        -- search count > 99
        "kevinhwang91/nvim-hlslens",
        dependencies = {
            "haya14busa/vim-asterisk",
        },
        config = function()
            require("hlslens").setup({ nearest_only = true })
            local kopts = { noremap = true, silent = true }
            local map = vim.keymap.set
            vim.g["asterisk#keeppos"] = 1
            map({ "n", "x" }, "*", [[<Plug>(asterisk-z*)<Cmd>lua require('hlslens').start()<CR>]], {})
            map({ "n", "x" }, "#", [[<Plug>(asterisk-z#)<Cmd>lua require('hlslens').start()<CR>]], {})
            map({ "n", "x" }, "g*", [[<Plug>(asterisk-gz*)<Cmd>lua require('hlslens').start()<CR>]], {})
            map({ "n", "x" }, "g#", [[<Plug>(asterisk-gz#)<Cmd>lua require('hlslens').start()<CR>]], {})
            map({ "n", "x" }, "n", [[n<Cmd>lua require('hlslens').start()<CR>]], kopts)
            map({ "n", "x" }, "N", [[N<Cmd>lua require('hlslens').start()<CR>]], kopts)
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
            vim.keymap.set("n", "<C-t>", "<cmd>NeoTreeFocusToggle<cr>", { noremap = true })
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
    "jnurmine/Zenburn",
    {
        -- coloring of colornames
        "rrethy/vim-hexokinase",
        build = "cd /home/hjalmarlucius/.local/share/nvim/lazy/vim-hexokinase && make hexokinase",
        config = function()
            vim.g.Hexokinase_highlighters = { "virtual" }
        end,
    }, -- status + buffer lines
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local noice_status = require("noice").api.status
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
                    lualine_x = {
                        {
                            noice_status.command.get,
                            cond = noice_status.command.has,
                            color = { fg = "#ff9e64" },
                        },
                        {
                            noice_status.mode.get,
                            cond = noice_status.mode.has,
                            color = { fg = "#ff9e64" },
                        },
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
            })
        end,
    },
    {
        "akinsho/nvim-bufferline.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({ options = { diagnostics = "nvim_lsp" } })
            local map = vim.keymap.set
            map("n", "<M-J>", "<cmd>BufferLineCyclePrev<cr>", { noremap = true, silent = true })
            map("n", "<M-K>", "<cmd>BufferLineCycleNext<cr>", { noremap = true, silent = true })
            map("n", "<M-P>", "<cmd>BufferLineMovePrev<cr>", { noremap = true, silent = true })
            map("n", "<M-N>", "<cmd>BufferLineMoveNext<cr>", { noremap = true, silent = true })
        end,
    }, -- git related plugins
    {
        "tpope/vim-fugitive",
        config = function()
            local map = vim.keymap.set
            map("", "<C-g>", "<cmd>vertical Git<cr>:vertical resize 60<cr>", {})
            map("", "<leader>gB", "<cmd>Git blame<cr>", {})
            map("", "<leader>gp", "<cmd>Git! push<cr>", {})
            map("", "<leader>gP", "<cmd>Git! push -f<cr>", {})
            vim.api.nvim_create_autocmd("User", {
                pattern = { "FugitiveCommit", "BufReadPost" },
                callback = function()
                    vim.opt.foldmethod = "syntax"
                    vim.opt.foldlevel = 0
                end,
            })
        end,
    },
    {
        "rbong/vim-flog",
        config = function()
            local map = vim.keymap.set
            map("", "<leader>gl", "<cmd>vertical Flogsplit -path=%<cr>", {})
            map("", "<leader>gL", "<cmd>vertical Flogsplit<cr>", {})
            vim.g.flog_permanent_default_opts = {
                -- format = "%ad [%h] {%an}%d %s",
                format = "%ad [%h]%d %s",
                date = "short",
            }
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
                    map({ "o", "x" }, "ih", "<cmd><C-U>Gitsigns select_hunk<CR>")
                end,
            })
        end,
    },
    { -- helplists
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
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        config = function()
            local cmp = require("cmp")
            local compare = require("cmp.config.compare")
            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                }, {
                    { name = "buffer" },
                }),
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                }),
                matching = {
                    disallow_fuzzy_matching = true,
                    disallow_fullfuzzy_matching = true,
                    disallow_partial_fuzzy_matching = true,
                    disallow_partial_matching = true,
                    disallow_prefix_unmatching = false,
                },
                sorting = {
                    comparators = {
                        -- compare.offset,
                        -- compare.exact,
                        -- compare.scopes,
                        -- compare.score,
                        -- compare.recently_used,
                        -- compare.locality,
                        -- compare.kind,
                        -- compare.sort_text,
                        -- compare.length,
                        -- compare.order,
                    },
                },
            })
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } },
            })
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
                matching = { disallow_symbol_nonprefix_matching = false },
            })
            cmp.setup.filetype("gitcommit", {
                sources = cmp.config.sources({ { name = "buffer" } }),
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
            map("n", "<M-F>", "<cmd>Telescope find_files layout_config={width=0.99}<cr>", opts)
            map("n", "<M-f>", "<cmd>Telescope git_files layout_config={width=0.99}<cr>", opts)
            map(
                "n",
                "<M-e>",
                "<cmd>Telescope diagnostics layout_strategy=vertical layout_config={width=0.99}<cr>",
                opts
            )
            map("n", "<M-w>", "<cmd>Telescope live_grep layout_strategy=vertical layout_config={width=0.99}<cr>", opts)
            map("n", "<M-w>", ':lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>', opts)
            map("n", "<M-y>", "<cmd>Telescope filetypes<cr>", opts)
            map("n", "<M-u>", "<cmd>Telescope search_history<cr>", opts)
            map("n", "<F9>", "<cmd>Telescope colorscheme layout_config={width=0.5} enable_preview=1<cr>", opts)
            require("telescope").setup({
                defaults = {
                    layout_config = { horizontal = { width = 0.99 } },
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
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        config = function()
            vim.o.foldcolumn = "0"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            local ufo = require("ufo")
            -- zm/M zr/R increase/increase foldlevel (max)
            -- zo/O zc/C open / close fold (max)
            -- za zA switch fold (small/full)
            -- zi toggle folds
            -- zi zj move to next / prev fold

            local map = vim.keymap.set
            map("n", "zR", ufo.openAllFolds)
            map("n", "zM", ufo.closeAllFolds)
            map("n", "zm", ufo.closeFoldsWith)
            map("n", "zr", ufo.openFoldsExceptKinds)

            local closecounthandler = function(virtText, lnum, endLnum, width, truncate)
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
            end
            ufo.setup({
                preview = {
                    mappings = {
                        scrollU = "<C-u>",
                        scrollD = "<C-d>",
                        jumpTop = "[",
                        jumpBot = "]",
                    },
                },
                fold_virt_text_handler = closecounthandler,
            })
        end,
    },
    {
        -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        config = function()
            pcall(require("nvim-treesitter.install").update({ with_sync = true }))
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "c", "cpp", "lua", "vimdoc", "gitcommit", "git_rebase", "bash", "python" },
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
            })
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("nvim-ts-autotag").setup({
                filetypes = { "html", "xml" },
            })
        end,
    },
    {
        "RRethy/nvim-treesitter-textsubjects",
        config = function()
            require("nvim-treesitter.configs").setup({
                textsubjects = {
                    enable = true,
                    prev_selection = ",",
                    keymaps = {
                        ["."] = "textsubjects-smart",
                        [";"] = "textsubjects-container-outer",
                        ["-"] = "textsubjects-container-inner",
                    },
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
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                html = { "tidy", "eslint_d" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },
    {
        "mhartington/formatter.nvim", -- TODO move to conform
        -- Utilities for creating configurations
        config = function()
            local util = require("formatter.util")
            local map = vim.keymap.set
            local opts = { silent = true, noremap = true }
            map("n", "<leader>f", ":Format<cr>", opts)
            map("n", "<leader>F", ":FormatWrite<cr>", opts)
            local eslint_d = function()
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
            end
            local prettierd = function()
                return {
                    exe = "prettierd",
                    args = { util.escape_path(util.get_current_buffer_file_path()) },
                    stdin = true,
                }
            end
            -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
            require("formatter").setup({
                logging = true,
                log_level = vim.log.levels.DEBUG,
                filetype = {
                    python = {
                        require("formatter.filetypes.python").black,
                        -- require("formatter.filetypes.python").pyment,
                        function()
                            return {
                                exe = "isort",
                                args = { "--quiet", "--profile black", "--force-single-line-import", "-" },
                                stdin = true,
                            }
                        end,
                        function()
                            return {
                                exe = "black", -- TODO move to ruff
                                args = { "--quiet", "-C", "--line-length", "100", "-" },
                                stdin = true,
                            }
                        end,
                        function()
                            return {
                                exe = "blackdoc",
                                args = { "-q", "--line-length", "100", "-t py311" },
                                stdin = false,
                            }
                        end,
                    },
                    go = { require("formatter.filetypes.go").gofumpt, require("formatter.filetypes.go").golines },
                    lua = {
                        function()
                            return {
                                exe = "stylua",
                                args = {
                                    "--search-parent-directories",
                                    "--indent-type Spaces",
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
                    sh = { require("formatter.filetypes.sh").shfmt },
                    typescript = {
                        eslint_d,
                    },
                    javascript = {
                        prettierd,
                        eslint_d,
                    },
                    html = {
                        prettierd,
                        -- eslint_d,
                    },
                    css = {
                        prettierd,
                        eslint_d,
                    },
                    markdown = { prettierd },
                    json = { require("formatter.filetypes.json").jq },
                    ["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "folke/neodev.nvim",
            "kevinhwang91/nvim-ufo",
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
                    vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.HINT } })
                end)
                bmap("n", "<M-p>", function()
                    vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.HINT } })
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
                bmap("n", "K", function()
                    local winid = require("ufo").peekFoldedLinesUnderCursor()
                    if not winid then
                        vim.lsp.buf.hover()
                    end
                end)
                bmap("n", "<M-r>", vim.lsp.buf.rename)
                bmap("n", "<leader>ca", vim.lsp.buf.code_action)
            end

            local server_configs = {
                pyright = {
                    python = {
                        analysis = { typeCheckingMode = "standard" },
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
                yaml = {
                    schemas = { kubernetes = "globPattern" },
                },
            }
            require("neodev").setup()

            local capabilities = vim.lsp.protocol.make_client_capabilities()

            local cmp = require("cmp_nvim_lsp")
            if cmp then
                capabilities = cmp.default_capabilities(capabilities)
            end

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
                    "bashls", -- bash
                    "cssls", -- css
                    "html", -- html
                    "jsonls", -- json
                    "lua_ls", -- lua
                    "marksman", -- markdown
                    "pyright", -- python
                    "tsserver", -- typescript
                    "yamlls", -- yaml
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
        dependencies = { "MunifTanjim/nui.nvim" },
        config = function()
            require("noice").setup({
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
                notify = { enabled = true, view = "notify" },
                lsp = {
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
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
            })
        end,
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
vim.o.listchars = "tab:→ ,trail:·,extends:↷,precedes:↶,nbsp:+,eol:↵"
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

vim.o.completeopt = "menu,menuone,noinsert,noselect"
vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
vim.opt.iskeyword = vim.opt.iskeyword - { "." }

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "quickfix" },
    callback = function()
        vim.keymap.set("n", "<cr>", "<cr>", { buffer = true })
    end,
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
map("n", "-", "_", { noremap = true })
map("v", "v", "<esc>", { noremap = true })
map("v", "<Tab>", ">gv", { noremap = true })
map("v", "<S-Tab>", "<gv", { noremap = true })
map("n", "<leader>o", "m`o<Esc>``", { noremap = true }) -- Insert a newline in normal mode
-- repeat and next
map("n", "\\", "n.", { noremap = true })

-- WINDOWS / BUFFERS
-- make splits and tabs
map("n", "<M-V>", "<cmd>vnew<cr>", { noremap = true })
map("n", "<M-S>", "<cmd>new<cr>", { noremap = true })
map("n", "<M-v>", "<cmd>vsplit<cr>", { noremap = true })
map("n", "<M-s>", "<cmd>split<cr>", { noremap = true })
map("n", "<M-t>", "<cmd>tabe %<cr>", { noremap = true })
map("n", "<M-T>", "<cmd>tabnew<cr>", { noremap = true })
-- buffers and tabs
map("n", "<M-J>", "<cmd>bprev<cr>", { noremap = true })
map("n", "<M-K>", "<cmd>bnext<cr>", { noremap = true })
map("n", "<M-H>", "<cmd>tabprev<cr>", { noremap = true })
map("n", "<M-L>", "<cmd>tabnext<cr>", { noremap = true })
-- resize windows with hjkl
map("n", "<C-h>", "5<C-w><", { noremap = true })
map("n", "<C-j>", "5<C-w>-", { noremap = true })
map("n", "<C-k>", "5<C-w>+", { noremap = true })
map("n", "<C-l>", "5<C-w>>", { noremap = true })
-- quickfix window
map("n", "<C-p>", "<cmd>cp<cr>", { noremap = true })
map("n", "<C-n>", "<cmd>cn<cr>", { noremap = true })
--- F keys
map("n", "<F1>", "<cmd>Lazy<cr>", { noremap = true })
map("n", "<F2>", "<cmd>Mason<cr>", { noremap = true })
map("n", "<F3>", "<cmd>LspInfo<cr>", { noremap = true })
map("n", "<F5>", "<cmd>checkt<cr>", { noremap = true })
map("n", "<F6>", "<cmd>TodoQuickFix<cr>", { noremap = true })

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
local customthemegroup = vim.api.nvim_create_augroup("customthemegroup", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = { "OceanicNext" },
    group = customthemegroup,
    callback = function()
        vim.api.nvim_set_hl(0, "DiffAdded", { default = false, link = "DiffAdd" })
        vim.api.nvim_set_hl(0, "DiffRemoved", { default = false, link = "DiffDelete" })
    end,
})
vim.cmd("colorscheme minicyan")
