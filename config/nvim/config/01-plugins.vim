let s:uname = system("echo -n \"$(uname)\"")
let g:is_mac = !v:shell_error && s:uname == "Darwin"
let g:is_linux = !v:shell_error && s:uname == "Linux"

call plug#begin('~/.vim/plugged')

Plug 'jeremija/ale', {'branch': 'jeremija/bingo'}
Plug 'flazz/vim-colorschemes'
Plug 'nvie/vim-flake8'
Plug 'ntpeters/vim-better-whitespace'
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
Plug 'ianks/vim-tsx'
Plug 'SirVer/ultisnips'
Plug 'jeremija/vim-snippets', {'branch': 'private'}
Plug 'editorconfig/editorconfig-vim'
Plug 'udalov/kotlin-vim'
Plug 'junegunn/vader.vim'

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
let g:ale_linters_ignore = {
\   'typescript': ['tslint'],
\   'typescript.tsx': ['tslint'],
\}
let g:ale_fixers = {
\  'javascript': ['eslint'],
\  'typescript': ['tslint'],
\  'go': ['gofmt', 'goimports'],
\}
let g:ale_completion_enabled = 1
let g:ale_kotlin_languageserver_executable = 'kotlin-language-server'
" let g:ale_go_bingo_options = '--mode stdio --logfile /tmp/lspserver.log --trace'
let g:ale_linters = {
\  'go': ['gofmt', 'golint', 'govet', 'bingo']
\}

let g:NERDTreeIgnore = ['__pycache__', '\.pyc$']

let g:UltiSnipsSnippetsDir = "~/.vim/plugged/vim-snippets/UltiSnips"
let g:UltiSnipsExpandTrigger = "<c-s>"
let g:UltiSnipsListSnippets = "<c-l>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<S-tab>"
