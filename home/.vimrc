set encoding=utf-8
scriptencoding utf-8

let s:config_dir = expand('~/.config/nvim/config/')
let g:python_host_prog = s:config_dir . '../python2/env/bin/python2'
let g:python3_host_prog = s:config_dir . '../python3/env/bin/python3'


exec 'source ' . s:config_dir . '01-plugins.vim'
exec 'source ' . s:config_dir . '02-general.vim'
exec 'source ' . s:config_dir . '03-theme.vim'
exec 'source ' . s:config_dir . '04-mappings.vim'
