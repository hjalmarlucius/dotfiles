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
opt.list = true                     -- Show listchars
opt.showtabline = 2

-- undo
opt.undodir = "/home/hjalmarlucius/.cache/vim/undo"
opt.undofile = true
opt.undolevels = 1000
opt.undoreload = 10000

-- window
opt.splitbelow = true               -- Put new windows below current
opt.splitright = true               -- Put new windows right of current

-- buffer
opt.hidden = true                   -- Enable background buffers
opt.wrap = false                    -- Disable line wrap
opt.number = true                   -- Show line numbers
opt.relativenumber = true           -- Relative line numbers
opt.cursorline = false              -- Highlight current line
opt.switchbuf = "useopen"           -- Use existing window if buffer is already open
opt.colorcolumn = "88"

-- tabs
opt.expandtab = true                -- Use spaces instead of tabs
opt.smartindent = false             -- Avoid fucking with comment indents
opt.shiftround = true               -- Round indent
opt.tabstop = 2                     -- Number of spaces tabs count for
opt.shiftwidth = 2                  -- Size of an indent

-- search
opt.ignorecase = true               -- Ignore case
opt.smartcase = true                -- Do not ignore case with capitals
opt.wildmode = {"list:longest"}     -- Command-line completion mode
opt.wildignorecase = true
opt.wildignore = opt.wildignore + {"*swp", "*.class", "*.pyc", "*.png", "*.jpg", "*.gif", "*.zip", "*/tmp/*", "*.o", ".obj", "*.so"}

-- cursor
opt.scrolloff = 5                   -- Lines of context
opt.scrolljump = 1                  -- Lines to scroll when cursor leaves screen
opt.sidescrolloff = 4               -- Columns of context
opt.showmatch = true                -- Show matching brackets / parentheses

-- editing
opt.joinspaces = false              -- No double spaces with join
opt.timeoutlen = 500                -- How long to wait during key combo
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

-- ----------------------------------------
-- AUTOCOMMANDS
-- ----------------------------------------
-- highlight on yank
local cmd = vim.cmd

