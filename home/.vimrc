let s:uname = system("echo -n \"$(uname)\"")
let s:is_mac = !v:shell_error && s:uname == "Darwin"
let s:is_linux = !v:shell_error && s:uname == "Linux"

" dependency for https://github.com/junegunn/vim-plug
call plug#begin('~/.vim/plugged')

" Plug 'scrooloose/syntastic'
" Plug 'mtscout6/syntastic-local-eslint.vim'
Plug 'w0rp/ale'
Plug 'fatih/vim-go'
" Plug 'terryma/vim-multiple-cursors'
Plug 'flazz/vim-colorschemes'
Plug 'nvie/vim-flake8'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Valloric/YouCompleteMe', {'do': 'python2 ./install.py --clang-completer --gocode-completer --tern-completer'}
" Plug 'rust-lang/rust.vim'
Plug 'airblade/vim-gitgutter'
" Plug 'phildawes/racer'
Plug 'elzr/vim-json'
" Plug 'rdnetto/YCM-Generator', {'branch': 'stable'}
" Plug 'dyng/ctrlsf.vim'
Plug 'kien/ctrlp.vim'
"Plug 'tfnico/vim-gradle'
Plug 'tpope/vim-commentary'
"Plug 'vim-scripts/Rename'
Plug 'tpope/vim-sensible'
Plug 'hdima/python-syntax'
Plug 'digitaltoad/vim-jade'
Plug 'tpope/vim-sleuth'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
"Plug 'maksimr/vim-jsbeautify'
"Plug 'tpope/vim-surround'
Plug 'jalvesaq/Nvim-R'
Plug 'hynek/vim-python-pep8-indent'
"Plug 'SirVer/ultisnips'
"Plug 'jeremija/vim-snippets', {'branch': 'private'}
"Plug 'vim-scripts/SQLUtilities'
"Plug 'vim-scripts/Align'
Plug 'qpkorr/vim-bufkill'

call plug#end()

syntax on
autocmd BufNewFile,BufRead *.md set syntax=markdown
filetype plugin indent on
set tabstop=4 shiftwidth=4 expandtab
autocmd FileType *.go set noexpandtab
autocmd BufNewFile,BufRead *.jade set shiftwidth=2 tabstop=2
autocmd BufNewFile,BufRead *.pug set shiftwidth=2 tabstop=2 syntax=jade
autocmd BufNewFile,BufRead *.jsx set tabstop=2 shiftwidth=2
autocmd BufNewFile,BufRead *.js set shiftwidth=2 ts=2
autocmd BufNewFile,BufRead *.R set shiftwidth=2 ts=2
let g:jsx_ext_required = 0
if s:is_linux
  set clipboard=unnamedplus
elseif s:is_mac
  if has('nvim')
    set clipboard+=unnamedplus
  else
    set clipboard=unnamed
  endif
endif
set colorcolumn=80
set wildmenu
silent !mkdir -p ~/.vim/.backup ~/.vim/.undo ~/.vim/.swp
set backupdir=~/.vim/.backup//
set undodir=~/.vim/.undo//
set directory=~/.vim/.swp//

" sane menu config
set completeopt=longest,menuone

let mapleader = ","
" map <Leader>l :call SyntasticCheck()<CR>
map <Leader>j :ALEPreviousWrap<CR>
map <Leader>k :ALENextWrap<CR>
map <Leader>c :Commentary<CR>
map <Leader>. :bnext<CR>
map <Leader>m :bprev<CR>
map <Leader>r :vertical resize 82<CR>

autocmd FileType javascript vnoremap <buffer> <Leader>f :call RangeJsBeautify()<CR>
autocmd FileType json vnoremap <buffer> <Leader>f :call RangeJsonBeautify()<CR>
autocmd FileType jsx vnoremap <buffer> <Leader>f :call RangeJsxBeautify()<CR>
autocmd FileType html vnoremap <buffer> <Leader>f :call RangeHtmlBeautify()<CR>
autocmd FileType css vnoremap <buffer> <Leader>f :call RangeCSSBeautify()<CR>

autocmd FileType javascript noremap <buffer> <Leader>F :call JsBeautify()<CR>
autocmd FileType json noremap <buffer> <Leader>F :call JsonBeautify()<CR>
autocmd FileType jsx noremap <buffer> <Leader>F :call JsxBeautify()<CR>
autocmd FileType html noremap <buffer> <Leader>F :call HtmlBeautify()<CR>
autocmd FileType css noremap <buffer> <Leader>F :call CSSBeautify()<CR>

map <C-PageUp> :bprev<CR>
map <C-PageDown> :bnext<CR>
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l

set hlsearch
set lazyredraw

set backspace=2

let g:ycm_extra_conf_globlist = ['~/src/private/*', '~/src/linux/*', '~/src/mnlth/*', '!~/*']
let g:ycm_auto_trigger = 0

" status function for ale
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

set laststatus=2
set statusline=
set statusline +=%1*\ %n\ %*       "buffer number
set statusline +=\ %<%F            "full path
set statusline +=%m                "modified flag
set statusline +=%1*%=%{&ff}%*     "file format
set statusline +=%y                "file type
set statusline +=%1*%5l%*          "current line
set statusline +=%2*/%L%*          "total lines
set statusline +=%1*%4v\ %*        "virtual column number
set statusline +=%2*0x%04B\ %*     "character under cursor
" set statusline+=%#warningmsg#                 "syntastic
" set statusline+=%{SyntasticStatuslineFlag()}  "syntastic
set statusline +=%{LinterStatus()}
set statusline+=%*                            "switch to default color

let g:syntastic_always_populate_loc_list = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_go_checkers = ['golint']
let g:syntastic_java_javac_config_file_enabled = 1
let g:syntastic_html_checkers=['']
let g:syntastic_mode_map = { "mode": "passive" }
let g:vim_json_syntax_conceal = 0
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']


let python_highlight_all = 1

" racer
set hidden
let g:racer_cmd = $HOME."/.vim/plugged/racer/target/release/racer"
let $RUST_SRC_PATH=$HOME."/Downloads/rustc-1.0.0/src/"

set t_Co=256
colorscheme last256
hi MatchParen cterm=bold ctermbg=none ctermfg=white
hi StatusLine  ctermfg=172 ctermbg=none
" hi User1 ctermbg=none ctermfg=172
hi StatusLineNC  ctermfg=none ctermbg=none cterm=none
hi VertSplit ctermbg=none cterm=none
hi Normal ctermfg=248

set timeout
set timeoutlen=750
set ttimeoutlen=250

"NeoVim handles ESC keys as alt+key, set this to solve the problem
if has('nvim')
  set ttimeout
  set ttimeoutlen=0

  set guicursor=
endif

let R_tmux_split = 1
let R_assign = 0

" Keep chained functions at the same indent
let g:javascript_opfirst = 1
let g:javascript_plugin_jsdoc = 1

let g:UltiSnipsExpandTrigger = "<c-a>"
let g:UltiSnipsListSnippets = "<c-l>"
let g:UltiSnipsJumpForwardTrigger = "<c-j>"
let g:UltiSnipsJumpBackwardTrigger = "<c-k>"
let g:UltiSnipsSnippetsDir="~/.vim/plugged/vim-snippets/UltiSnips"

let g:gitgutter_sign_column_always = 1
let g:ale_sign_column_always = 1
