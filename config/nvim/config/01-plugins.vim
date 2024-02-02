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
let g:better_whitespace_filetypes_blacklist = ['diff', 'gitcommit', 'unite', 'qf', 'help', 'markdown', 'fzf']

let g:R_tmux_split = 1
let g:R_assign = 0

set signcolumn=yes

" disable ALE LSP in favor of native support in Neovim.
let g:ale_disable_lsp = 1
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
\  'rust': [],
\}
let g:ale_fix_on_save = 1
let g:ale_kotlin_languageserver_executable = 'kotlin-language-server'
let g:ale_kotlin_kotlinc_options = '-d build/ale-kotlinc'
let g:ale_linters = {
\  'go': ['gopls', 'golangci-lint'],
\  'rust': ['analyzer'],
\}
let g:ale_go_golangci_lint_options = ''
let g:ale_go_golangci_lint_package=1
let g:ale_completion_autoimport = 1

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

let g:fzf_layout = {
\ 'window': {
\   'width':0.95,
\   'height': 0.8,
\  },
\}

" let g:nvim_tree_git_icon_padding = ''
let g:nvim_tree_symlink_arrow = ' -> '
let g:nvim_tree_create_in_closed_folder = 1
let g:nvim_tree_show_icons = {
\ 'git': 0,
\ 'folders': 0,
\ 'files': 0,
\ 'folder_arrows': 0,
\ }

let g:nvim_tree_icons = {
\ 'default': '',
\ 'symlink': '',
\ 'git': {
\   'unstaged': "✗",
\   'staged': "✓",
\   'unmerged': "",
\   'renamed': "➜",
\   'untracked': "★",
\   'deleted': "",
\   'ignored': "◌"
\   },
\ 'folder': {
\   'arrow_open': "-",
\   'arrow_closed': "+",
\   'default': "",
\   'open': "",
\   'empty': "",
\   'empty_open': "",
\   'symlink': "",
\   'symlink_open': "",
\   }
\ }

lua << EOF
require'nvim-tree'.setup {
  actions = {
    open_file = {
      window_picker = {
        enable = false,
      }
    },
  },
  disable_netrw       = true,
  hijack_netrw        = true,
  open_on_tab         = false,
  hijack_cursor       = false,
  update_cwd          = true,
  hijack_directories = {
    enable = true,
    auto_open = true,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    }
  },
  update_focused_file = {
    enable      = false,
    update_cwd  = false,
    ignore_list = {}
  },
  system_open = {
    cmd  = nil,
    args = {}
  },
  filters = {
    dotfiles = false,
    custom = {}
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 500,
  },
  view = {
    width = 30,
    side = 'left',
    number = false,
    relativenumber = false,
    signcolumn = "yes"
  },
  trash = {
    cmd = "trash",
    require_confirm = true
  },
  renderer = {
    icons = {
      git_placement = "before",
    }
  }
}
EOF

let g:git_urls = {}

function! OpenGit(range, line1, line2) abort
  let l:file = expand('%:p')
  let l:root = l:file
  let l:check = fnamemodify(l:file, ':h')
  let l:found = 0

  while l:check !=# l:root
    let l:git_dir = l:check . '/.git'

    if isdirectory(l:git_dir)
      let l:root = l:check
      let l:found = 1
      break
    endif

    let l:root = l:check
    let l:check = fnamemodify(l:check, ':h')
  endwhile

  if !l:found
    throw 'No git repo found'
  endif

  let l:hash = systemlist(['git', '-C', l:root, 'rev-parse', 'HEAD'])[0]
  let l:remote = systemlist(['git', '-C', l:root, 'remote'])[0]
  let l:url = systemlist(['git', '-C', l:root, 'remote', 'get-url', l:remote])[0]

  " remove the SSH protocol prefix
  let l:url = substitute(l:url, '^ssh://', 'https://', '')
  let l:url = substitute(l:url, 'https://.*@', 'https://', '')
  let l:url = substitute(l:url, '\.git$', '', '')

  if has_key(g:git_urls, l:url)
    let l:url = g:git_urls[l:url]
  endif

  let l:rel_path = substitute(l:file, l:root . '/', '', '')

  let l:gitlab_url = l:url . '/blob/' . l:hash . '/' . l:rel_path

  if a:range == 0
  elseif a:range == 1 || a:line1 ==# a:line2
    let l:gitlab_url = l:gitlab_url . '#L' . a:line1
  else
    let l:line2 = a:line2
    if l:url =~ "^https://github.com"
      let l:line2 = 'L' . l:line2
    endif
    let l:gitlab_url = l:gitlab_url . '#L' . a:line1 . '-' . l:line2
  endif

  echom l:gitlab_url

  " Linux
  let l:exec = 'xdg-open'

  if executable('open')
    " Mac
    let l:exec = 'open'
  endif

  call system([l:exec, l:gitlab_url])
endfunction

command! -range OpenGit :call OpenGit(<range>, <line1>, <line2>)
