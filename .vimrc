" dependency for https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf'
Plug 'scrooloose/syntastic'
Plug 'fatih/vim-go'
Plug 'terryma/vim-multiple-cursors'
Plug 'flazz/vim-colorschemes'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-sensible'
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

call plug#end()

syntax on
autocmd BufNewFile,BufRead *.md set syntax=markdown
filetype plugin indent on
set tabstop=4 shiftwidth=4 expandtab
set clipboard=unnamedplus
set colorcolumn=80
set wildmenu

" sane menu config
set completeopt=longest,menuone

function s:getFzfPath()
    " use git repository's root instead of current path
    let location = system('git rev-parse --show-cdup')
    " remove \0 character from the end of the string
    let location = substitute(location, '\%x00', '', 'g')
    if v:shell_error
        " if not a git repository, use git current path
        return "ag -l -g '' ."
    endif
    return 'ag -l -g "" ' . location
endfunction

function CustomFZF()
    let source = s:getFzfPath()
    call fzf#run({"source": source, "sink": "e", "down": "20"})
endfunction

map <C-P> :call CustomFZF()<CR>
map LL :call SyntasticCheck()<CR>
map <C-F> :CtrlSF 

" highlight current line
"set cursorline cursorcolumn
set cursorline
hi CursorLine cterm=NONE ctermbg=black
hi CursorColumn cterm=NONE ctermbg=black

set lazyredraw

let g:indentLine_enabled = 0
let g:indentLine_char = '|'
let g:indentLine_first_char = '|'
"let g:indentLine_leadingSpaceEnabled = 1
"let g:indentLine_leadingSpaceChar = '·'
"let g:indentLine_showFirstIndentLevel = 1
"let g:indentLine_color_term = 239
set hlsearch

let g:indentLine_color_term = 'black'
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
" end syntastic config
let g:vim_json_syntax_conceal = 0

" airline config
" let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
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
endif
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'bubblegum'
"let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#buffer_min_count = 2

" racer
set hidden
let g:racer_cmd = $HOME."/.vim/plugged/racer/target/release/racer"
let $RUST_SRC_PATH=$HOME."/Downloads/rustc-1.0.0/src/"

colorscheme last256
hi MatchParen cterm=bold ctermbg=none ctermfg=white
