set encoding=utf-8
scriptencoding utf-8

let g:nvim_dir = expand('~/.config/nvim')
let &runtimepath = g:nvim_dir . ',' . &runtimepath
let &packpath = g:nvim_dir . ',' . &packpath

let s:config_dir = g:nvim_dir . '/config/'
let g:python_host_prog = g:nvim_dir . '/python2/python2-wrapper'
let g:python3_host_prog = g:nvim_dir . '/python3/python3-wrapper'
kk


exec 'source ' . s:config_dir . '01-plugins.vim'
exec 'source ' . s:config_dir . '02-general.vim'
exec 'source ' . s:config_dir . '03-theme.vim'
exec 'source ' . s:config_dir . '04-mappings.vim'

let s:local_config = s:config_dir . '99-local.vim'

if filereadable(s:local_config)
  exec 'source ' . s:local_config
endif
