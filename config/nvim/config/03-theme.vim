set t_Co=256
silent! colorscheme last256

hi tsxTagName ctermfg=11
hi tsxAttrib ctermfg=172
hi MatchParen cterm=bold ctermbg=none ctermfg=white
hi StatusLine  ctermfg=172 ctermbg=none
hi StatusLineNC  ctermfg=none ctermbg=none cterm=none
hi VertSplit ctermbg=none cterm=none
hi TabLine ctermfg=none ctermbg=none cterm=none
hi Normal ctermfg=248
hi ColorColumn ctermbg=233

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
set statusline +=%{LinterStatus()}
set statusline+=%*                 "switch to default color
