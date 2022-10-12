local opt = vim.opt
-- ----------------------------------------
-- SETTINGS
-- ----------------------------------------

-- system
opt.shell = "/usr/bin/bash"
opt.fileencodings = "utf-8,ucs-bom,gb18030,gbk,gb2312,cp936"
opt.fileformats = "unix"
opt.swapfile = false
opt.backup = false
opt.updatetime = 300
opt.timeoutlen = 200
vim.g.BASH_Ctrl_j = "off"
vim.g.BASH_Ctrl_l = "off"
vim.g.python3_host_prog = "/usr/bin/python3.10"

-- looks
opt.termguicolors = true
opt.cmdheight = 1
-- opt.background = "dark"
opt.listchars = "tab:→ ,trail:·,extends:↷,precedes:↶,nbsp:+,eol:↵"
opt.list = true -- Show listchars
opt.showtabline = 2
opt.laststatus = 2

-- undo
opt.undodir = "/home/hjalmarlucius/.cache/vim/undo"
opt.undofile = true
opt.undolevels = 1000
opt.undoreload = 10000

-- window
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current

-- buffer
opt.hidden = true -- Enable background buffers
opt.wrap = false -- Disable line wrap
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = false -- Highlight current line
opt.switchbuf = "useopen" -- Use existing window if buffer is already open
opt.colorcolumn = "88"

-- tabs
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = false -- Avoid fucking with comment indents
opt.shiftround = true -- Round indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent

-- search
opt.ignorecase = false -- Ignore case
opt.smartcase = false -- Do not ignore case with capitals
opt.wildmode = {"full"} -- Command-line completion mode
opt.wildignorecase = true
opt.wildignore = opt.wildignore + {
  "*swp", "*.class", "*.pyc", "*.png", "*.jpg", "*.gif", "*.zip", "*/tmp/*",
  "*.o", ".obj", "*.so"
}

-- cursor
opt.scrolloff = 5 -- Lines of context
opt.scrolljump = 1 -- Lines to scroll when cursor leaves screen
opt.sidescrolloff = 4 -- Columns of context
opt.showmatch = true -- Show matching brackets / parentheses

-- editing
opt.timeoutlen = 500 -- How long to wait during key combo
opt.langmap = "å(,¨),Å{,^},Ø\\;,ø:,æ^,+$"
opt.clipboard = opt.clipboard + {"unnamedplus"}

-- folding (also see treesitter)
-- zm/M zr/R increase/increase foldlevel (max)
-- zo/O zc/C open / close fold (max)
-- za zA switch fold (small/full)
-- zi toggle folds
-- zi zj move to next / prev fold
opt.foldenable = false
opt.foldmethod = "expr"

opt.completeopt = "menu,menuone,noinsert"
vim.g.seoul256_background = 235

-- ----------------------------------------
-- AUTOCOMMANDS
-- ----------------------------------------
-- highlight on yank
local cmd = vim.cmd

vim.api.nvim_command [[augroup MYAU]]
vim.api.nvim_command [[autocmd!]]
vim.api.nvim_command [[autocmd BufWritePost * %s/\s\+$//e]]
vim.api.nvim_command [[autocmd BufWritePost *.py silent! execute ':Black']]
vim.api.nvim_command [[autocmd BufReadPost quickfix nmap <buffer> <cr> <cr>]]
vim.api
    .nvim_command [[autocmd TextYankPost * "lua vim.highlight.on_yank {on_visual = false}"]]
vim.api.nvim_command [[augroup END]]

-- ----------------------------------------
-- MAPS
-- ----------------------------------------
-- leader/local leader
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local map = vim.api.nvim_set_keymap
map("n", "Q", "", {noremap = true})
map("n", "q:", "", {noremap = true})

map("n", "<leader>E",
    [[:so ~/.config/nvim/init.lua<cr>:PackerInstall<cr>:PackerCompile<cr>]],
    {noremap = true})
map("n", "<leader>e", [[:vnew ~/dotfiles/nvim/init.lua<cr>]], {noremap = true})
map("n", "<leader>nt", [[:vnew ~/notes/todos.md<cr>]], {noremap = true})
map("n", "<leader>nc", [[:vnew ~/notes/cheatsheet.md<cr>]], {noremap = true})
map("n", "<leader>nl", [[:vnew ~/notes/libs.md<cr>]], {noremap = true})
map("n", "<leader>nu", [[:vnew ~/notes/urls.md<cr>]], {noremap = true})
map("n", "<leader>nn", [[:Explore ~/notes<cr>]], {noremap = true})
map("n", "<leader>ww", [[:cd %:p:h<cr>]], {noremap = true})
map("n", "<esc><esc>", ":noh<cr>", {silent = true, noremap = true})
map("n", "<F12>", "<esc>", {silent = true, noremap = true})
map("i", "<F12>", "<esc>", {silent = true, noremap = true})
map("v", "<F12>", "<esc>", {silent = true, noremap = true})

-- <Tab> to navigate the completion menu
map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]],
    {expr = true, noremap = true})
