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
      \ 'coc-python',
      \ 'coc-git',
      \ 'coc-tsserver',
      \ 'coc-diagnostic',
      \ 'coc-yaml',
      \ 'coc-explorer'
      \ ]

call plug#begin('~/.config/nvim/plugged')
" tools
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'           " language syntax
Plug 'tpope/vim-abolish'              " better search replace
" git
Plug 'tpope/vim-fugitive'
" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'plasticboy/vim-markdown'        " markdown helper.
" helpers
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'           " commenting tool
Plug 'tpope/vim-surround'             " parentheses helper
Plug 'mbbill/undotree'                " Persistent undo
Plug 'farmergreg/vim-lastplace'       " When reopen a buffer, puts the cursor where it was last time
Plug 'haya14busa/vim-asterisk'        " better asterisk motions
Plug 'svermeulen/vim-cutlass'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-sensible'
" tmux
Plug 'roxma/vim-tmux-clipboard'
Plug 'christoomey/vim-tmux-navigator' " integrate movement in tmux and vim
" aesthetics
Plug 'chriskempson/base16-vim'        " base16 themes
Plug 'chrisbra/Colorizer'             " show color codes
Plug 'junegunn/rainbow_parentheses.vim' " colorize parentheses
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
" colo seoul256

" statusline
set cmdheight=2
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
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

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
set scrolljump=1   " Line to scroll when cursor leaves screen

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

" indentation
set smartindent

" folds
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
set listchars=tab:→\ ,eol:↵,trail:·,extends:↷,precedes:↶,nbsp:+
set fillchars=vert:│,stl:\ ,stlnc:\
set clipboard+=unnamedplus
set list


" -----------------------------------------------------------------------------
" KEYBINDS
" -----------------------------------------------------------------------------
let mapleader="\<SPACE>"
nnoremap q: <nop>
nnoremap Q <nop>
vnoremap v <Esc>
set pastetoggle=<F2>
nmap <esc><esc> :noh<cr>
nmap <leader>R :so ~/.config/nvim/init.vim<cr>
nmap <leader>E :tabe ~/OneDrive/dotfiles/nvim/init.vim<cr>
nmap <leader>w :cd %:p:h<cr>
" vim-surround: visual 'SA' to wrap in A. Surround 'csAB' to change from A to B, 'dsA' to remove A. Word 'ysiwA' to wrap with A

" *****************************
" REMAPPING
set langmap=å(,¨),Å{,^},Ø\\;,ø:,æ^

" *****************************
" REMAPPING
nnoremap m d
xnoremap m d

nnoremap mm dd
nnoremap M D

" *****************************
" EDITING
nmap cr <Plug>(coc-rename)
nmap cR <Plug>(coc-refactor)
xmap cf <Plug>(coc-format-selected)
nmap cf <Plug>(coc-format-selected)

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
" stay visual when indenting
vnoremap >> >gv
vnoremap << <gv
" move between errors
nmap <M-n> <Plug>(coc-diagnostic-prev)
nmap <M-m> <Plug>(coc-diagnostic-next)
" GoTo code navigation
nmap <M-,> <Plug>(coc-git-prevchunk)
nmap <M-.> <Plug>(coc-git-nextchunk)
nmap gd <Plug>(coc-definition)
nmap gy <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)
nmap gr <Plug>(coc-references)

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
nnoremap <M-t> :tabe %<cr>
nnoremap <M-T> :tabnew<cr>
" buffers and tabs
nmap <M-H> :bprev<cr>
nmap <M-L> :bnext<cr>
nmap <M-J> :tabprev<cr>
nmap <M-K> :tabnext<cr>
" resize windows with hjkl
nnoremap <C-h> <C-w><
nnoremap <C-j> <C-w>-
nnoremap <C-k> <C-w>+
nnoremap <C-l> <C-w>>
" quickfix window
nmap <C-n> :cp<cr>
nmap <C-m> :cn<cr>
" remove buffer
nmap <M-d> :bp<bar>bd#<cr>
nmap <M-D> :bp<bar>bd!#<cr>
" close window
nmap <M-q> :q<cr>

" *****************************
" GIT
nmap <M-i> <Plug>(coc-git-chunkinfo)
nmap <M-S> :CocCommand git.chunkStage<cr>
vmap <M-S> :CocCommand git.chunkStage<cr>
nmap <M-X> :CocCommand git.chunkUndo<cr>
vmap <M-X> :CocCommand git.chunkUndo<cr>

" *****************************
" EXPLORERS
" coc-explorer
map <C-f> :CocCommand explorer<cr>
" vim-fugitive
" g? for fugitive help. :Gdiff, :Gblame, :Gstats '=' expand, '-' add/reset changes, :Gcommit % to commit current file with messag
map <C-g> :vertical Git<cr>:vertical resize 60<cr>

" *****************************
" POPUPS
nmap <silent> <M-x> :CocFzfList<cr>
nmap <silent> <M-v> :CocFzfList symbols --kind Variable<cr>
nmap <silent> <M-u> :CocFzfList symbols --kind Function<cr>
nmap <silent> <M-r> :History<cr>
nmap <silent> <M-e> :History/<cr>
nmap <silent> <M-f> :GFiles<cr>
nmap <silent> <M-F> :Files<cr>
nmap <silent> <M-b> :Buffers<cr>
map  <silent> <M-z> :Colors<cr>
map  <silent> <M-y> :Filetypes<cr>
let g:fzf_preview_command='bat --color=always --plain {-1}' " Installed bat
let g:fzf_preview_grep_cmd='rg --smart-case --line-number --no-heading --color=never'
" fzf git
nmap <silent> <M-g> :GFiles?<cr>
nmap <silent> <M-c> :Commits<cr>
nmap <silent> <M-C> :BCommits<cr>
" Grep
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
"command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)
nmap          <M-w> :RG<cr>

" *****************************
" COC CONFIGS
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

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" *****************************
" MARKDOWN
" vim-markdown
let g:vim_markdown_new_list_item_indent=0
let g:vim_markdown_auto_insert_bullets=1
let g:vim_markdown_conceal=1
let g:vim_markdown_conceal_code_blocks=1
let g:vim_markdown_math=1
let g:vim_markdown_folding_disabled=0
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
" autocmd
augroup myAu   " A unique name for the group.  DO NOT use the same name twice!
    autocmd!
    autocmd FileType python set        tabstop=4 softtabstop=4 shiftwidth=4
    autocmd FileType markdown,yaml set tabstop=2 softtabstop=2 shiftwidth=2
    autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o   " Disables automatic commenting on newline
    autocmd FileType * RainbowParentheses()
    autocmd BufEnter * if &filetype == "" | setlocal ft=markdown | endif             " default new file is markdown
    autocmd BufWritePre * %s/\s\+$//e                                                " Automatically deletes all trailing whitespace on save.
    autocmd BufReadPost quickfix nmap <buffer> <cr> <cr>                             " quickfix <cr>
    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif                     " bugfix
    autocmd BufNewFile,BufRead *.cfg set syntax=cfg
    autocmd FileType python map <F9> :CocCommand python.execInTerminal<CR>
    autocmd FileType python imap <F9> <esc>:CocCommand python.execInTerminal<CR>
augroup end

" CTRL-A CTRL-Q to select all and build quickfix list

function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction

let g:fzf_action = {
\ 'ctrl-q': function('s:build_quickfix_list'),
\ 'ctrl-t': 'tab split',
\ 'ctrl-s': 'split',
\ 'ctrl-v': 'vsplit' }

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