vim.api.nvim_command [[augroup MYAU]]
vim.api.nvim_command [[autocmd!]]
vim.api.nvim_command [[autocmd BufWritePre * %s/\s\+$//e]]
vim.api.nvim_command [[autocmd BufWritePre *.py silent! execute ':Black']]
vim.api.nvim_command [[autocmd BufReadPost quickfix nmap <buffer> <cr> <cr>]]
vim.api.nvim_command [[autocmd TextYankPost * "lua vim.highlight.on_yank {on_visual = false}"]]
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

map("n", "<leader>E", [[:so ~/.config/nvim/init.lua<cr>:PackerInstall<cr>:PackerCompile<cr>]], { noremap = true })
map("n", "<leader>e", [[:vnew ~/dotfiles/nvim/init.lua<cr>]], { noremap = true })
map("n", "<leader>nt", [[:vnew ~/notes/todos.md<cr>]], { noremap = true })
map("n", "<leader>nc", [[:vnew ~/notes/cheatsheet.md<cr>]], { noremap = true })
map("n", "<leader>nl", [[:vnew ~/notes/libs.md<cr>]], { noremap = true })
map("n", "<leader>nu", [[:vnew ~/notes/urls.md<cr>]], { noremap = true })
map("n", "<leader>nn", [[:Explore ~/notes<cr>]], { noremap = true })
map("n", "<leader>ww", [[:cd %:p:h<cr>]], { noremap = true })
map("n", "<esc><esc>", ":noh<cr>", { silent = true, noremap = true } )

-- <Tab> to navigate the completion menu
map("i", "<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true, noremap = true })
map("i", "<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true, noremap = true })

-- CURSOR
-- stay visual when indenting
map("n", "-", "_", { noremap = true })
map("v", "v", "<esc>", { noremap = true })
map("v", "<Tab>", ">gv", { noremap = true })
map("v", "<S-Tab>", "<gv", { noremap = true })
map("n", "<leader>o", "m`o<Esc>``", { noremap = true })  -- Insert a newline in normal mode

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
map("n", "<C-h>", "<C-w><", { noremap = true })
map("n", "<C-j>", "<C-w>-", { noremap = true })
map("n", "<C-k>", "<C-w>+", { noremap = true })
map("n", "<C-l>", "<C-w>>", { noremap = true })
-- quickfix window
map("n", "<C-n>", ":cp<cr>", { noremap = true })
map("n", "<C-m>", ":cn<cr>", { noremap = true })
-- remove buffer
map("n", "<M-d>", ":bprev<bar>:bd#<cr>", { noremap = true })
map("n", "<M-D>", ":bprev<bar>:bd!#<cr>", { noremap = true })

-- ----------------------------------------
-- PACKER
-- ----------------------------------------
local install_path = vim.fn.stdpath("data").."/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({"git", "clone", "https://github.com/wbthomason/packer.nvim", install_path})
  vim.api.nvim_command "packadd packer.nvim"
end

require("packer").startup {function(use)
  use {"wbthomason/packer.nvim"}

  -- tpope
  use {"tpope/vim-sensible"}                -- sensible default
  use {"tpope/vim-commentary"}              -- comment out stuff
  use {"tpope/vim-surround"}
  use {"tpope/vim-repeat"}                  -- repeat vim-surround with .
  use {"tpope/vim-eunuch"}                  -- Move, Rename etc
  use {"farmergreg/vim-lastplace"}          -- keep location upon reopening

  -- smooth scrolling
  use {"psliwka/vim-smoothie"}

  -- tables
  use {"dhruvasagar/vim-table-mode"}

  -- git
  use {"tpope/vim-fugitive",
    config = function()
      local map = vim.api.nvim_set_keymap
      map("", "<C-g>", ":vertical Git<cr>:vertical resize 60<cr>", {})
    end
  }

  use {
    "lewis6991/gitsigns.nvim",
    requires = {"nvim-lua/plenary.nvim"},
    config = function()
      require("gitsigns").setup{
        numhl = false,
        linehl = false,
        keymaps = {
          -- Default keymap options
          noremap = true,
          buffer = true,

          ["n <M-.>"] = { expr = true, [[&diff ? "]c" : "<cmd>lua require('gitsigns.actions').next_hunk()<cr>"]]},
          ["n <M-,>"] = { expr = true, [[&diff ? "[c" : "<cmd>lua require('gitsigns.actions').prev_hunk()<cr>"]]},

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
        word_diff = false,
      }
    end
  }

  -- folder tree
  use {"kyazdani42/nvim-tree.lua",
    requires = {"kyazdani42/nvim-web-devicons"},
    config = function()
      vim.g.nvim_tree_auto_open = 0
      vim.g.nvim_tree_disable_netrw = 0
      local map = vim.api.nvim_set_keymap
      map("n", "<M-p>", ":NvimTreeToggle<cr>", {noremap = true})
      map("n", "<M-P>", ":NvimTreeRefresh<cr>", {noremap = true})
      map("n", "<M-7>", ":NvimTreeFindFile<cr>", {noremap = true})
    end
  }

  -- theme
  use {"folke/tokyonight.nvim",
    config = function()
      vim.g.tokyonight_style = "night"
    end
  }

  use {"sonph/onehalf", rtp = "vim", }
  use {"tomasr/molokai", }
  use {"morhetz/gruvbox", }
  use {"jnurmine/Zenburn", }
  use {"nanotech/jellybeans.vim", }
  use {"mhartington/oceanic-next", }
  use {"NLKNguyen/papercolor-theme", }
  use {"drewtempelmeyer/palenight.vim", }
  use {"altercation/vim-colors-solarized", }
  use {"rakr/vim-one",
    config = function()
      vim.g.one_allow_italics = 1
    end
  }

  use {"ayu-theme/ayu-vim",
    config = function()
      -- vim.g.ayucolor = "light"
      -- vim.g.ayucolor = "mirage"
      vim.g.ayucolor = "dark"
    end
  }

  use {"skbolton/embark",
    config = function()
      vim.g.embark_terminal_italics = 1
    end
  }

  use {"arcticicestudio/nord-vim",
    config = function()
    end
  }

  use {"junegunn/seoul256.vim",
    config = function()
      vim.g.seoul256_background = 235
    end
  }
  vim.cmd "colorscheme zenburn"

  -- coloring of colornames
  use {"rrethy/vim-hexokinase",
    run = "cd /home/hjalmarlucius/.local/share/nvim/site/pack/packer/start/vim-hexokinase && make hexokinase",
    config = function()
      vim.g.Hexokinase_highlighters = {"backgroundfull"}
    end
  }

  -- flashing cursor on move
  use {"danilamihailov/beacon.nvim",
    setup = function()
      vim.api.nvim_exec( [[highlight Beacon guibg=white ctermbg=15]], false)
    end,
    config = function()
      vim.g.beacon_size = 40
      vim.g.beacon_minimal_jump = 10
      vim.g.beacon_shrink = 1
    end
  }

  -- indentation guides
  use {"lukas-reineke/indent-blankline.nvim",
    config = function()
      vim.g.indent_blankline_char = "|"
      vim.g.indent_blankline_use_treesitter = true
    end
  }

  use {"haya14busa/vim-asterisk",
    config = function()
      vim.g["asterisk#keeppos"] = 1
      local map = vim.api.nvim_set_keymap
      map("", "*", "<Plug>(asterisk-z*)", {})
      map("", "#", "<Plug>(asterisk-z#)", {})
      map("", "g*", "<Plug>(asterisk-gz*)", {})
      map("", "g#", "<Plug>(asterisk-gz#)", {})
    end
  }

  use {"christoomey/vim-tmux-navigator",
    config = function()
      vim.g.tmux_navigator_no_mappings = 1
      vim.g.tmux_navigator_disable_when_zoomed = 1
      local map = vim.api.nvim_set_keymap
      opts = { silent = true, noremap = true }
      map("n", "<M-h>", ":TmuxNavigateLeft<cr>", opts)
      map("n", "<M-j>", ":TmuxNavigateDown<cr>", opts)
      map("n", "<M-k>", ":TmuxNavigateUp<cr>", opts)
      map("n", "<M-l>", ":TmuxNavigateRight<cr>", opts)
    end
  }

  use {"dkarter/bullets.vim",
    config = function()
      vim.g.bullets_outline_levels = {"ROM", "ABC", "num", "abc", "rom", "std-", "std*"}
      vim.g.bullets_enabled_file_types = {"markdown", "text", "gitcommit"}
    end
  }

  use {"mbbill/undotree",
    config = function()
      local map = vim.api.nvim_set_keymap
      map("", "<C-t>", ":UndotreeToggle<cr>:UndotreeFocus<cr>", { noremap = true })
    end
}

  use {"iamcco/markdown-preview.nvim", -- requires yarn
    run = "cd /home/hjalmarlucius/.local/share/nvim/site/pack/packer/start/markdown-preview && yarn install",
    config = function()
      vim.g.mkdp_auto_start = 0             -- auto start on moving into
      vim.g.mkdp_auto_close = 0             -- auto close on moving away
      vim.g.mkdp_open_to_the_world = 0      -- available to others
      vim.g.mkdp_open_ip = ""               -- use custom IP to open preview page
    end
  }

  use {"hoob3rt/lualine.nvim",
    requires = {"kyazdani42/nvim-web-devicons"},
    config = function()
      require("lualine").setup {
        options = {
          theme = "auto",
        },
        extensions = {
          "fugitive",
        },
        sections = {
          lualine_a = {"mode"},
          lualine_b = {"branch"},
          lualine_c = {{"filename", file_status = true, path = 1}, {"diff", colored=false}, { "diagnostics", sources = {"nvim_lsp"}}},
          lualine_x = {"encoding", "fileformat", "filetype"},
          lualine_y = {"progress"},
          lualine_z = {"location"}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {{"filename", file_status = true, path = 1}},
          lualine_x = {"location"},
          lualine_y = {"progress"},
          lualine_z = {}
        },
      }
    end
  }

  use {"akinsho/nvim-bufferline.lua",
    requires = {"kyazdani42/nvim-web-devicons"},
    config = function()
      require("bufferline").setup{
        options = {
          diagnostics = "nvim_lsp",
        }
      }
      local map = vim.api.nvim_set_keymap
      map("n", "<M-J>", ":BufferLineCyclePrev<cr>", { noremap = true, silent=true })
      map("n", "<M-K>", ":BufferLineCycleNext<cr>", { noremap = true, silent=true })
      map("n", "<M-N>", ":BufferLineMovePrev<cr>", { noremap = true, silent=true })
      map("n", "<M-M>", ":BufferLineMoveNext<cr>", { noremap = true, silent=true })
    end
  }

  use {"numtostr/FTerm.nvim",
    config = function()
      require("FTerm").setup{}
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }
      map("n", "<F2>", [[<cmd>lua require("FTerm").toggle()<cr>]], opts)
      map("t", "<F2>", [[<C-\><C-n><cmd>lua require("FTerm").toggle()<cr>]], opts)
    end
  }

  use {"psf/black"}

-- treesitter
use {"nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = "all",
      }
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end
  }

  use {"nvim-telescope/telescope.nvim",
    requires = {"nvim-lua/popup.nvim", "nvim-lua/plenary.nvim"},
    config = function()
      -- TODO grep with regex
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true }
      local actions = require("telescope.actions")
      map("n", "<M-F>", "<cmd>Telescope find_files<cr>", opts )
      map("n", "<M-f>", "<cmd>Telescope git_files<cr>", opts )
      map("n", "<M-w>", "<cmd>Telescope live_grep<cr>", opts )
      map("n", "<M-b>", "<cmd>Telescope buffers<cr>", opts )
      -- map("n", "<M-y>", "<cmd>Telescope filetypes<cr>", opts )
      map("n", "<F3>", "<cmd>Telescope colorscheme<cr>", opts )
      map("n", "<leader>la", "<cmd>Telescope lsp_code_actions<cr>", opts )
      map("v", "<leader>la", "<cmd>Telescope lsp_range_code_actions<cr>", opts )
      map("n", "<leader>ld", "<cmd>Telescope lsp_document_diagnostics<cr>", opts )
      map("n", "<leader>lD", "<cmd>Telescope lsp_workspace_diagnostics<cr>", opts )
      map("n", "<leader>gg", "<cmd>Telescope git_status<cr>", opts )
      map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", opts )
      map("n", "<leader>gC", "<cmd>Telescope git_bcommits<cr>", opts )
      map("n", "<F12>", "<cmd>Telescope<cr>", opts )
      require("telescope").setup{
        defaults = {
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            -- "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
          },
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
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag
            },
          },
          file_ignore_patterns = {},
          set_env = { ["COLORTERM"] = "truecolor" },
        },
      }
    end }

  -- debugging
  -- use {"mfussenegger/nvim-dap-python",
  --   requires = {"mfussenegger/nvim-dap"},
  --   config = function()
  --     require("dap-python").setup("/usr/bin/python")
  --     local map = vim.api.nvim_set_keymap
  --     local opts = { noremap = true, silent = true }
  --     map("n", "<F5>", [[:lua require("dap").continue()<cr>]], opts)
  --     map("n", "<F10>", [[:lua require("dap").step_over()<cr>]], opts)
  --     map("n", "<F11>", [[:lua require("dap").step_into()<cr>]], opts)
  --     map("n", "<F12>", [[:lua require("dap").step_out()<cr>]], opts)
  --     map("n", "<F6>", [[:lua require("dap").toggle_breakpoint()<cr>]], opts)
  --     map("n", "<F7>", [[:lua require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>]], opts)
  --     map("n", "<S-F7>", [[:lua require("dap").set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<cr>]], opts)
  --     map("n", "<F4>", [[:lua require("dap").repl.open()<cr>]], opts)
  --     map("n", "<leader>vl", [[:lua require("dap").repl.run_last()<cr>`]], opts)
  --     map("n", "<leader>vt", [[:lua require('dap-python').test_method()<cr>]], opts)
  --     map("v", "<leader>vs", [[<ESC>:lua require('dap-python').debug_selection()<cr>]], opts)
  --   end
  -- }

  -- use {"nvim-telescope/telescope-dap.nvim",
  --   requires = {"mfussenegger/nvim-dap", "nvim-telescope/telescope.nvim"},
  --   config = function()
  --     require("telescope").load_extension("dap")
  --     local map = vim.api.nvim_set_keymap
  --     local opts = { noremap = true, silent = true }
  --     map("n", "<M-1>", [[:lua require("telescope").extensions.dap.commands{}<cr>]], opts)
  --     map("n", "<M-2>", [[:lua require("telescope").extensions.dap.configurations{}<cr>]], opts)
  --     map("n", "<M-3>", [[:lua require("telescope").extensions.dap.list_breakpoints{}<cr>]], opts)
  --     map("n", "<M-4>", [[:lua require("telescope").extensions.dap.variables{}<cr>]], opts)
  --   end
  -- }

  -- autocompletion
  use {"hrsh7th/nvim-compe",
    config = function()
      vim.opt.completeopt = "menuone,noselect"
      require("compe").setup {
        source = {
          nvim_lsp = true,
          path = true,
          buffer = true,
          calc = true,
          nvim_lua = true,
        },
      }
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true, expr = true }
      map("i", "<C-space>", [[compe#complete()]], opts)
      map("i", "<cr>", [[compe#confirm("<cr>")]], opts)
      map("i", "<C-e>", [[compe#close("<C-e>")]], opts)
      -- TODO don't seem useful?
      -- map("i", "<C-f>", [[compe#scroll({ "delta": +4 })]], opts)
      -- map("i", "<C-b>", [[compe#scroll({ "delta": -4 })]], opts)
    end
  }

  use {
  "folke/trouble.nvim",
  requires = "kyazdani42/nvim-web-devicons",
  config = function()
    require("trouble").setup {
      position = "right", -- position of the list can be: bottom, top, left, right
      height = 10, -- height of the trouble list when position is top or bottom
      width = 60, -- width of the list when position is left or right
      icons = true, -- use devicons for filenames
      mode = "lsp_workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
      fold_open = "", -- icon used for open folds
      fold_closed = "", -- icon used for closed folds
      action_keys = { -- key mappings for actions in the trouble list
          close = "q", -- close the list
          cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
          refresh = "r", -- manually refresh
          jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
          open_split = { "<c-s>" }, -- open buffer in new split
          open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
          open_tab = { "<c-t>" }, -- open buffer in new tab
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
      auto_fold = false, -- automatically fold a file trouble list at creation
    }
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true }
      map("n", "<F5>", ":Trouble<cr>", opts)
  end
  }

  use {"folke/todo-comments.nvim",
    requires = {"nvim-lua/plenary.nvim"},
    config = function()
      require("todo-comments").setup {
        signs = true, -- show icons in the signs column
        sign_priority = 8, -- sign priority
        -- keywords recognized as todo comments
        keywords = {
          FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
          TODO = { icon = " ", color = "info" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        },
        merge_keywords = true, -- when true, custom keywords will be merged with the defaults
        colors = {
          error = { "LspDiagnosticsDefaultError", "ErrorMsg", "#DC2626" },
          warning = { "LspDiagnosticsDefaultWarning", "WarningMsg", "#FBBF24" },
          info = { "LspDiagnosticsDefaultInformation", "#10B981" },
          hint = { "LspDiagnosticsDefaultHint", "#7C3AED" },
          default = { "Identifier", "#2563EB" },
        },
      }
      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true }
      map("n", "<F4>", ":TodoTrouble<cr>", opts)
    end
  }

  use {"glepnir/lspsaga.nvim",
    requires = {"neovim/nvim-lspconfig"},
    run = ":TSUpdate",
    config = function()
        -- see https://github.com/lukas-reineke/dotfiles/blob/master/vim/lua/lsp/init.lua
        on_attach = function (client, bufnr)
          local bmap = vim.api.nvim_buf_set_keymap
          local opts = { noremap = true }
          vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
          vim.lsp.set_log_level("error")
          -- workspaces
          bmap(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", opts)
          bmap(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", opts)
          bmap(bufnr, "n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", opts)
          -- jump
          bmap(bufnr, "n", "gl", "<cmd>lua vim.lsp.diagnostic.set_loclist({severity_limit='Warning'})<cr>", opts)
          bmap(bufnr, "n", "<M-i>", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({show_header=false})<cr>", opts)
          bmap(bufnr, "n", "<M-m>", "<cmd>lua vim.lsp.diagnostic.goto_next({severity_limit='Warning', popup_opts={show_header=false}})<cr>", opts)
          bmap(bufnr, "n", "<M-n>", "<cmd>lua vim.lsp.diagnostic.goto_prev({severity_limit='Warning', popup_opts={show_header=false}})<cr>", opts)
          -- popups
          bmap(bufnr, "n", "<M-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
          bmap(bufnr, "i", "<M-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
          bmap(bufnr, "n", "<C-f>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<cr>", opts)
          bmap(bufnr, "n", "<C-b>", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<cr>", opts)
          -- other
          if client.resolved_capabilities.goto_definition then
            bmap(bufnr, "n", "gd", ":Lspsaga preview_definition<cr>", opts)
            bmap(bufnr, "n", "gD", ":lua vim.lsp.buf.definition()<cr>", opts)
          end
          if client.resolved_capabilities.find_references then
            bmap(bufnr, "n", "gr", ":Lspsaga lsp_finder<cr>", opts)
          end
          if client.resolved_capabilities.hover then
            bmap(bufnr, "n", "K", ":Lspsaga hover_doc<cr>", opts)
          end
          if client.resolved_capabilities.rename then
            bmap(bufnr, "n", "<M-r>", ":Lspsaga rename<cr>", opts)
          end
        end
      use_saga_diagnostic_sign = true
      require("lspsaga").init_lsp_saga {
        max_preview_lines = 20,
        finder_action_keys = {
          quit = {"<esc>", "C-c"},
          open = "<cr>",
          vsplit = "v",
          split = "s",
          scroll_down = "<C-f>",
          scroll_up = "<C-b>"
        },
        code_action_keys = {
          quit = {"<esc>", "C-c"},
          exec = "<cr>"
        },
        rename_action_keys = {
          quit = {"<esc>", "C-c"},
          exec = "<cr>"
        },
      }
      local nvim_lsp = require("lspconfig")
      -- sudo npm install -g typescript typescript-language-server
      nvim_lsp.tsserver.setup{}
      -- sudo npm install -g yaml-language-server
      nvim_lsp.yamlls.setup{
        on_attach = on_attach
      }
      -- sudo npm install -g pyright
      nvim_lsp.pyright.setup{
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              diagnosticMode = "workspace",
              logLevel = "Warning",
              typeCheckingMode = "strict",
            }
          }
        }
      }
      local prettier = {
        formatCommand = ([[prettier ${--config-precedence:configPrecedence} ${--tab-width:tabWidth} ${--single-quote:singleQuote} ${--trailing-comma:trailingComma}]])
      }
      nvim_lsp.efm.setup{
        on_attach = on_attach,
        init_options = { documentFormatting = true },
        filetypes = { "python", "markdown", "yaml", "lua", "javascript" },
        root_dir = vim.loop.cwd,
        settings = {
          rootMarkers = { ".git/" },
          languages = {
            python = {
              -- {
              --   lintCommand = "flake8 --max-line-length 88 --format '%(path)s:%(row)d:%(col)d: %(code)s %(code)s %(text)s' --stdin-display-name ${INPUT} -",
              --   lintStdin = true,
              --   lintIgnoreExitCode = true,
              --   lintFormats = {"%f:%l:%c: %t%n%n%n %m"},
              --   lintSource = "flake8"
              -- },
              {
                formatCommand = "isort --stdout --profile black --force-single-line-imports -",
                formatStdin = true
              },
            },
            javascript = {prettier, eslint},
            yaml = {prettier},
            markdown = {prettier},
          },
        },
      }
    end
  }
end
}
