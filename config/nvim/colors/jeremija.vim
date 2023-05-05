runtime pack/bundle/start/vim-colorschemes/colors/last256.vim
let g:colors_name = 'jeremija'

hi tsxTagName ctermfg=11
hi tsxAttrib ctermfg=172
hi MatchParen cterm=bold ctermbg=none ctermfg=white
hi StatusLine  ctermfg=172 ctermbg=none
hi StatusLineNC  ctermfg=none ctermbg=none cterm=none
hi VertSplit ctermbg=none cterm=none
hi TabLine ctermfg=none ctermbg=none cterm=none
hi Normal ctermfg=248
hi ColorColumn ctermbg=233

hi DiffAdd ctermbg=233 ctermfg=172
hi DiffDelete ctermbg=none ctermfg=black
hi DiffChange ctermbg=233 ctermfg=248
hi DiffText ctermbg=236 ctermfg=11

" floating window for LSP popups
hi NormalFloat ctermbg=233

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
