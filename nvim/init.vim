set shell=bash
" -----------------------------------------------------------------------------
" plugins
" -----------------------------------------------------------------------------
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ~/.config/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif
let g:coc_global_extensions = [
      \ 'coc-fzf-preview',
      \ 'coc-python',
      \ 'coc-git',
      \ 'coc-tsserver',
      \ 'coc-diagnostic',
      \ 'coc-yaml'
      \ ]

call plug#begin('~/.config/nvim/plugged')
" tools
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
"Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'           " language syntax
Plug 'godlygeek/tabular'              " help aligning text on tabs
Plug 'tpope/vim-fugitive'
" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'plasticboy/vim-markdown'        " markdown helper.
Plug 'ferrine/md-img-paste.vim'
" helpers
Plug 'scrooloose/nerdcommenter'       " commenting tool
Plug 'tpope/vim-surround'             " parentheses helper
Plug 'mbbill/undotree'                " Persistent undo
Plug 'junegunn/vim-peekaboo'          " show paste buffers
Plug 'farmergreg/vim-lastplace'       " When reopen a buffer, puts the cursor where it was last time
Plug 'christoomey/vim-tmux-navigator' " integrate movement in tmux and vim
Plug 'haya14busa/vim-asterisk'        " better asterisk motions
Plug 'bfredl/nvim-miniyank'           " nvim bugfix block copy
"Plug 'terryma/vim-multiple-cursors'   " multiple cursors via 'C-n'
"Plug 'michaeljsmith/vim-indent-object' " define indent as a group to operate on
"Plug 'liuchengxu/vim-which-key'       " popuup for shortcuts like emacs
" aesthetics
Plug 'chriskempson/base16-vim'        " base16 themes
Plug 'junegunn/goyo.vim'              " zen mode
Plug 'junegunn/limelight.vim'         " highlight current paragraph
Plug 'PotatoesMaster/i3-vim-syntax'   " syntax highlighting for i3 file
Plug 'chrisbra/Colorizer'             " show color codes
Plug 'junegunn/rainbow_parentheses.vim' " colorize parentheses
" file mgmt
Plug 'jeetsukumaran/vim-buffergator'
Plug 'scrooloose/nerdtree'
"Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
"Plug 'vifm/vifm.vim'
"Plug 'rafaqz/ranger.vim'
" themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/seoul256.vim'
call plug#end()

" -----------------------------------------------------------------------------
" format
" -----------------------------------------------------------------------------
set t_Co=256       " Use 256 colors
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
if has("nvim")
  if $TERM =~ '^\(rxvt\)\(-.*\)\?$'
      set notermguicolors
  else
      set termguicolors
  endif
endif
"let g:airline_theme='molokai'
let g:airline_theme='qwq'
"let g:airline_theme='badwolf'
"let g:airline_theme='silver'
"let g:airline_theme='raven'

" Transparent Background (For i3 and compton)
highlight Normal guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE

" -----------------------------------------------------------------------------
" settings
" -----------------------------------------------------------------------------
" general
set cmdheight=2                       " height of command bar at the bottom. 1 is default
let g:BASH_Ctrl_j='off'             " avoid 'C-j' being overridden to newline
let g:BASH_Ctrl_l='off'             " avoid 'C-l' being overridden to newline
set updatetime=300
set timeoutlen=500
set lazyredraw
set shell=/usr/bin/bash
let $SHELL = "/usr/bin/bash"
set conceallevel=2

" fold config
set foldmethod=indent
set foldlevelstart=20
" zm/M zr/R increase/increase foldlevel (max)
" zo/O zc/C open / close fold (max)
" za zA switch fold (small/full)
" zi toggle folds
" zi zj move to next / prev fold

" indentation
set ai                                " auto indent
set si                                " smart indent

" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e

" default new file is markdown
autocmd BufEnter * if &filetype == "" | setlocal ft=markdown | endif

set tabstop=4
set softtabstop=4
set shiftwidth=4
set fileformat=unix
au Filetype python set
    \ tabstop=4
    \ softtabstop=4
    \ shiftwidth=4

au Filetype markdown,yaml set
    \ tabstop=2
    \ softtabstop=2
    \ shiftwidth=2
