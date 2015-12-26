let s:uname = system("echo -n \"$(uname)\"")
let s:is_mac = !v:shell_error && s:uname == "Darwin"
let s:is_linux = !v:shell_error && s:uname == "Linux"

" dependency for https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/syntastic'
Plug 'fatih/vim-go'
Plug 'terryma/vim-multiple-cursors'
Plug 'flazz/vim-colorschemes'
Plug 'nvie/vim-flake8'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Valloric/YouCompleteMe'
Plug 'marijnh/tern_for_vim'
Plug 'rust-lang/rust.vim'
Plug 'airblade/vim-gitgutter'
Plug 'phildawes/racer'
Plug 'elzr/vim-json'
Plug 'rdnetto/YCM-Generator', {'branch': 'stable'}
Plug 'dyng/ctrlsf.vim'
Plug 'bling/vim-airline'
Plug 'kien/ctrlp.vim'
Plug 'tfnico/vim-gradle'
Plug 'tpope/vim-commentary'
Plug 'vim-scripts/Rename'
Plug 'haya14busa/incsearch.vim'
Plug 'hdima/python-syntax'
Plug 'digitaltoad/vim-jade'
Plug 'tpope/vim-sleuth'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

call plug#end()

syntax on
autocmd BufNewFile,BufRead *.md set syntax=markdown
filetype plugin indent on
set tabstop=4 shiftwidth=4 expandtab
autocmd FileType *.go set noexpandtab
autocmd BufNewFile,BufRead *.jade set shiftwidth=2 tabstop=2
autocmd BufNewFile,BufRead *.jsx set tabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead *.js set shiftwidth=2 ts=2
let g:jsx_ext_required = 0
if s:is_linux
  set clipboard=unnamedplus
elseif s:is_mac
  set clipboard=unnamed
endif
set colorcolumn=80
set wildmenu
silent !mkdir -p ~/.vim/.backup ~/.vim/.undo ~/.vim/.swp
set backupdir=~/.vim/.backup//
set undodir=~/.vim/.undo//
set directory=~/.vim/.swp//

" sane menu config
set completeopt=longest,menuone

map LL :call SyntasticCheck()<CR>
map <C-F> :CtrlSF<Space>
map LC :Commentary<CR>

map <C-PageUp> :bprev<CR>
map <C-PageDown> :bnext<CR>

" highlight current line
"set cursorline cursorcolumn
set cursorline
hi CursorLine cterm=NONE ctermbg=black
hi CursorColumn cterm=NONE ctermbg=black

set hlsearch
set lazyredraw

set backspace=2

let g:ycm_extra_conf_globlist = ['~/src/private/*', '~/src/linux/*', '~/src/mnlth/*', '!~/*']

" configure syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_html_checkers=['']
" end syntastic config
let g:vim_json_syntax_conceal = 0
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']

" airline config
" let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  if s:is_linux
    let g:airline_symbols = {}
    let g:airline_left_sep = '⮀'
    let g:airline_left_alt_sep = '⮁'
    let g:airline_right_sep = '⮂'
    let g:airline_right_alt_sep = '⮃'
    let g:airline_symbols.branch = '⭠'
    let g:airline_symbols.readonly = '⭤'
    let g:airline_symbols.linenr = '⭡'

    let g:airline#extensions#tabline#left_sep = '⮀'
    let g:airline#extensions#tabline#left_alt_sep = '⮁'
  elseif s:is_mac
    let g:airline_symbols = {}
    let g:airline_left_sep = ' '
    let g:airline_left_alt_sep = ' '
    let g:airline_right_sep = ' '
    let g:airline_right_alt_sep = ' '
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.readonly = '🔒'
    let g:airline_symbols.linenr = '␊'

    let g:airline#extensions#tabline#left_sep = ' '
    let g:airline#extensions#tabline#left_alt_sep = ' '
  endif
endif
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'bubblegum'
let g:airline#extensions#tabline#buffer_min_count = 2

let python_highlight_all = 1

map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" racer
set hidden
let g:racer_cmd = $HOME."/.vim/plugged/racer/target/release/racer"
let $RUST_SRC_PATH=$HOME."/Downloads/rustc-1.0.0/src/"

set t_Co=256
colorscheme last256
hi MatchParen cterm=bold ctermbg=none ctermfg=white

set timeout
set timeoutlen=750
set ttimeoutlen=250

"NeoVim handles ESC keys as alt+key, set this to solve the problem
if has('nvim')
  set ttimeout
  set ttimeoutlen=0
endif

