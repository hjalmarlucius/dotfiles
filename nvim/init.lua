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

-- looks
opt.termguicolors = true
opt.cmdheight = 2
opt.background = "dark"
opt.listchars = "tab:→ ,trail:·,extends:↷,precedes:↶,nbsp:+,eol:↵"
opt.list = true -- Show listchars
opt.showtabline = 2

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
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Do not ignore case with capitals
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
map("n", "<C-n>", ":cp<cr>", {noremap = true})
map("n", "<C-m>", ":cn<cr>", {noremap = true})
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
        map("", "<leader>gg", ":vertical Gclog!<cr>", {})
        map("", "<leader>gc", ":vertical 0Gclog!<cr>", {})
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

            ["n <M-.>"] = {
              expr = true,
              [[&diff ? "]c" : "<cmd>lua require('gitsigns.actions').next_hunk()<cr>"]]
            },
            ["n <M-,>"] = {
              expr = true,
              [[&diff ? "[c" : "<cmd>lua require('gitsigns.actions').prev_hunk()<cr>"]]
            },

            ["n <leader>gs"] = [[<cmd>lua require("gitsigns").stage_hunk()<cr>]],
            ["v <leader>gs"] = [[<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<cr>]],
            ["n <leader>gu"] = [[<cmd>lua require("gitsigns").undo_stage_hunk()<cr>]],
            ["n <leader>gx"] = [[<cmd>lua require("gitsigns").reset_hunk()<cr>]],
            ["v <leader>gx"] = [[<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<cr>]],
            ["n <leader>gi"] = [[<cmd>lua require("gitsigns").preview_hunk()<cr>]],
            ["n <leader>gb"] = [[<cmd>lua require("gitsigns").blame_line(true)<cr>]],

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
        require("nvim-tree").setup {disable_netrw = false, auto_close = true}
        local map = vim.api.nvim_set_keymap
        map("n", "<C-p>", ":NvimTreeToggle<cr>", {noremap = true})
      end
    }

    -- theme
    use {
      "folke/tokyonight.nvim",
      config = function() vim.g.tokyonight_style = "night" end
    }

    use {"sonph/onehalf", rtp = "vim"}
    use {"tomasr/molokai"}
    use {"morhetz/gruvbox"}
    use {"jnurmine/Zenburn"}
    use {"nanotech/jellybeans.vim"}
    use {"mhartington/oceanic-next"}
    use {"NLKNguyen/papercolor-theme"}
    use {"drewtempelmeyer/palenight.vim"}
    use {"altercation/vim-colors-solarized"}
    use {"rakr/vim-one", config = function() vim.g.one_allow_italics = 1 end}

    use {
      "ayu-theme/ayu-vim",
      config = function()
        -- vim.g.ayucolor = "light"
        -- vim.g.ayucolor = "mirage"
        vim.g.ayucolor = "dark"
      end
    }

    use {
      "skbolton/embark",
      config = function() vim.g.embark_terminal_italics = 1 end
    }

    use {"arcticicestudio/nord-vim", config = function() end}

    use {
      "junegunn/seoul256.vim",
      config = function() vim.g.seoul256_background = 235 end
    }
    vim.cmd "colorscheme nord"

    -- coloring of colornames
    use {
      "rrethy/vim-hexokinase",
      run = "cd /home/hjalmarlucius/.local/share/nvim/site/pack/packer/start/vim-hexokinase && make hexokinase",
      config = function()
        vim.g.Hexokinase_highlighters = {"backgroundfull"}
      end
    }

    -- edgedb syntax highlighting
    use {"edgedb/edgedb-vim"}

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

    -- indentation guides
    use {
      "lukas-reineke/indent-blankline.nvim",
      config = function()
        vim.g.indent_blankline_char = "|"
        vim.g.indent_blankline_use_treesitter = true
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
      "mbbill/undotree",
      config = function()
        local map = vim.api.nvim_set_keymap
        map("", "<F11>", ":UndotreeToggle<cr>:UndotreeFocus<cr>",
            {noremap = true})
      end
    }

    use {
      "iamcco/markdown-preview.nvim", -- requires yarn
      run = "cd /home/hjalmarlucius/.local/share/nvim/site/pack/packer/start/markdown-preview && yarn install",
      config = function()
        vim.g.mkdp_auto_start = 0 -- auto start on moving into
        vim.g.mkdp_auto_close = 0 -- auto close on moving away
        vim.g.mkdp_open_to_the_world = 0 -- available to others
        vim.g.mkdp_open_ip = "" -- use custom IP to open preview page
      end
    }

    use {
      "hoob3rt/lualine.nvim",
      requires = {"kyazdani42/nvim-web-devicons"},
      config = function()
        require("lualine").setup {
          options = {theme = "auto"},
          extensions = {"fugitive"},
          sections = {
            lualine_a = {"mode"},
            lualine_b = {"branch"},
            lualine_c = {{"filename", file_status = true, path = 1}}, -- , {"diff", colored=false}, { "diagnostics", sources = {"nvim_lsp"}}
            lualine_x = {"filetype"},
            lualine_y = {"progress"}, -- "encoding", "fileformat",
            lualine_z = {"location"}
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {{"filename", file_status = true, path = 1}},
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
        map("n", "<M-N>", ":BufferLineMovePrev<cr>",
            {noremap = true, silent = true})
        map("n", "<M-M>", ":BufferLineMoveNext<cr>",
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
          ensure_installed = "maintained"
        }
        vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      end
    }

    use {
      "nvim-telescope/telescope.nvim",
      requires = {
        "nvim-lua/popup.nvim", "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-live-grep-raw.nvim"
      },
      config = function()
        -- TODO grep with regex
        local map = vim.api.nvim_set_keymap
        local opts = {noremap = true}
        local actions = require("telescope.actions")
        map("n", "<M-F>", "<cmd>Telescope find_files<cr>", opts)
        map("n", "<M-f>", "<cmd>Telescope git_files<cr>", opts)
        map("n", "<M-w>",
            ":lua require('telescope').extensions.live_grep_raw.live_grep_raw()<cr>",
            opts)
        map("n", "<M-b>", "<cmd>Telescope buffers<cr>", opts)
        map("n", "<M-y>", "<cmd>Telescope filetypes<cr>", opts)
        map("n", "<F3>", "<cmd>Telescope colorscheme<cr>", opts)
        map("n", "<leader>la", "<cmd>Telescope lsp_code_actions<cr>", opts)
        map("v", "<leader>la", "<cmd>Telescope lsp_range_code_actions<cr>", opts)
        map("n", "<leader>ld", "<cmd>Telescope document_diagnostics<cr>",
            opts)
        map("n", "<leader>lD", "<cmd>Telescope workspace_diagnostics<cr>", opts)
        map("n", "<F12>", "<cmd>Telescope<cr>", opts)
        require("telescope").setup {
          defaults = {
            mappings = {
              i = {
                ["<esc>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-b>"] = actions.preview_scrolling_up,
                ["<C-f>"] = actions.preview_scrolling_down,
                ["<cr>"] = actions.select_default + actions.center,
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
                ["<C-l>"] = actions.complete_tag
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
        {"hrsh7th/cmp-nvim-lsp", after = "nvim-cmp"},
        {"hrsh7th/cmp-path", after = "nvim-cmp"},
        {"hrsh7th/cmp-buffer", after = "nvim-cmp"},
        {"hrsh7th/cmp-calc", after = "nvim-cmp"}
      },
      config = function()
        local cmp = require("cmp")
        cmp.setup({
          experimental = {native_menu = true},
          mapping = {
            ['<C-n>'] = cmp.mapping.select_next_item({
              behavior = cmp.SelectBehavior.Insert
            }),
            ['<C-p>'] = cmp.mapping.select_prev_item({
              behavior = cmp.SelectBehavior.Insert
            }),
            ['<TAB>'] = cmp.mapping({
              c = function(fallback)
                if #cmp.core:get_sources() > 0 and
                    not cmp.get_config().experimental.native_menu then
                  if cmp.visible() then
                    cmp.select_next_item()
                  else
                    cmp.complete()
                  end
                else
                  fallback()
                end
              end
            }),
            ['<S-TAB>'] = cmp.mapping({
              c = function(fallback)
                if #cmp.core:get_sources() > 0 and
                    not cmp.get_config().experimental.native_menu then
                  if cmp.visible() then
                    cmp.select_prev_item()
                  else
                    cmp.complete()
                  end
                else
                  fallback()
                end
              end
            })
          },
          sources = {
            {name = "nvim_lsp"}, {name = "buffer"}, {name = "path"},
            {name = "nvim_lua"}
          }
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
        map("n", "<C-t>", ":Trouble workspace_diagnostics<cr>", opts)
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
          merge_keywords = true, -- when true, custom keywords will be merged with the defaults
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
               "<cmd>lua vim.diagnostic.show_line_diagnostics({show_header=false})<cr>",
               opts)
          bmap(bufnr, "n", "<M-m>",
               "<cmd>lua vim.diagnostic.goto_next({severity_limit='Warning', popup_opts={show_header=false}})<cr>",
               opts)
          bmap(bufnr, "n", "<M-n>",
               "<cmd>lua vim.diagnostic.goto_prev({severity_limit='Warning', popup_opts={show_header=false}})<cr>",
               opts)
          -- popups
          bmap(bufnr, "n", "<M-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>",
               opts)
          bmap(bufnr, "i", "<M-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>",
               opts)
          -- other
          if client.resolved_capabilities.goto_definition then
            bmap(bufnr, "n", "gd", ":lua vim.lsp.buf.definition()<cr>", opts)
          end
          if client.resolved_capabilities.find_references then
            bmap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
          end
          if client.resolved_capabilities.hover then
            bmap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
          end
          if client.resolved_capabilities.rename then
            bmap(bufnr, "n", "<M-r>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
          end
          if client.resolved_capabilities.document_formatting or
              client.resolved_capabilities.document_range_formatting then
            vim.api.nvim_command [[augroup Format]]
            vim.api.nvim_command [[autocmd! * <buffer>]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.py lua vim.lsp.buf.formatting_seq_sync()]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.lua lua vim.lsp.buf.formatting_seq_sync()]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.md lua vim.lsp.buf.formatting_seq_sync()]]
            vim.api
                .nvim_command [[autocmd BufWritePost *.yaml lua vim.lsp.buf.formatting_seq_sync()]]
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
                "!ConstantTensorAccessor mapping", "!DtypeTensor scalar",
                "!ImportClass scalar", "!ReferenceContainer mapping",
                "!ReferenceLink mapping", "!SeriesTensor mapping",
                "!SeriesTensorAccessor mapping", "!UDFtensorfactory scalar",
                "!UDFnu scalar", "!UDFvalidator scalar", "!Unit scalar",
                "!UserClass mapping", "!UserInstance mapping",
                "!getattr mapping"
              }
            }
          }
        }
        nvim_lsp.pyright.setup {
          on_attach = on_attach,
          settings = {
            python = {
              analysis = {
                diagnosticMode = "workspace",
                logLevel = "Warning",
                typeCheckingMode = "basic",
                autoImportCompletions = false
              }
            }
          }
        }
        nvim_lsp.efm.setup {
          on_attach = on_attach,
          init_options = {documentFormatting = true},
          filetypes = {"python", "markdown", "yaml", "lua", "javascript"},
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
                  formatCommand = "isort --stdout --profile black --force-single-line-imports -",
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