map("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]],
    {expr = true, noremap = true})

-- CURSOR
-- stay visual when indenting
map("n", "-", "_", {noremap = true})
map("v", "v", "<esc>", {noremap = true})
map("v", "<Tab>", ">gv", {noremap = true})
map("v", "<S-Tab>", "<gv", {noremap = true})
map("n", "<leader>o", "m`o<Esc>``", {noremap = true}) -- Insert a newline in normal mode
-- repeat and next
map("n", "\\", "n.", {noremap = true})

-- WINDOWS / BUFFERS
-- make splits and tabs
map("n", "<M-V>", ":vnew<cr>", {noremap = true})
map("n", "<M-S>", ":new<cr>", {noremap = true})
map("n", "<M-v>", ":vsplit<cr>", {noremap = true})
map("n", "<M-s>", ":split<cr>", {noremap = true})
map("n", "<M-t>", ":tabe %<cr>", {noremap = true})
map("n", "<M-T>", ":tabnew<cr>", {noremap = true})
-- buffers and tabs
map("n", "<M-J>", ":bprev<cr>", {noremap = true})
map("n", "<M-K>", ":bnext<cr>", {noremap = true})
map("n", "<M-H>", ":tabprev<cr>", {noremap = true})
map("n", "<M-L>", ":tabnext<cr>", {noremap = true})
-- resize windows with hjkl
map("n", "<C-h>", "5<C-w><", {noremap = true})
map("n", "<C-j>", "5<C-w>-", {noremap = true})
map("n", "<C-k>", "5<C-w>+", {noremap = true})
map("n", "<C-l>", "5<C-w>>", {noremap = true})
-- quickfix window
map("n", "<C-p>", ":cp<cr>", {noremap = true})
map("n", "<C-n>", ":cn<cr>", {noremap = true})
-- remove buffer
map("n", "<M-d>", ":bprev<bar>:bd#<cr>", {noremap = true})
map("n", "<M-D>", ":bprev<bar>:bd!#<cr>", {noremap = true})
map("n", "<F9>", ":checkt<cr>", {noremap = true})

-- ----------------------------------------
-- PACKER
-- ----------------------------------------
local install_path = vim.fn.stdpath("data") ..
                         "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({
    "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path
  })
  vim.api.nvim_command "packadd packer.nvim"
end

