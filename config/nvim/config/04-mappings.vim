let mapleader = ","
noremap <Leader>i :ImportJSWord<CR>
noremap <Leader>I :ImportJSFix<CR>
noremap <Leader>gi :ImportJSGoto<CR>
inoremap <C-k> <Esc>:ImportJSWord<CR>a
noremap <Leader>j :ALEPreviousWrap<CR>
noremap <Leader>k :ALENextWrap<CR>
noremap <Leader>c :Commentary<CR>
noremap <Leader>. :bnext<CR>
noremap <Leader>m :bprev<CR>
noremap <Leader>tc :tabnew<CR>
noremap <Leader>tx :tabclose<CR>
noremap <Leader>b :Buffers<CR>
noremap <Leader>r :vertical resize 82<CR>
noremap <Leader>gd :ALEGoToDefinition<CR>
noremap <Leader>gt :ALEHover<CR>
noremap <Leader>gT :ALEGoToDefinitionInTab<CR>
noremap <Leader>gR :ALEFindReferences<CR>
noremap <Leader>nt :NERDTreeToggle<CR>
noremap <Leader>nx :NERDTreeClose<CR>
noremap <Leader>nf :NERDTreeFind<CR>
noremap <Leader>nF :NERDTreeFocus<CR>
noremap <Leader>nc :NERDTreeCWD<CR>

noremap <C-PageUp> :bprev<CR>
noremap <C-PageDown> :bnext<CR>
noremap <C-H> <C-W>h
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-L> <C-W>l
noremap <silent> <C-p> :call fzf#run({ 'source': 'rg --hidden --files $(git rev-parse --show-cdup)', 'sink': 'e' })<CR>

" Show completions even when g:ale_completion_enabled = 0
function! GetCompletions() abort
	let l:completion_enabled = get(g:, 'ale_completion_enabled', 0)
  if !l:completion_enabled
    let g:ale_completion_enabled = 1
	endif
  call ale#completion#GetCompletions()
  if !l:completion_enabled
		let g:ale_completion_enabled = 0
	endif
endfunction

inoremap <silent><C-Space> <C-\><C-O>:call GetCompletions()<CR>

" Bind <Tab> and <S-Tab> to Up/Down when popup menu is visible
inoremap <expr> <Tab> pumvisible() ? "\<Down>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<Up>" : "\<S-Tab>"

command! -bang -nargs=* Rg
	\ call fzf#vim#grep(
	\   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
	\   <bang>0 ? fzf#vim#with_preview('up:60%')
	\           : fzf#vim#with_preview('right:50%:hidden', '?'),
	\   <bang>0)
