set shell=bash
" -----------------------------------------------------------------------------
" PLUGINS
" -----------------------------------------------------------------------------
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ~/.config/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif
let g:coc_global_extensions=[
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
Plug 'sheerun/vim-polyglot'           " language syntax
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'plasticboy/vim-markdown'        " markdown helper.
" helpers
Plug 'scrooloose/nerdcommenter'       " commenting tool
Plug 'tpope/vim-surround'             " parentheses helper
Plug 'mbbill/undotree'                " Persistent undo
Plug 'farmergreg/vim-lastplace'       " When reopen a buffer, puts the cursor where it was last time
Plug 'christoomey/vim-tmux-navigator' " integrate movement in tmux and vim
Plug 'haya14busa/vim-asterisk'        " better asterisk motions
Plug 'bfredl/nvim-miniyank'           " nvim bugfix block copy
Plug 'qpkorr/vim-bufkill'             " delete buffer without closing window
" aesthetics
Plug 'chriskempson/base16-vim'        " base16 themes
Plug 'chrisbra/Colorizer'             " show color codes
Plug 'junegunn/rainbow_parentheses.vim' " colorize parentheses
" file mgmt
Plug 'jeetsukumaran/vim-buffergator'
Plug 'scrooloose/nerdtree'
" themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/seoul256.vim'
call plug#end()

" -----------------------------------------------------------------------------
" SETTINGS
" -----------------------------------------------------------------------------
" colors
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
if $TERM =~ '^\(rxvt\)\(-.*\)\?$'
  set notermguicolors
else
  set termguicolors
endif

" Transparent Background (For i3 and compton)
"highlight Normal guibg=NONE ctermbg=NONE
"highlight LineNr guibg=NONE ctermbg=NONE

" seoul256 theme config (dark 233-239, light 252-256)
let g:seoul256_background=233
colo seoul256

" statusline
set cmdheight=1
let g:airline_powerline_fonts=1
"let g:airline_theme='molokai'
"let g:airline_theme='qwq'
"let g:airline_theme='badwolf'
"let g:airline_theme='silver'
let g:airline_theme='raven'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#show_splits=0
let g:airline#extensions#tabline#show_tabs=0
let g:airline#extensions#tabline#show_buffers=1
let g:airline#extensions#tabline#switch_buffers_and_tabs=0

" temporary files and undo
set directory=/tmp//,.
set backupdir=/tmp//,.
set undodir=~/.vim/undo/
set noswapfile
set nowritebackup
set undofile             " Persistent undo
set undolevels=500       " Maximum number of changes that can be undone
set undoreload=5000      " Maximum number lines to save for undo on a buffer reload

" search
set ignorecase     " Case insensitive search
set smartcase      " ... but case sensitive when uc present

" cursor
set scrolljump=5   " Line to scroll when cursor leaves screen
set scrolloff=3    " Minumum lines to keep above and below cursor

" buffers
set splitright     " Puts new vsplit windows to the right of the current
set splitbelow     " Puts new split windows to the bottom of the current
set hidden         " Allow buffer switching without saving

" buffer
set nowrap         " Do not wrap long lines
set cursorline     " Highlight current line
set number         " Line numbers on

" parentheses
set showmatch      " Show matching brackets/parentthesis
set matchtime=5    " Show matching time

" files and encodings
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set fileformats=unix,dos,mac

" indentation and folds
set smartindent
set foldmethod=indent
set foldlevelstart=20
" zm/M zr/R increase/increase foldlevel (max)
" zo/O zc/C open / close fold (max)
" za zA switch fold (small/full)
" zi toggle folds
" zi zj move to next / prev fold

" tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" other
set lazyredraw
set updatetime=300
set timeoutlen=500
set conceallevel=2
set shell=/usr/bin/bash
let $SHELL="/usr/bin/bash"
let g:BASH_Ctrl_j='off'            " avoid 'C-j' being overridden to newline
let g:BASH_Ctrl_l='off'            " avoid 'C-l' being overridden to newline
highlight clear SignColumn         " SignColumn should match background
set shortmess=atOI                 " No help Uganda information, and overwrite read messages to avoid PRESS ENTER prompts
set listchars=tab:→\ ,eol:↵,trail:·,extends:↷,precedes:↶
set fillchars=vert:│,stl:\ ,stlnc:\

" -----------------------------------------------------------------------------
" KEYBINDS
" -----------------------------------------------------------------------------
let mapleader="\<SPACE>"
let maplocalleader=","
nnoremap q: <nop>
nnoremap Q <nop>
vnoremap v <Esc>
nnoremap . :
nnoremap , .
nmap <esc><esc> :noh<cr>
nmap <M-d> :BD<cr>
nnoremap <leader>R :so ~/.config/nvim/init.vim<cr>
nnoremap <leader>E :tabe ~/.config/nvim/init.vim<cr>
" nerdcommenter: '<leader>c ', '<leader>cl' aligned and '<leader>cu>' remove
" vim-surround: visual 'SA' to wrap in A. Surround 'csAB' to change from A to B, 'dsA' to remove A. Word 'ysiwA' to wrap with A

" *****************************
" CLIPBOARD (incl bugfix paste unnamedplus)
set clipboard+=unnamedplus
nmap p <Plug>(miniyank-autoput)
nmap P <Plug>(miniyank-autoPut)

" *****************************
" TERMINAL
nmap <Leader>T :terminal<cr>
tmap <C-x> <C-\><C-n>
tmap <F2> <C-\><C-n>

" *****************************
" SEARCH
set wildignorecase
set wildignore+=*swp,*.class,*.pyc,*.png,*.jpg,*.gif,*.zip
set wildignore+=*/tmp/*,*.o,*.obj,*.so     " Unix
set wildignore+=*\\tmp\\*,*.exe            " Windows
function! EnterSubdir()
    call feedkeys("\<Down>", 't')
    return ''
endfunction
cnoremap <C-h> <up>
cnoremap <C-j> <right>
cnoremap <C-k> <left>
cnoremap <expr> <C-l> EnterSubdir()
map *   <Plug>(asterisk-z*)
map g*  <Plug>(asterisk-gz*)
map g#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)
let g:asterisk#keeppos=1

" *****************************
" CURSOR
" vertical movement remapping ala US
map å (
map ¨ )
map Å {
map ^ }
map + [
map \ ]
" Treat long lines as break lines (useful when moving around in them)
nmap j gj
nmap k gk
vmap j gj
vmap k gk
" indenting
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" Move start and end of line
noremap H _
noremap L $
" insert mode movement
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-b> <BS>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Delete>

" *****************************
" WINDOWS / BUFFERS
let g:tmux_navigator_no_mappings=1
nmap <silent> <M-h> :TmuxNavigateLeft<cr>
nmap <silent> <M-j> :TmuxNavigateDown<cr>
nmap <silent> <M-k> :TmuxNavigateUp<cr>
nmap <silent> <M-l> :TmuxNavigateRight<cr>
" make splits and tabs
nnoremap <M-BAR> :vsplit<cr>
nnoremap <M-§> :vnew<cr>
nnoremap <M--> :split<cr>
nnoremap <M-_> :new<cr>
nnoremap <M-p> <C-w>T
nnoremap <M-P> :tabnew<cr>
" buffergator & nerdtree
nmap <M-N> :bprev<cr>
nmap <M-n> :bnext<cr>
nmap <M-T> :tabprev<cr>
nmap <M-t> :tabnext<cr>
" resize windows with hjkl
nnoremap <C-h> <C-w><
nnoremap <C-j> <C-w>-
nnoremap <C-k> <C-w>+
nnoremap <C-l> <C-w>>
" buffergator & nerdtree
map <C-f> :NERDTreeToggle<cr>
map <C-b> :BuffergatorToggle<cr>
map <C-t> :BuffergatorTabsToggle<cr>
let g:buffergator_mru_cycle_loop=0
let g:buffergator_suppress_keymaps=1
let g:buffergator_autoupdate=1
let g:buffergator_sort_regime='bufnum'
let g:buffergator_display_regime='basename'
let g:buffergator_autodismiss_on_select=0
let g:buffergator_show_full_directory_path=0
let g:buffergator_tab_statusline=0
let g:buffergator_window_statusline=0
" other C-w commands to remember
" <C-w>= equalize sizes
" <C-w>T move buffer to new tab
" move windows with <leader>+HJKL
" <C-w>H
" <C-w>J
" <C-w>K
" <C-w>L

" *****************************
" MARKDOWN
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

" *****************************
" GIT
" vim-fugitive
" g? for fugitive help. :Gdiff, :Gblame, :Gstats '=' expand, '-' add/reset changes, :Gcommit % to commit current file with messag
nmap <leader>gg :vertical Gstatus<cr>:vertical resize 60<cr>
" gv.vim
map <leader>gv :GV<cr>
map <leader>gf :GV!<cr>
map <leader>gl :GV?<cr>
" coc git
nmap <leader>gn    <Plug>(coc-git-nextchunk)
nmap <leader>gp    <Plug>(coc-git-prevchunk)
nmap <leader>g<cr> <Plug>(coc-git-chunkinfo)
nmap <leader>gs    :CocCommand git.chunkStage<cr>
vmap <leader>gs    :CocCommand git.chunkStage<cr>
nmap <leader>gX    :CocCommand git.chunkUndo<cr>
vmap <leader>gX    :CocCommand git.chunkUndo<cr>
" coc fzf
nmap <silent> <M-g> :<C-u>CocCommand fzf-preview.GitStatus<cr>
nmap <silent> <M-G> :<C-u>CocCommand fzf-preview.GitActions<cr>

" *****************************
" COC FZF
nmap          <M-w> :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
xmap          <M-w> "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<cr>"
nmap          <M-W> :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
nmap <silent> <M-e> :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<cr>
nmap <silent> <M-E> :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<cr>"<cr>
nmap <silent> <M-r> :<C-u>CocCommand fzf-preview.MruFiles<cr>
nmap <silent> <M-R> :<C-u>CocCommand fzf-preview.ProjectMruFiles<cr>
nmap <silent> <M-f> :<C-u>CocCommand fzf-preview.DirectoryFiles<cr>
nmap <silent> <M-F> :<C-u>CocCommand fzf-preview.ProjectFiles<cr>
nmap <silent> <M-b> :<C-u>CocCommand fzf-preview.Buffers<cr>
nmap <silent> <M-B> :<C-u>CocCommand fzf-preview.AllBuffers<cr>
let g:fzf_preview_command='bat --color=always --plain {-1}' " Installed bat
let g:fzf_preview_grep_cmd='rg --smart-case --line-number --no-heading --color=never'

" *****************************
" COC OTHER
" coc menus
let g:coc_node_path='/usr/bin/node'
function! s:check_back_space() abort
  let col=col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
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
" show coc documentation in preview window
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
nmap <silent> K :call <SID>show_documentation()<cr>

" *****************************
" autocmd
augroup myAu   " A unique name for the group.  DO NOT use the same name twice!
    autocmd!
    autocmd FileType python set        tabstop=4 softtabstop=4 shiftwidth=4
    autocmd FileType markdown,yaml set tabstop=2 softtabstop=2 shiftwidth=2
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o  " Disables automatic commenting on newline
    autocmd FileType * RainbowParentheses()
    autocmd BufEnter * if &filetype == "" | setlocal ft=markdown | endif             " default new file is markdown
    autocmd BufWritePre * %s/\s\+$//e                                                " Automatically deletes all trailing whitespace on save.
    autocmd BufReadPost quickfix nmap <buffer> <cr> <cr>                             " quickfix <cr>
    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif                     " bugfix
augroup end
