let g:mapleader = ','
noremap <Leader>gi :ImportJSGoto<CR>
inoremap <C-k> <Esc>:ImportJSWord<CR>a
noremap <Leader>aj :ALENextWrap<CR>
noremap <Leader>ak :ALEPreviousWrap<CR>
noremap <Leader>c :Commentary<CR>
noremap <Leader>. :bnext<CR>
noremap <Leader>m :bprev<CR>
noremap <Leader>tx :tabclose<CR>
noremap <Leader>p :Buffers<CR>
noremap <Leader>e :e <C-R>=expand("%:h") . "/" <CR>
noremap <Leader>E :vertical resize 82<CR>
noremap <Leader>ad :ALEDetail<CR>
noremap <Leader>aD :ALEDocumentation<CR>
noremap <Leader>agd :ALEGoToDefinition<CR>
noremap <Leader>agt :ALEHover<CR>
noremap <Leader>agT :ALEGoToDefinitionInTab<CR>
noremap <Leader>aR :ALEFindReferences<CR>
noremap <Leader>ao :ALEOrganizeImports<CR>
noremap <Leader>ar :ALERename<CR>
noremap <Leader>ax :ALEFix<CR>
noremap <Leader>nt :NvimTreeToggle<CR>
noremap <Leader>nx :NvimTreeClose<CR>
noremap <Leader>nf :NvimTreeFindFile<CR>
noremap <Leader>nF :NvimTreeFocus<CR>
noremap <Leader>tn :TestNearest<CR>
noremap <Leader>tf :TestFile<CR>
noremap <Leader>ts :TestSuite<CR>
noremap <Leader>tl :TestLast<CR>
noremap <Leader>tv :TestVisit<CR>
noremap <Leader>ss vip:sort<CR>
noremap <Leader>tt :OpenTest<CR>

noremap <Leader>C :FzfLua lsp_code_actions<CR>
vnoremap <Leader>C :FzfLua lsp_code_actions<CR>
noremap <Leader>lr :FzfLua lsp_references<CR>
noremap <Leader>ldf :FzfLua lsp_definitions<CR>
noremap <Leader>ldc :FzfLua lsp_declarations<CR>
noremap <Leader>lt :FzfLua lsp_typedefs<CR>
noremap <Leader>li :FzfLua lsp_implementations<CR>
noremap <Leader>lds :FzfLua lsp_document_symbols<CR>
noremap <Leader>lws :FzfLua lsp_workspace_symbols<CR>
noremap <Leader>ws :FzfLua lsp_live_workspace_symbols<CR>
noremap <Leader>lc :FzfLua lsp_incoming_calls<CR>
noremap <Leader>lo :FzfLua lsp_outgoing_calls<CR>
noremap <Leader>lf :FzfLua lsp_finder<CR>
noremap <Leader>dd :FzfLua diagnostics_document<CR>
noremap <Leader>dw :FzfLua diagnostics_workspace<CR>
noremap <Leader>ldd :FzfLua lsp_document_diagnostics<CR>
noremap <Leader>lwd :FzfLua lsp_workspace_diagnostics<CR>

noremap <C-PageUp> :bprev<CR>
noremap <C-PageDown> :bnext<CR>
noremap <C-H> <C-W>h
noremap <C-J> <C-W>j
noremap <C-K> <C-W>k
noremap <C-L> <C-W>l
noremap <silent> <C-p> :call fzf#run(fzf#wrap({ 'source': 'rg --hidden --files', 'options': ['--preview', 'head --bytes 2048 {}'], 'sink': 'e' }))<CR>
inoremap <expr> <C-X><C-J> fzf#vim#complete#path('rg --hidden --files')
noremap <silent> <Leader>f :Rg<CR>

" imap <C-A> <Plug>(ale_complete)
" nmap <C-A> <Plug>(ale_complete)

" Bind <Tab> and <S-Tab> to Up/Down when popup menu is visible
inoremap <expr> <Tab> pumvisible() ? "\<Down>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<Up>" : "\<S-Tab>"

inoremap <C-Space> <C-x><C-o>
inoremap <C-@> <C-Space>