require("packer").startup {
  function(use)
    use {"wbthomason/packer.nvim"}

    -- tpope
    use {"tpope/vim-sensible"} -- sensible default
    use {"tpope/vim-commentary"} -- comment out stuff
    use {"tpope/vim-surround"}
    use {"tpope/vim-repeat"} -- repeat vim-surround with .
    use {"tpope/vim-eunuch"} -- Move, Rename etc
    use {"farmergreg/vim-lastplace"} -- keep location upon reopening

    -- smooth scrolling
    -- use {"psliwka/vim-smoothie"}

    -- tables
    use {"dhruvasagar/vim-table-mode"}

    -- git
    use {
      "tpope/vim-fugitive",
      config = function()
        local map = vim.api.nvim_set_keymap
        map("", "<C-g>", ":vertical Git<cr>:vertical resize 60<cr>", {})
        map("", "<leader>gb", ":Git blame<cr>", {})
        map("", "<leader>gp", ":Git push<cr>", {})
        map("", "<leader>gP", ":Git push -f<cr>", {})
      end
    }

    -- tig
    use {
      "iberianpig/tig-explorer.vim",
      requires = {"rbgrouleff/bclose.vim"},
      config = function()
        vim.g.tig_explorer_use_builtin_term = 0
        local map = vim.api.nvim_set_keymap
        map("", "<leader>gg", ":TigOpenProjectRootDir<cr><cr>", {})
        map("", "<leader>gG", ":TigOpenCurrentFile<cr>", {})
      end
    }

    use {
      "lewis6991/gitsigns.nvim",
      requires = {"nvim-lua/plenary.nvim"},
      config = function()
        require("gitsigns").setup {
          numhl = false,
          linehl = false,
          keymaps = {
            -- Default keymap options
            noremap = true,
            buffer = true,

            ["n <M-,>"] = {
              expr = true,
              [[&diff ? "]c" : "<cmd>lua require('gitsigns.actions').next_hunk()<cr>"]]
            },
            ["n <M-.>"] = {
              expr = true,
              [[&diff ? "[c" : "<cmd>lua require('gitsigns.actions').prev_hunk()<cr>"]]
            },

            ["n <leader>gs"] = [[<cmd>lua require("gitsigns").stage_hunk()<cr>]],
            ["v <leader>gs"] = [[<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<cr>]],
            ["n <leader>gu"] = [[<cmd>lua require("gitsigns").undo_stage_hunk()<cr>]],
            ["n <leader>gx"] = [[<cmd>lua require("gitsigns").reset_hunk()<cr>]],
            ["v <leader>gx"] = [[<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<cr>]],
            ["n <leader>gi"] = [[<cmd>lua require("gitsigns").preview_hunk()<cr>]],
            ["n <leader>gB"] = [[<cmd>lua require("gitsigns").blame_line(true)<cr>]],

            -- Text objects
            ["o ih"] = [[:<C-U>lua require("gitsigns.actions").select_hunk()<cr>]],
            ["x ih"] = [[:<C-U>lua require("gitsigns.actions").select_hunk()<cr>]]
          },
          word_diff = false
        }
      end
    }

    -- folder tree
    use {
      "kyazdani42/nvim-tree.lua",
      requires = {"kyazdani42/nvim-web-devicons"},
      config = function()
        require("nvim-tree").setup {disable_netrw = false}
        local map = vim.api.nvim_set_keymap
        map("n", "<C-t>", ":NvimTreeToggle<cr>", {noremap = true})
      end
    }

    -- theme dark and light
    use {"NLKNguyen/papercolor-theme"}
    use {"folke/tokyonight.nvim"}
    use {"junegunn/seoul256.vim"}
    use {"mhartington/oceanic-next"}
    use {"morhetz/gruvbox"}
    use {"sonph/onehalf", rtp = "vim/"}

    use {
      "Shatur/neovim-ayu",
      config = function()
        require('ayu').setup {mirage = true}
        vim.g.ayu_extended_palette = 1
      end
    }

    use {
      "skbolton/embark",
      config = function() vim.g.embark_terminal_italics = 1 end
    }

    -- theme dark only
    use {"tomasr/molokai"}
    use {"kdheepak/monochrome.nvim"}
    use {"kcsongor/vim-monochrome-light"}
    use {"jnurmine/Zenburn"}
    use {"nanotech/jellybeans.vim"}

    vim.cmd "colorscheme seoul256"

    -- coloring of colornames
    use {
      "rrethy/vim-hexokinase",
      run = "cd /home/hjalmarlucius/.local/share/nvim/site/pack/packer/start/vim-hexokinase && make hexokinase",
      config = function() vim.g.Hexokinase_highlighters = {"virtual"} end
    }

    -- flashing cursor on move
    use {
      "danilamihailov/beacon.nvim",
      setup = function()
        vim.api.nvim_exec([[highlight Beacon guibg=white ctermbg=15]], false)
      end,
      config = function()
        vim.g.beacon_size = 40
        vim.g.beacon_minimal_jump = 10
        vim.g.beacon_shrink = 1
      end
    }

    use {
      "haya14busa/vim-asterisk",
      config = function()
        vim.g["asterisk#keeppos"] = 1
        local map = vim.api.nvim_set_keymap
        map("", "*", "<Plug>(asterisk-z*)", {})
        map("", "#", "<Plug>(asterisk-z#)", {})
        map("", "g*", "<Plug>(asterisk-gz*)", {})
        map("", "g#", "<Plug>(asterisk-gz#)", {})
      end
    }

    use {
      "christoomey/vim-tmux-navigator",
      config = function()
        vim.g.tmux_navigator_no_mappings = 1
        vim.g.tmux_navigator_disable_when_zoomed = 1
        local map = vim.api.nvim_set_keymap
        opts = {silent = true, noremap = true}
        map("n", "<M-h>", ":TmuxNavigateLeft<cr>", opts)
        map("n", "<M-j>", ":TmuxNavigateDown<cr>", opts)
        map("n", "<M-k>", ":TmuxNavigateUp<cr>", opts)
        map("n", "<M-l>", ":TmuxNavigateRight<cr>", opts)
      end
    }

    use {
      "iamcco/markdown-preview.nvim", -- requires yarn
      run = function() vim.fn["mkdp#util#install"]() end,
      config = function()
        vim.g.mkdp_auto_start = 0 -- auto start on moving into
        vim.g.mkdp_auto_close = 0 -- auto close on moving away
        vim.g.mkdp_open_to_the_world = 1 -- available to others
        vim.g.mkdp_port = 8555
        vim.g.mkdp_echo_preview_url = 1
      end
    }

    use {
      "hoob3rt/lualine.nvim",
      requires = {"kyazdani42/nvim-web-devicons"},
      config = function()
        require("lualine").setup {
          options = {theme = "auto", globalstatus = false},
          extensions = {"fugitive"},
          sections = {
            lualine_a = {"mode"},
            lualine_b = {"branch"},
            lualine_c = {
              {"filename", file_status = true, path = 1, shorting_target = 0},
              {"diff", colored = true}
            },
            lualine_x = {"filetype"},
            lualine_y = {"progress"},
            lualine_z = {"location"}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
              {"filename", file_status = true, path = 1, shorting_target = 0},
              {"diff", colored = true}
            },
            lualine_x = {},
            lualine_y = {"progress"},
            lualine_z = {"location"}
          }
        }
      end
    }

    use {
      "akinsho/nvim-bufferline.lua",
      requires = {"kyazdani42/nvim-web-devicons"},
      config = function()
        require("bufferline").setup {options = {diagnostics = "nvim_lsp"}}
        local map = vim.api.nvim_set_keymap
        map("n", "<M-J>", ":BufferLineCyclePrev<cr>",
            {noremap = true, silent = true})
        map("n", "<M-K>", ":BufferLineCycleNext<cr>",
            {noremap = true, silent = true})
        map("n", "<M-P>", ":BufferLineMovePrev<cr>",
            {noremap = true, silent = true})
        map("n", "<M-N>", ":BufferLineMoveNext<cr>",
            {noremap = true, silent = true})
      end
    }

    use {
      "numtostr/FTerm.nvim",
      config = function()
        require("FTerm").setup {}
        local map = vim.api.nvim_set_keymap
        local opts = {noremap = true, silent = true}
        map("n", "<F2>", [[<cmd>lua require("FTerm").toggle()<cr>]], opts)
        map("t", "<F2>", [[<C-\><C-n><cmd>lua require("FTerm").toggle()<cr>]],
            opts)
      end
    }

    use {"psf/black", config = function() vim.g.black_fast = 1 end}

    -- treesitter
    use {
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup {
          ensure_installed = {
            "bash", "lua", "c", "comment", "cpp", "css", "cuda", "dockerfile",
            "fish", "graphql", "help", "html", "java", "javascript", "json",
            "json5", "julia", "latex", "lua", "make", "markdown",
            "markdown_inline", "ninja", "python", "regex", "toml", "vim", "yaml"
          },
          highlight = {
            enable = true,
            -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
            -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
            -- Using this option may slow down your editor, and you may see some duplicate highlights.
            -- Instead of true it can also be a list of languages
            additional_vim_regex_highlighting = false
          },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_decremental = "<M-j>",
              node_incremental = "<M-k>",
              scope_incremental = "<M-n>"
            }
          }
        }
        vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      end
    }

    use {
      "nvim-telescope/telescope.nvim",
      requires = {
        "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-live-grep-args.nvim"
      },
      config = function()
        -- TODO grep with regex
        local map = vim.api.nvim_set_keymap
        local opts = {noremap = true}
        local actions = require("telescope.actions")
        map("n", "<M-F>", "<cmd>Telescope find_files<cr>", opts)
        map("n", "<M-f>", "<cmd>Telescope git_files<cr>", opts)
        map("n", "<M-w>",
            ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>",
            opts)
        map("n", "<M-b>", "<cmd>Telescope buffers<cr>", opts)
        map("n", "<M-y>", "<cmd>Telescope filetypes<cr>", opts)
        map("n", "<F3>",
            "<cmd>lua require('telescope.builtin').colorscheme({enable_preview=1})<cr>",
            opts)
        map("n", "<leader>la", "<cmd>Telescope lsp_code_actions<cr>", opts)
        map("v", "<leader>la", "<cmd>Telescope lsp_range_code_actions<cr>", opts)
        map("n", "<leader>ld", "<cmd>Telescope document_diagnostics<cr>", opts)
        map("n", "<leader>lD", "<cmd>Telescope workspace_diagnostics<cr>", opts)
        map("n", "<F11>", "<cmd>Telescope<cr>", opts)
        require("telescope").setup {
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
                ["<S-Tab>"] = actions.toggle_selection +
                    actions.move_selection_worse,
                ["<Tab>"] = actions.toggle_selection +
                    actions.move_selection_better,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist +
                    actions.open_qflist,
                ["<PageUp>"] = actions.results_scrolling_up,
                ["<PageDown>"] = actions.results_scrolling_down
              }
            },
            file_ignore_patterns = {},
            set_env = {["COLORTERM"] = "truecolor"}
          }
        }
      end
    }
    -- context
    use {
      "romgrk/nvim-treesitter-context",
      requires = {"nvim-treesitter/nvim-treesitter"},
      config = function()
        require("treesitter-context").setup {
          enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
          throttle = true, -- Throttles plugin updates (may improve performance)
          max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
          patterns = {
            default = {
              "class", "function", "method"
              -- 'for', -- These won't appear in the context
              -- 'while',
              -- 'if',
              -- 'switch',
              -- 'case',
            }
            -- Example for a specific filetype.
            -- If a pattern is missing, *open a PR* so everyone can benefit.
            --   rust = {
            --       'impl_item',
            --   },
          }
        }
      end
    }

    -- autocompletion
    use {
      "hrsh7th/nvim-cmp",
      requires = {
        {"hrsh7th/cmp-path", after = "nvim-cmp"},
        {"hrsh7th/cmp-buffer", after = "nvim-cmp"},
        {"hrsh7th/cmp-calc", after = "nvim-cmp"}
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          sources = {
            {name = "nvim_lsp"}, {name = "buffer"}, {name = "path"},
            {name = "nvim_lua"}
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete()
          })
        })
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}})
        })
      end
    }

    use {"itchyny/vim-qfedit"}

    use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("trouble").setup {
          position = "right", -- position of the list can be: bottom, top, left, right
          height = 10, -- height of the trouble list when position is top or bottom
          width = 60, -- width of the list when position is left or right
          icons = true, -- use devicons for filenames
          mode = "quickfix", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
          fold_open = "", -- icon used for open folds
          fold_closed = "", -- icon used for closed folds
          action_keys = { -- key mappings for actions in the trouble list
            close = "q", -- close the list
            cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
            refresh = "r", -- manually refresh
            jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
            open_split = {"<c-s>"}, -- open buffer in new split
            open_vsplit = {"<c-v>"}, -- open buffer in new vsplit
            open_tab = {"<c-t>"}, -- open buffer in new tab
            jump_close = {"o"}, -- jump to the diagnostic and close the list
            toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
            toggle_preview = "P", -- toggle auto_preview
            hover = "K", -- opens a small popup with the full multiline message
            preview = "p", -- preview the diagnostic location
            close_folds = {"zM", "zm"}, -- close all folds
            open_folds = {"zR", "zr"}, -- open all folds
            toggle_fold = {"zA", "za"}, -- toggle fold of current file
            previous = "k", -- preview item
            next = "j" -- next item
          },
          indent_lines = true, -- add an indent guide below the fold icons
          auto_open = false, -- automatically open the list when you have diagnostics
          auto_close = false, -- automatically close the list when you have no diagnostics
          auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
          auto_fold = false -- automatically fold a file trouble list at creation
        }
        local map = vim.api.nvim_set_keymap
        local opts = {noremap = true}
        map("n", "<F4>", ":Trouble workspace_diagnostics<cr>", opts)
        map("n", "<F6>", ":Trouble quickfix<cr>", opts)
        map("n", "<F7>", ":Trouble loclist<cr>", opts)
        map("n", "<F8>", ":Trouble lsp_references<cr>", opts)
      end
    }

    use {
      "folke/todo-comments.nvim",
      requires = {"nvim-lua/plenary.nvim"},
      config = function()
        require("todo-comments").setup {
          signs = true, -- show icons in the signs column
          sign_priority = 8, -- sign priority
          -- keywords recognized as todo comments
          keywords = {
            ERROR = {icon = " ", color = "error"},
            WIP = {icon = " ", color = "warning"},
            TODO = {icon = " ", color = "warning"},
            PERF = {icon = " ", color = "info"},
            TEST = {icon = " ", color = "info"},
            MAYBE = {icon = " ", color = "default"},
            IDEA = {icon = " ", color = "hint"}
          },
          merge_keywords = false, -- when true, custom keywords will be merged with the defaults
          highlight = {keyword = "bg", pattern = [[<(KEYWORDS)\s*]]},
          search = {pattern = [[\b(KEYWORDS)\b]]},
          colors = {
            error = {"#E15030"},
            warning = {"#FBBF24"},
            info = {"#91BED0"},
            hint = {"#10B981"},
            default = {"#91D0C1"}
          }
        }
        local map = vim.api.nvim_set_keymap
        local opts = {noremap = true}
        map("n", "<F5>", ":TodoTrouble<cr>", opts)
      end
    }

    use {
      "neovim/nvim-lspconfig",
      requires = {"hrsh7th/cmp-nvim-lsp"},
      run = ":TSUpdate",
      config = function()
        -- see https://github.com/lukas-reineke/dotfiles/blob/master/vim/lua/lsp/init.lua
        on_attach = function(client, bufnr)
          local bmap = vim.api.nvim_buf_set_keymap
          local opts = {noremap = true}
          vim.api.nvim_buf_set_option(bufnr, "omnifunc",
                                      "v:lua.vim.lsp.omnifunc")
          vim.lsp.set_log_level("error")
          -- workspaces
          bmap(bufnr, "n", "<leader>wa",
               "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", opts)
          bmap(bufnr, "n", "<leader>wr",
               "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", opts)
          bmap(bufnr, "n", "<leader>wl",
               "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
               opts)
          -- jump
          bmap(bufnr, "n", "gl",
               "<cmd>lua vim.diagnostic.set_loclist({severity_limit='Warning'})<cr>",
               opts)
          bmap(bufnr, "n", "<M-i>",
               "<cmd>lua vim.diagnostic.open_float(0, {scope='line'})<cr>", opts)
          bmap(bufnr, "n", "<M-I>",
               "<cmd>lua vim.diagnostic.open_float(0, {scope='cursor'})<cr>",
               opts)
          bmap(bufnr, "n", "<M-n>",
               "<cmd>lua vim.diagnostic.goto_next({float={}})<cr>", opts)
          bmap(bufnr, "n", "<M-p>",
               "<cmd>lua vim.diagnostic.goto_prev({float={}})<cr>", opts)
          -- popups
          bmap(bufnr, "n", "<M-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>",
               opts)
          bmap(bufnr, "i", "<M-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>",
               opts)
          -- other
          bmap(bufnr, "n", "gd", ":lua vim.lsp.buf.definition()<cr>", opts)
          bmap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
          bmap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
          bmap(bufnr, "n", "<M-r>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
          bmap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<cr>",
               opts)
          if client.server_capabilities.documentFormattingProvider or
              client.server_capabilities.documentRangeFormattingProvider then
            vim.api.nvim_command [[augroup Format]]
            vim.api.nvim_command [[autocmd! * <buffer>]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.py lua vim.lsp.buf.format()]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.lua lua vim.lsp.buf.format()]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.md lua vim.lsp.buf.format()]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.yaml lua vim.lsp.buf.format()]]
            vim.api.nvim_command [[augroup END]]

          end
        end
        local nvim_lsp = require("lspconfig")
        nvim_lsp.tsserver.setup {}
        nvim_lsp.yamlls.setup {
          on_attach = on_attach,
          settings = {
            yaml = {
              customTags = {
                "!ChildAccessor mapping", "!ChildContainer mapping",
                "!ConstantAccessor mapping", "!Dtype scalar",
                "!ParameterAccessor mapping", "!DtypeTensor scalar",
                "!ImportClass scalar", "!ReferenceContainer mapping",
                "!ReferenceLink mapping", "!SeriesTensor mapping",
                "!SeriesAccessor mapping", "!UDFtensorfactory scalar",
                "!UDFnu scalar", "!UDFvalidator scalar", "!Unit scalar",
                "!UserClass mapping", "!UserInstance mapping",
                "!getattr mapping", "!timedelta mapping"
              }
            }
          }
        }
        local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
                                                                             .protocol
                                                                             .make_client_capabilities())
        nvim_lsp.html.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          provideFormatter = false
        }
        nvim_lsp.jsonls.setup {
          on_attach = on_attach,
          capabilities = capabilities
        }
        nvim_lsp.cssls.setup {
          on_attach = on_attach,
          capbilities = capabilities,
          provideFormatter = false
        }
        nvim_lsp.eslint.setup {on_attach = on_attach}
        nvim_lsp.pyright.setup {
          on_attach = on_attach,
          settings = {
            python = {
              analysis = {
                diagnosticMode = "workspace",
                logLevel = "Warning",
                typeCheckingMode = "basic",
                autoImportCompletions = false,
                venvPath = "."
              }
            }
          }
        }
        nvim_lsp.efm.setup {
          on_attach = on_attach,
          init_options = {documentFormatting = true},
          filetypes = {
            "python", "markdown", "yaml", "lua", "javascript", "html", "css"
          },
          root_dir = vim.loop.cwd,
          settings = {
            rootMarkers = {".git/"},
            languages = {
              python = {
                {
                  lintCommand = "flake8 --max-line-length 88 --format '%(path)s:%(row)d:%(col)d: %(code)s %(code)s %(text)s' --stdin-display-name ${INPUT} -",
                  lintFormats = {"%f:%l:%c: %t%n%n%n %m"},
                  lintSource = "flake8",
                  lintStdin = true,
                  lintIgnoreExitCode = true
                }, {
                  formatCommand = "isort --stdout -e -",
                  formatStdin = true
                  -- }, {
                  --     lintCommand = "mypy --show-column-numbers --ignore-missing-imports",
                  --     lintFormats = {
                  --         "%f=%l:%c: %trror: %m",
                  --         "%f=%l:%c: %tarning: %m",
                  --         "%f=%l:%c: %tote: %m"
                  --     }
                }
              },
              css = {{formatCommand = "prettier"}},
              html = {{formatCommand = "prettier"}},
              javascript = {{formatCommand = "prettier"}},
              yaml = {{formatCommand = "prettier"}},
              markdown = {{formatCommand = "prettier"}},
              lua = {
                {
                  formatCommand = "lua-format -i --tab-width=2 --indent-width=2",
                  formatStdin = true
                }
              }
            }
          }
        }
      end
    }
  end
}