set expandtab
"
" Disables automatic commenting on newline:
"autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" -----------------------------------------------------------------------------
" keybinds
" -----------------------------------------------------------------------------
" general
let mapleader="\<SPACE>"
let maplocalleader=","
"nmap <silent> <leader> :WhichKey '<SPACE>'<cr>
tmap <C-x> <C-\><C-n>
nmap <esc><esc> :noh<cr>
if has('nvim')
    nmap <leader>R :so ~/.config/nvim/init.vim<cr>
    nmap <leader>E :tabe ~/.config/nvim/init.vim<cr>
else
    nmap <leader>R :so ~/.vimrc<cr>
    nmap <leader>E :tabe ~/.vimrc<cr>
endif
map q: <nop>
nmap Q <nop>
map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)

" search for selected text in visual mode
vnoremap // y/<C-R>"<CR>

" exit terminal
:tnoremap <F2> <C-\><C-n>

" keep selection after indenting
nmap <Tab> >>_
nmap <S-Tab> <<_
vmap <Tab> >gv
vmap <S-Tab> <gv

" move between windows by hjkl
nmap <silent> <M-h> :TmuxNavigateLeft<cr>
nmap <silent> <M-j> :TmuxNavigateDown<cr>
nmap <silent> <M-k> :TmuxNavigateUp<cr>
nmap <silent> <M-l> :TmuxNavigateRight<cr>

" make splits and tabs
nmap <leader><BAR> :vsplit<cr>
nmap <leader>- :split<cr>
nmap <leader>o :tabnew %<cr>

" resize windows with hjkl
nmap <C-h> <C-w><
nmap <C-j> <C-w>-
nmap <C-k> <C-w>+
nmap <C-l> <C-w>>

" other C-w commands to remember
" <C-w>BAR maximise
" <C-w>= equalize sizes
" <C-w>T move buffer to new tab
" move windows with <leader>+HJKL
" <C-w>H
" <C-w>J
" <C-w>K
" <C-w>L

" remove buffer
nmap <leader>d :bp<bar>sp<bar>bn<bar>bd<cr>
" nmap <leader>q :bd<cr>

" fullscreen mode and reset
map <M-g> :Goyo<cr>
map <M-w> <C-w>=
map <M-BAR> <C-w><BAR>
map <M--> <C-w>_

" tab management
nmap <leader>h :tabprevious<cr>
nmap <leader>l :tabnext<cr>
nmap <M-Left> :call MoveToNextTab()<cr>
nmap <M-Right> :call MoveToPrevTab()<cr>
nmap <silent> <C-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<cr>
nmap <silent> <C-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<cr>

" fzf
"nmap <C-p>g :GitFiles<ENTER>
"nmap <C-p>f :Files<ENTER>
"nmap <C-p>l :Ag<ENTER>
"nmap <C-p>L :Lines<ENTER>
"nmap <C-p>r :Rg<ENTER>
"nmap <C-p>b :Buffers<ENTER>
"nmap <C-p>c :Commands<ENTER>
"nmap <C-p>t :Colors<ENTER>
"nmap <C-p>m :Marks<ENTER>
"nmap <C-p>w :Windows<ENTER>
"nmap <F2> :Maps<ENTER>

nmap          <M-w>     :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
xmap          <M-w>     "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nmap          <M-W>     :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
nmap <silent> <M-e>     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
nmap <silent> <M-E>     :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nmap <silent> <M-r>     :<C-u>CocCommand fzf-preview.MruFiles<CR>
nmap <silent> <M-R>     :<C-u>CocCommand fzf-preview.ProjectMruFiles<CR>
nmap <silent> <M-f>     :<C-u>CocCommand fzf-preview.DirectoryFiles<CR>
nmap <silent> <M-F>     :<C-u>CocCommand fzf-preview.ProjectFiles<CR>
nmap <silent> <M-g>     :<C-u>CocCommand fzf-preview.GitStatus<CR>
nmap <silent> <M-G>     :<C-u>CocCommand fzf-preview.GitActions<CR>
nmap <silent> <M-b>     :<C-u>CocCommand fzf-preview.Buffers<CR>
nmap <silent> <M-B>     :<C-u>CocCommand fzf-preview.AllBuffers<CR>

