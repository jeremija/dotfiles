syntax on
autocmd BufNewFile,BufRead *.md set syntax=markdown
filetype plugin indent on
set tabstop=2 shiftwidth=2 expandtab
autocmd FileType *.go set noexpandtab tabstop=4 shiftwidth=4
let g:jgx_ext_required = 0
if g:is_linux
  set clipboard=unnamedplus
elseif g:is_mac
  if has('nvim')
    set clipboard+=unnamedplus
  else
    set clipboard=unnamed
  endif
endif
set colorcolumn=80
set wildmenu

" create temporary files in separate directories
let s:backupdir = g:nvim_dir . '/tmp/backup/'
let s:undodir = g:nvim_dir . '/tmp/undo/'
let s:directory = g:nvim_dir . '/tmp/swp/'
silent execute '!mkdir -p ' . join([s:backupdir, s:undodir, s:directory], ' ')
let &backupdir = s:backupdir . '/'
let &undodir = s:undodir . '/'
let &directory = s:directory . '/'

" sane menu config
set completeopt=longest,menuone
set hlsearch
set lazyredraw
set backspace=2

" racer
set hidden

" make gitgutter update faster (default is 4000)
set updatetime=100

set timeout
set timeoutlen=750
set ttimeoutlen=250

"NeoVim handles ESC keys as alt+key, set this to solve the problem
if has('nvim')
  set ttimeout
  set ttimeoutlen=0

  set guicursor=
endif

" Enable mouse
set mouse=a

" Disable folding
set nofoldenable
