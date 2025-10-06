vim.cmd([[
set encoding=utf-8

let g:nvim_dir = expand('~/.config/nvim')
let &runtimepath = g:nvim_dir . ',' . &runtimepath
let &packpath = g:nvim_dir . ',' . &packpath

let s:config_dir = g:nvim_dir . '/config/'
let g:python_host_prog = g:nvim_dir . '/python2/python2-wrapper'
let g:python3_host_prog = g:nvim_dir . '/python3/python3-wrapper'

exec 'source ' . s:config_dir . '01-plugins.vim'
exec 'source ' . s:config_dir . '02-general.vim'
exec 'source ' . s:config_dir . '04-mappings.vim'

" status function for ale
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    let l:all_errors += luaeval('#vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR })')
    let l:all_non_errors += luaeval('#vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN })')

    let l:total = l:all_errors + l:all_non_errors

    return l:total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   l:all_non_errors,
    \   l:all_errors
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
set statusline +=%{LinterStatus()}
set statusline+=%*                 "switch to default color

let s:local_config = s:config_dir . '99-local.vim'

if filereadable(s:local_config)
  exec 'source ' . s:local_config
endif
]])

require("01-plugins")
require("02-theme")
