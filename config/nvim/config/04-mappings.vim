let mapleader = ","
noremap <Leader>i :ImportJSWord<CR>
noremap <Leader>I :ImportJSFix<CR> noremap <Leader>gi :ImportJSGoto<CR>
noremap <Leader>j :ALEPreviousWrap<CR>
noremap <Leader>k :ALENextWrap<CR>
noremap <Leader>c :Commentary<CR>
noremap <Leader>. :bnext<CR>
noremap <Leader>m :bprev<CR>
noremap <Leader>tn :tabnext<CR>
noremap <Leader>tp :tabprev<CR>
noremap <Leader>tc :tabnew<CR>
noremap <Leader>tx :tabclose<CR>
noremap <Leader>b :Buffers<CR>
noremap <Leader>r :vertical resize 82<CR>
noremap <Leader>gd :YcmCompleter GoToDefinition<CR>
noremap <Leader>gt :YcmCompleter GetType<CR>
noremap <Leader>gD :YcmCompleter GetDoc<CR>
noremap <Leader>n :NERDTree<CR>
noremap <Leader>N :NERDTreeClose<CR>
noremap <Leader>f :NERDTreeFind<CR>
noremap <Leader>F :NERDTreeCWD<CR>

noremap <C-PageUp> :bprev<CR>
noremap <C-PageDown> :bnext<CR>
noremap <C-H> <C-W>h
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-L> <C-W>l
noremap <silent> <C-p> :call fzf#run({ 'source': 'rg --hidden --files $(git rev-parse --show-cdup)', 'sink': 'e' })<CR>
