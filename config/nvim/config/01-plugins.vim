let s:uname = system("echo -n \"$(uname)\"")
let g:is_mac = !v:shell_error && s:uname == "Darwin"
let g:is_linux = !v:shell_error && s:uname == "Linux"
let g:ycm_install_command = 'python3 ./install.py --clang-completer --gocode-completer --tern-completer --racer-completer' . (g:is_linux ? ' --system-libclang' : '')

call plug#begin('~/.vim/plugged')

Plug 'w0rp/ale'
Plug 'fatih/vim-go'
Plug 'flazz/vim-colorschemes'
Plug 'nvie/vim-flake8'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Valloric/YouCompleteMe', {'do': g:ycm_install_command}
Plug 'airblade/vim-gitgutter'
Plug 'elzr/vim-json'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sensible'
Plug 'hdima/python-syntax'
Plug 'digitaltoad/vim-pug'
Plug 'tpope/vim-sleuth'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'jalvesaq/Nvim-R'
Plug 'hynek/vim-python-pep8-indent'
Plug 'qpkorr/vim-bufkill'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/fzf'
Plug 'rust-lang/rust.vim'
Plug 'leafgarland/typescript-vim'
Plug 'galooshi/vim-import-js'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jparise/vim-graphql'

call plug#end()

let g:ycm_extra_conf_globlist = ['!~/*']
let g:ycm_auto_trigger = 0

let g:vim_json_syntax_conceal = 0

" Keep chained functions at the same indent
let g:javascript_opfirst = 1
let g:javascript_plugin_jsdoc = 1
let g:typescript_opfirst='\%([<>=,?^%|*/&]\|\([-:+]\)\1\@!\|!=\|in\%(stanceof\)\=\>\)'

let python_highlight_all = 1

let R_tmux_split = 1
let R_assign = 0

set signcolumn=yes

let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_pattern_options = {
\  'node_modules': {'ale_enabled': 0},
\}
let g:ale_fixers = {
\  'javascript': ['eslint'],
\}