" Close preview window when completion is done
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" coc menus
imap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
imap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"
imap <silent><expr> <C-space> coc#refresh()
" coc helpers
nmap gP <Plug>(coc-diagnostic-prev)
nmap gp <Plug>(coc-diagnostic-next)
nmap gd <Plug>(coc-definition)
nmap gy <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)
nmap gR <Plug>(coc-refactor)
" coc git
nmap <leader>gn <Plug>(coc-git-nextchunk)
nmap <leader>gp <Plug>(coc-git-prevchunk)
nmap <leader>g<cr> <Plug>(coc-git-chunkinfo)
nmap <leader>gs :CocCommand git.chunkStage<CR>
vmap <leader>gs :CocCommand git.chunkStage<CR>
nmap <leader>gX :CocCommand git.chunkUndo<CR>
vmap <leader>gX :CocCommand git.chunkUndo<CR>

" vim-fugitive
" g? for fugitive help. :Gdiff, :Gblame, :Gstats '=' expand, '-' add/reset changes, :Gcommit % to commit current file with messag
nmap <leader>gg :vertical Gstatus<cr>:vertical resize 60<cr>

" nerdtree
map <C-f> :NERDTreeToggle<cr>

" nerdcommenter
" '<leader>c ', '<leader>cl' aligned and '<leader>cu>' remove

" vim-surround
" Visual: 'SA' to wrap in A. Surround: 'csAB' to change from A to B, 'dsA' to remove A. Word: 'ysiwA' to wrap with A

" tabular
" line up selected text by :Tabularize /[identifier]

" vim markdown

" vim asterisk

map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)

" buffergator
map <C-b> :BuffergatorToggle<cr>
map <C-t> :BuffergatorTabsToggle<cr>
nmap <leader>j :BuffergatorMruCyclePrev<cr>
nmap <leader>k :BuffergatorMruCycleNext<cr>

" -----------------------------------------------------------------------------
" plugin config
" -----------------------------------------------------------------------------
" tmux navigator
let g:tmux_navigator_no_mappings=1

" undotree defaults
set undodir=~/.vim/undo/

" Goyo plugin makes text more readable when writing prose:
let g:goyo_width=120
let g:goyo_height=85
let g:goyo_linenr=1
function! s:goyo_enter()
    Limelight
endfunction

function! s:goyo_leave()
    highlight Normal guibg=NONE ctermbg=NONE
    highlight LineNr guibg=NONE ctermbg=NONE
    Limelight!
endfunction
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" Limelight
let g:limelight_conceal_ctermfg='gray'     " Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_guifg='DarkGray'   " Color name (:help gui-colors) or RGB color
let g:limelight_default_coefficient=0.7
let g:limelight_paragraph_span=0           " Number of preceding/following paragraphs to include (default: 0)
let g:limelight_priority=-1                " Highlighting priority (default: 10). Set it to -1 not to overrule hlsearch
let g:limelight_bop='^\n^'
let g:limelight_eop='\ze\n\n'

" NerdTree
" Nerd tree autostart if empty
" autocmd vimenter * NERDTree
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Nerd tree binding
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Airline
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_splits=0
"let g:airline#extensions#tabline#show_tabs=0
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#switch_buffers_and_tabs=0
let g:airline_powerline_fonts=1

" vim-markdown
let g:vim_markdown_new_list_item_indent=0
let g:vim_markdown_conceal=0
let g:vim_markdown_conceal_code_blocks=0
let g:vim_markdown_math=1
let g:vim_markdown_folding_disabled=0
let g:vim_markdown_math=0

" markdown preview
let g:mkdp_auto_start=0             " auto start on moving into
let g:mkdp_auto_close=0             " auto close on moving away
let g:mkdp_open_to_the_world=0      " available to others
let g:mkdp_open_ip=''               " use custom IP to open preview page
let g:mkdp_preview_options={
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1
    \ }
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative'
" hide_yaml_meta: if hide yaml metadata, default is 1

" md-img-paste
autocmd FileType markdown nmap <buffer><silent> <leader>p :call mdip#MarkdownClipboardImage()<CR>

" peekaboo
let g:peekaboo_window='vert bo 80new'
let g:peekaboo_delay=1000
let g:peekaboo_compact=0

" coc
function! s:check_back_space() abort
  let col=col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
nmap <silent> K :call <SID>show_documentation()<CR>
let g:coc_node_path = '/usr/bin/node'
let g:fzf_preview_command = 'bat --color=always --plain {-1}' " Installed bat
let g:fzf_preview_grep_cmd = 'rg --smart-case --line-number --no-heading --color=never'

" vim asterisk
let g:asterisk#keeppos = 1

