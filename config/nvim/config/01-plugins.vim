let s:uname = system("echo -n \"$(uname)\"")
let g:is_mac = !v:shell_error && s:uname is# 'Darwin'
let g:is_linux = !v:shell_error && s:uname is# 'Linux'

let g:vim_json_syntax_conceal = 0

" Keep chained functions at the same indent
let g:javascript_opfirst = 1
let g:javascript_plugin_jsdoc = 1
let g:typescript_opfirst='\%([<>=,?^%|*/&]\|\([-:+]\)\1\@!\|!=\|in\%(stanceof\)\=\>\)'

let g:python_highlight_all = 1
let g:vim_indent_cont = 0

let g:R_tmux_split = 1
let g:R_assign = 0

set signcolumn=yes

let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_echo_cursor = 0
let g:ale_hover_cursor = 0
let g:ale_pattern_options = {
\  'node_modules': {'ale_enabled': 0},
\}
let g:ale_linters_ignore = {
\   'typescript': [],
\   'typescript.tsx': [],
\}
let g:ale_fixers = {
\  'javascript': ['eslint'],
\  'typescript': ['eslint'],
\  'go': ['gofmt', 'goimports'],
\}
let g:ale_fix_on_save = 1
let g:ale_kotlin_languageserver_executable = 'kotlin-language-server'
let g:ale_kotlin_kotlinc_options = '-d build/ale-kotlinc'
let g:ale_go_golangci_lint_package=1
let g:ale_linters = {
\  'go': ['gopls', 'golangci-lint'],
\  'rust': ['cargo', 'rls'],
\}
let g:ale_completion_autoimport = 1

let g:NERDTreeIgnore = ['__pycache__', '\.pyc$']

let g:UltiSnipsSnippetsDir = '~/.config/nvim/pack/bundle/start/vim-snippets/UltiSnips'
let g:UltiSnipsExpandTrigger = '<c-s>'
let g:UltiSnipsListSnippets = '<c-l>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-tab>'

function! OpenTest() abort
  let l:filename = expand('%:p:r')
  let l:ext = expand('%:e')
  let l:test_part = get(b:, 'opentest_test_part', '.test')
  let l:pattern = '\V' . l:test_part . '\$'

  if l:filename =~# l:pattern
    let l:file_to_open = substitute(l:filename, l:pattern, '', '') . '.' . l:ext
  else
    let l:file_to_open = l:filename . l:test_part . '.' . l:ext
  endif

  execute 'edit ' . l:file_to_open
endfunction
command! OpenTest :call OpenTest()

function! ToggleLinter(name) abort
  for l:original_filetype in split(&filetype, '\.')
    if has_key(g:ale_linters, l:original_filetype)
      let l:linters = g:ale_linters[l:original_filetype]
      let l:index = index(l:linters, a:name)
      if l:index > 0
        call remove(l:linters, l:index)
      else
        call add(l:linters, a:name)
      endif
      echo l:original_filetype . ': ' . string(l:linters)
    endif
  endfor
  call ale#toggle#Reset()
endfunction
command! -nargs=1 ToggleLinter :call ToggleLinter(<q-args>)
