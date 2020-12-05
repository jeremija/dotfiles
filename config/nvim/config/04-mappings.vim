let g:mapleader = ','
noremap <Leader>gi :ImportJSGoto<CR>
inoremap <C-k> <Esc>:ImportJSWord<CR>a
noremap <Leader>j :ALENextWrap<CR>
noremap <Leader>k :ALEPreviousWrap<CR>
noremap <Leader>c :Commentary<CR>
noremap <Leader>. :bnext<CR>
noremap <Leader>m :bprev<CR>
noremap <Leader>tx :tabclose<CR>
noremap <Leader>p :Buffers<CR>
noremap <Leader>e :e <C-R>=expand("%:h") . "/" <CR>
noremap <Leader>E :vertical resize 82<CR>
noremap <Leader>d :ALEDetail<CR>
noremap <Leader>D :ALEDocumentation<CR>
noremap <Leader>gd :ALEGoToDefinition<CR>
noremap <Leader>gt :ALEHover<CR>
noremap <Leader>gT :ALEGoToDefinitionInTab<CR>
noremap <Leader>R :ALEFindReferences<CR>
noremap <Leader>o :ALEOrganizeImports<CR>
noremap <Leader>r :ALERename<CR>
noremap <Leader>x :ALEFix<CR>
noremap <Leader>nt :NERDTreeToggle<CR>
noremap <Leader>nx :NERDTreeClose<CR>
noremap <Leader>nf :NERDTreeFind<CR>
noremap <Leader>nF :NERDTreeFocus<CR>
noremap <Leader>nc :NERDTreeCWD<CR>
noremap <Leader>tn :TestNearest<CR>
noremap <Leader>tf :TestFile<CR>
noremap <Leader>ts :TestSuite<CR>
noremap <Leader>tl :TestLast<CR>
noremap <Leader>tv :TestVisit<CR>
noremap <Leader>ss vip:sort<CR>
noremap <Leader>tt :OpenTest<CR>

noremap <C-PageUp> :bprev<CR>
noremap <C-PageDown> :bnext<CR>
noremap <C-H> <C-W>h
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-L> <C-W>l
noremap <silent> <C-p> :call fzf#run({ 'source': 'rg --hidden --files', 'sink': 'e' })<CR>
inoremap <expr> <C-X><C-J> fzf#vim#complete#path('rg --hidden --files')
noremap <silent> <Leader>f :Rg<CR>

imap <C-Space> <Plug>(ale_complete)
nmap <C-Space> <Plug>(ale_complete)

" Bind <Tab> and <S-Tab> to Up/Down when popup menu is visible
inoremap <expr> <Tab> pumvisible() ? "\<Down>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<Up>" : "\<S-Tab>"