" buffgator
let g:buffergator_mru_cycle_loop = 0
let g:buffergator_suppress_keymaps = 1
let g:buffergator_autoupdate = 1
let g:buffergator_sort_regime = 'mru'
let g:buffergator_display_regime = 'basename'
let g:buffergator_autodismiss_on_select = 0

" -----------------------------------------------------------------------------
" functions
" -----------------------------------------------------------------------------
" coc
" show documentation in preview window
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" for moving of tabs
if !exists("*MoveToPrevTab")
  function MoveToPrevTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
      return
    endif
    "preparing new window
    let l:tab_nr=tabpagenr('$')
    let l:cur_buf=bufnr('%')
    if tabpagenr() != 1
      close!
      if l:tab_nr == tabpagenr('$')
        tabprev
      endif
      sp
    else
      close!
      exe "0tabnew"
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
  endfunc
endif

if !exists("*MoveToNextTab()")
  function MoveToNextTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
      return
    endif
    "preparing new window
    let l:tab_nr=tabpagenr('$')
    let l:cur_buf=bufnr('%')
    if tabpagenr() < tab_nr
      close!
      if l:tab_nr == tabpagenr('$')
        tabnext
      endif
      sp
    else
      close!
      tabnew
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
  endfunc
endif


" -----------------------------------------------------------------------------
" default settings config
" -----------------------------------------------------------------------------

" default.vim - Better vim than the default
" Maintainer:   Liu-Cheng Xu <https://github.com/liuchengxu>
" Version:      1.0
" vim: et ts=2 sts=2 sw=2

set shortmess=atOI " No help Uganda information, and overwrite read messages to avoid PRESS ENTER prompts
set ignorecase     " Case insensitive search
set wildignorecase
set smartcase      " ... but case sensitive when uc present
set scrolljump=5   " Line to scroll when cursor leaves screen
set scrolloff=3    " Minumum lines to keep above and below cursor
set nowrap         " Do not wrap long lines
set splitright     " Puts new vsplit windows to the right of the current
set splitbelow     " Puts new split windows to the bottom of the current
set mousehide      " Hide the mouse cursor while typing
set hidden         " Allow buffer switching without saving
set ruler          " Show the ruler
set showcmd        " Show partial commands in status line and Selected characters/lines in visual mode
set showmode       " Show current mode in command-line
set showmatch      " Show matching brackets/parentthesis
set matchtime=5    " Show matching time
set report=0       " Always report changed lines
set linespace=0    " No extra spaces between rows

set winminheight=0

set listchars=tab:→\ ,eol:↵,trail:·,extends:↷,precedes:↶

set whichwrap+=<,>,h,l  " Allow backspace and cursor keys to cross line boundaries

set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

set wildignore+=*swp,*.class,*.pyc,*.png,*.jpg,*.gif,*.zip
set wildignore+=*/tmp/*,*.o,*.obj,*.so     " Unix
set wildignore+=*\\tmp\\*,*.exe            " Windows

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv
" Treat long lines as break lines (useful when moving around in them)
nmap j gj
nmap k gk
vmap j gj
vmap k gk

set nobackup
set noswapfile
set nowritebackup

set cursorline              " Highlight current line
set fileformats=unix,dos,mac        " Use Unix as the standard file type
set number                  " Line numbers on
set fillchars=vert:│,stl:\ ,stlnc:\

" Annoying temporary files
set directory=/tmp//,.
set backupdir=/tmp//,.

highlight clear SignColumn  " SignColumn should match background

if has('unnamedplus')
  set clipboard+=unnamedplus
else
  set clipboard+=unnamed
endif

set undofile             " Persistent undo
set undolevels=500       " Maximum number of changes that can be undone
set undoreload=5000      " Maximum number lines to save for undo on a buffer reload

" Insert mode shortcut
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-b> <BS>
" Bash like
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Delete>
" Command mode shortcut
cnoremap <C-h> <BS>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Delete>
" Quit visual mode
vnoremap v <Esc>
" Move to the start of line
nmap H ^
" Move to the end of line
nmap L $
" Quick command mode
nmap <CR> :
" In the quickfix window, <CR> is used to jump to the error under the
" cursor, so undefine the mapping there.
autocmd BufReadPost quickfix nmap <buffer> <CR> <CR>
" Open shell in vim
map <Leader>' :terminal<CR>
