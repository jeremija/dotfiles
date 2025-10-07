" Color scheme based on last256 (https://github.com/sk1418/last256)
let g:colors_name = 'jeremija'

" set notermguicolors

if &t_Co < 256
  finish
endif

" if $COLORTERM == "truecolor"
" 	echo "truecolor"
" else
" 	echo "not true color"
" endif

" set background=dark
hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "last256"

"}}}
" GUI And Cterm Palettes:"{{{
" ----------------------------------------------------------------------------
if has('termguicolors') && &termguicolors
  let s:vmode      = "gui"
  let s:white      = "#c6c6c6"
  let s:background = "#000000"
  let s:window     = "#5f5f5f"
  let s:darkcolumn = "#1c1c1c"
  let s:addbg      = "#5f875f"
  let s:addfg      = "#d7ffaf"
  let s:changebg   = "#5f5f87"
  let s:changefg   = "#d7d7ff"
  let s:brown      = "#87875f"
  let s:foreground = "#a8a8a8"
  let s:selection  = "#585858"
  let s:visual     = "#5f8787"
  let s:line       = "#121212"
  let s:comment    = "#585858"
  let s:red        = "#d75f5f"
  let s:orange     = "#d78700"
  let s:yellow     = "#d7af00"
  let s:green      = "#5faf5f"
  let s:aqua       = "#87afff"
  let s:blue       = "#5f87ff"
  let s:purple     = "#8787ff"

  if &background == "light"
    let s:white      = "#3a3a3a"   " Now a dark gray to contrast the light background
    let s:background = "#efe7d2"   " Light tan/cream background
    let s:window     = "#b3ab98"   " Soft taupe gray
    let s:darkcolumn = "#d7cfba"   " Slightly darker than background, for subtle side columns
    let s:addbg      = "#a3cfa3"   " Muted pastel green (for additions)
    let s:addfg      = "#324632"   " Dark olive green text
    let s:changebg   = "#a3b3cf"   " Muted dusty blue
    let s:changefg   = "#2a3346"   " Charcoal navy
    let s:brown      = "#8c7f5a"   " Earthy brown, muted
    let s:foreground = "#2e2e2e"   " Primary text color, dark gray
    let s:selection  = "#cfc7b0"   " Slightly darker beige for selections
    let s:visual     = "#aacfcf"   " Muted cyan for visual mode
    let s:line       = "#dcd4bd"   " Very subtle line background
    let s:comment    = "#a89f8a"   " Grayish-brown for comments
    let s:red        = "#af5f5f"   " Muted brick red
    let s:orange     = "#af8700"   " Dusty amber
    let s:yellow     = "#af9f00"   " Muted mustard yellow
    let s:green      = "#5f9f5f"   " Calm green
    let s:aqua       = "#5f87af"   " Dusty blue
    let s:blue       = "#5f7faf"   " Steel blue
    let s:purple     = "#7f7faf"   " Dusty violet
  endif
else
  let s:vmode      = "cterm"
  let s:white      = "251"
  let s:background = "16"
  let s:window     = "59"
  let s:darkcolumn = "234"
  let s:addbg      = "65"
  let s:addfg      = "193"
  let s:changebg   = "60"
  let s:changefg   = "189"
  let s:brown      = "101"
  let s:foreground = "248"
  let s:selection  = "240"
  let s:visual     = "66"
  let s:line       = "233"
  let s:comment    = "240"
  let s:red        = "167"
  let s:orange     = "172"
  let s:yellow     = "178"
  let s:green      = "71"
  let s:aqua       = "111"
  let s:blue       = "69"
  let s:purple     = "105"
endif

"}}}
" Formatting Options:"{{{
" ----------------------------------------------------------------------------
let s:none   = "NONE"
let s:t_none = "NONE"
let s:n      = "NONE"
let s:c      = ",undercurl"
let s:r      = ",reverse"
let s:s      = ",standout"
let s:b      = ",bold"
let s:u      = ",underline"
let s:i      = ",italic"

"}}}
" Highlighting Primitives:"{{{
" ----------------------------------------------------------------------------
exe "let s:bg_none       = ' ".s:vmode."bg = ".s:none      ."'"
exe "let s:bg_foreground = ' ".s:vmode."bg = ".s:foreground."'"
exe "let s:bg_background = ' ".s:vmode."bg = ".s:background."'"
exe "let s:bg_selection  = ' ".s:vmode."bg = ".s:selection ."'"
exe "let s:bg_visual     = ' ".s:vmode."bg = ".s:visual ."'"
exe "let s:bg_line       = ' ".s:vmode."bg = ".s:line      ."'"
exe "let s:bg_comment    = ' ".s:vmode."bg = ".s:comment   ."'"
exe "let s:bg_brown      = ' ".s:vmode."bg = ".s:brown   ."'"
exe "let s:bg_white      = ' ".s:vmode."bg = ".s:white   ."'"
exe "let s:bg_red        = ' ".s:vmode."bg = ".s:red       ."'"
exe "let s:bg_orange     = ' ".s:vmode."bg = ".s:orange    ."'"
exe "let s:bg_yellow     = ' ".s:vmode."bg = ".s:yellow    ."'"
exe "let s:bg_green      = ' ".s:vmode."bg = ".s:green     ."'"
exe "let s:bg_aqua       = ' ".s:vmode."bg = ".s:aqua      ."'"
exe "let s:bg_blue       = ' ".s:vmode."bg = ".s:blue      ."'"
exe "let s:bg_purple     = ' ".s:vmode."bg = ".s:purple    ."'"
exe "let s:bg_window     = ' ".s:vmode."bg = ".s:window    ."'"
exe "let s:bg_darkcolumn = ' ".s:vmode."bg = ".s:darkcolumn."'"
exe "let s:bg_addbg      = ' ".s:vmode."bg = ".s:addbg     ."'"
exe "let s:bg_addfg      = ' ".s:vmode."bg = ".s:addfg     ."'"
exe "let s:bg_changebg   = ' ".s:vmode."bg = ".s:changebg  ."'"
exe "let s:bg_changefg   = ' ".s:vmode."bg = ".s:changefg  ."'"

exe "let s:fg_none       = ' ".s:vmode."fg = ".s:none      ."'"
exe "let s:fg_foreground = ' ".s:vmode."fg = ".s:foreground."'"
exe "let s:fg_background = ' ".s:vmode."fg = ".s:background."'"
exe "let s:fg_selection  = ' ".s:vmode."fg = ".s:selection ."'"
exe "let s:fg_visual     = ' ".s:vmode."fg = ".s:visual ."'"
exe "let s:fg_line       = ' ".s:vmode."fg = ".s:line      ."'"
exe "let s:fg_comment    = ' ".s:vmode."fg = ".s:comment   ."'"
exe "let s:fg_brown      = ' ".s:vmode."fg = ".s:brown   ."'"
exe "let s:fg_white      = ' ".s:vmode."fg = ".s:white   ."'"
exe "let s:fg_red        = ' ".s:vmode."fg = ".s:red       ."'"
exe "let s:fg_orange     = ' ".s:vmode."fg = ".s:orange    ."'"
exe "let s:fg_yellow     = ' ".s:vmode."fg = ".s:yellow    ."'"
exe "let s:fg_green      = ' ".s:vmode."fg = ".s:green     ."'"
exe "let s:fg_aqua       = ' ".s:vmode."fg = ".s:aqua      ."'"
exe "let s:fg_blue       = ' ".s:vmode."fg = ".s:blue      ."'"
exe "let s:fg_purple     = ' ".s:vmode."fg = ".s:purple    ."'"
exe "let s:fg_window     = ' ".s:vmode."fg = ".s:window    ."'"
exe "let s:fg_darkcolumn = ' ".s:vmode."fg = ".s:darkcolumn."'"
exe "let s:fg_addbg      = ' ".s:vmode."fg = ".s:addbg     ."'"
exe "let s:fg_addfg      = ' ".s:vmode."fg = ".s:addfg     ."'"
exe "let s:fg_changebg   = ' ".s:vmode."fg = ".s:changebg  ."'"
exe "let s:fg_changefg   = ' ".s:vmode."fg = ".s:changefg  ."'"

exe "let s:fmt_none      = ' ".s:vmode."   = NONE".          " term = NONE"        ."'"
exe "let s:fmt_bold      = ' ".s:vmode."   = NONE".s:b.      " term = NONE".s:b    ."'"
exe "let s:fmt_bldi      = ' ".s:vmode."   = NONE".s:b.      " term = NONE".s:b    ."'"
exe "let s:fmt_undr      = ' ".s:vmode."   = NONE".s:u.      " term = NONE".s:u    ."'"
exe "let s:fmt_undb      = ' ".s:vmode."   = NONE".s:u.s:b.  " term = NONE".s:u.s:b."'"
exe "let s:fmt_undi      = ' ".s:vmode."   = NONE".s:u.      " term = NONE".s:u    ."'"
exe "let s:fmt_curl      = ' ".s:vmode."   = NONE".s:c.      " term = NONE".s:c    ."'"
exe "let s:fmt_ital      = ' ".s:vmode."   = NONE".s:i.      " term = NONE".s:i    ."'"
exe "let s:fmt_stnd      = ' ".s:vmode."   = NONE".s:s.      " term = NONE".s:s    ."'"
exe "let s:fmt_revr      = ' ".s:vmode."   = NONE".s:r.      " term = NONE".s:r    ."'"
exe "let s:fmt_revb      = ' ".s:vmode."   = NONE".s:r.s:b.  " term = NONE".s:r.s:b."'"

if has("gui_running")
  exe "let s:sp_none       = ' guisp=".s:none      ."'"
  exe "let s:sp_foreground = ' guisp=".s:foreground."'"
  exe "let s:sp_background = ' guisp=".s:background."'"
  exe "let s:sp_selection  = ' guisp=".s:selection ."'"
  exe "let s:sp_visual  = ' guisp=".s:visual ."'"
  exe "let s:sp_line       = ' guisp=".s:line      ."'"
  exe "let s:sp_comment    = ' guisp=".s:comment   ."'"
  exe "let s:sp_brown    = ' guisp=".s:brown   ."'"
  exe "let s:sp_red        = ' guisp=".s:red       ."'"
  exe "let s:sp_orange     = ' guisp=".s:orange    ."'"
  exe "let s:sp_yellow     = ' guisp=".s:yellow    ."'"
  exe "let s:sp_green      = ' guisp=".s:green     ."'"
  exe "let s:sp_aqua       = ' guisp=".s:aqua      ."'"
  exe "let s:sp_blue       = ' guisp=".s:blue      ."'"
  exe "let s:sp_purple     = ' guisp=".s:purple    ."'"
  exe "let s:sp_window     = ' guisp=".s:window    ."'"
  exe "let s:sp_addbg      = ' guisp=".s:addbg     ."'"
  exe "let s:sp_addfg      = ' guisp=".s:addfg     ."'"
  exe "let s:sp_changebg   = ' guisp=".s:changebg  ."'"
  exe "let s:sp_changefg   = ' guisp=".s:changefg  ."'"
else
  let s:sp_none       = ""
  let s:sp_foreground = ""
  let s:sp_background = ""
  let s:sp_selection  = ""
  let s:sp_line       = ""
  let s:sp_comment    = ""
  let s:sp_brown    = ""
  let s:sp_red        = ""
  let s:sp_orange     = ""
  let s:sp_yellow     = ""
  let s:sp_green      = ""
  let s:sp_aqua       = ""
  let s:sp_blue       = ""
  let s:sp_purple     = ""
  let s:sp_window     = ""
  let s:sp_addbg      = ""
  let s:sp_addfg      = ""
  let s:sp_changebg   = ""
  let s:sp_changefg   = ""
endif

"}}}
" Vim Highlighting: (see :help highlight-groups)"{{{
" ----------------------------------------------------------------------------
exe "hi! ColorColumn"   .s:fg_none        .s:bg_line        .s:fmt_none
"		Conceal"
"		Cursor"
"		CursorIM"
exe "hi! Title"         .s:fg_white       .s:bg_none        .s:fmt_bold
exe "hi! CursorColumn"  .s:fg_none        .s:bg_line        .s:fmt_none
exe "hi! CursorLine"    .s:fg_none        .s:bg_line        .s:fmt_none
exe "hi! Directory"     .s:fg_aqua        .s:bg_none        .s:fmt_none
exe "hi! DiffAdd"       .s:fg_addfg       .s:bg_addbg       .s:fmt_none
exe "hi! DiffChange"    .s:fg_changefg    .s:bg_changebg    .s:fmt_none
exe "hi! DiffDelete"    .s:fg_background  .s:bg_red         .s:fmt_none
exe "hi! DiffText"      .s:fg_background  .s:bg_blue        .s:fmt_none
exe "hi! ErrorMsg"      .s:fg_background  .s:bg_red         .s:fmt_stnd
exe "hi! VertSplit"     .s:fg_brown       .s:bg_none         .s:fmt_none
exe "hi! Folded"        .s:fg_comment     .s:bg_darkcolumn  .s:fmt_none
exe "hi! FoldColumn"    .s:fg_none        .s:bg_darkcolumn  .s:fmt_none
exe "hi! SignColumn"    .s:fg_none        .s:bg_darkcolumn  .s:fmt_none
"		Incsearch"
exe "hi! LineNr"        .s:fg_selection   .s:bg_none        .s:fmt_none
exe "hi! CursorLineNr"  .s:fg_yellow      .s:bg_none        .s:fmt_bold
exe "hi! MatchParen"    .s:fg_white       .s:bg_changebg    .s:fmt_bold
exe "hi! MoreMsg"       .s:fg_green       .s:bg_none        .s:fmt_bold
exe "hi! NonText"       .s:fg_selection   .s:bg_none        .s:fmt_none
exe "hi! Pmenu"         .s:fg_foreground  .s:bg_selection   .s:fmt_none
exe "hi! PmenuSel"      .s:fg_background  .s:bg_visual   .s:fmt_none
"		PmenuSbar"
"		PmenuThumb"
exe "hi! Question"      .s:fg_green       .s:bg_none        .s:fmt_none
exe "hi! Search"        .s:fg_background  .s:bg_orange      .s:fmt_none
exe "hi! SpecialKey"    .s:fg_selection   .s:bg_none        .s:fmt_none
exe "hi! SpellBad"      .s:fg_red         .s:bg_none        .s:fmt_undr
exe "hi! SpellCap"      .s:fg_blue        .s:bg_none        .s:fmt_undr
exe "hi! SpellLocal"    .s:fg_aqua        .s:bg_none        .s:fmt_undr
exe "hi! SpellRare"     .s:fg_purple      .s:bg_none        .s:fmt_undr
exe "hi! StatusLine"    .s:fg_orange      .s:bg_none        .s:fmt_none
exe "hi! StatusLineNC"  .s:fg_none        .s:bg_none        .s:fmt_none

"		VisualNos"
exe "hi! WarningMsg"    .s:fg_red         .s:bg_none        .s:fmt_none
"		WildMenu"

if has('gui_running')
  exe "hi! Normal"        .s:fg_foreground  .s:bg_background  .s:fmt_none
else
  exe "hi! Normal"        .s:fg_foreground  .s:bg_none        .s:fmt_none
endif

"}}}
" Generic Syntax Highlighting: (see :help group-name)"{{{
" ----------------------------------------------------------------------------
exe "hi! Comment"         .s:fg_comment     .s:bg_none        .s:fmt_none

exe "hi! Constant"        .s:fg_red         .s:bg_none        .s:fmt_none
exe "hi! String"          .s:fg_green       .s:bg_none        .s:fmt_none
"		Character"
"		Number"
"		Boolean"
"		Float"

exe "hi! Identifier"      .s:fg_purple      .s:bg_none        .s:fmt_none
exe "hi! Function"        .s:fg_yellow      .s:bg_none        .s:fmt_none

exe "hi! Statement"       .s:fg_aqua        .s:bg_none        .s:fmt_bold
"		Conditional"
"		Repeat"
"		Label"
exe "hi! Operator"        .s:fg_foreground  .s:bg_none        .s:fmt_none
"		Keyword"
"		Exception"

exe "hi! PreProc"         .s:fg_blue        .s:bg_none        .s:fmt_none
"		Include"
"		Define"
"		Macro"
"		PreCondit"

exe "hi! Type"            .s:fg_orange      .s:bg_none        .s:fmt_bold
"		StorageClass"
exe "hi! Structure"       .s:fg_aqua        .s:bg_none        .s:fmt_bold
"		Typedef"

exe "hi! Special"         .s:fg_green       .s:bg_none        .s:fmt_none
exe "hi! SpecialComment"         .s:fg_brown       .s:bg_none        .s:fmt_none
"		SpecialChar"
"		Tag"
"		Delimiter"
"		SpecialComment"
"		Debug"
"
exe "hi! Underlined"      .s:fg_aqua       .s:bg_none        .s:fmt_none

exe "hi! Ignore"          .s:fg_none        .s:bg_none        .s:fmt_none

exe "hi! Error"           .s:fg_red         .s:bg_none        .s:fmt_undr

exe "hi! Todo"            .s:fg_background       .s:bg_green        .s:fmt_none


" Quickfix window highlighting
exe "hi! qfLineNr"        .s:fg_yellow      .s:bg_none        .s:fmt_none
"   qfFileName"
"   qfLineNr"
"   qfError"

"add Important and mark1-3 groups
exe "hi! MK1"       . s:fg_background . s:bg_blue   . s:fmt_none
exe "hi! MK2"       . s:fg_background . s:bg_purple . s:fmt_none
exe "hi! MK3"       . s:fg_background . s:bg_orange . s:fmt_none
exe "hi! Important" . s:fg_background . s:bg_red    . s:fmt_bold
exe "hi! FIXME"     . s:fg_addfg      . s:bg_red    . s:fmt_bold
" neovim
exe "hi! WinSeparator"   . s:fg_darkcolumn
exe "hi! NormalFloat"    . s:bg_line
exe "hi! SnippetTabStop" . s:fg_none . s:bg_line
" markdown plugin
exe "hi! RenderMarkdownCode"     . s:bg_darkcolumn
exe "hi! RenderMarkdownQuote"    . s:fg_comment
exe "hi! RenderMarkdownInfo"     . s:fg_aqua
" typescript plugin
exe "hi! tsxTagName" . s:fg_yellow
exe "hi! tsxAttrib"  . s:fg_orange
"add autocommands
autocmd BufWinEnter * call matchadd("Important","!Important!")
autocmd BufWinEnter * call matchadd("MK1","!MARK1")
autocmd BufWinEnter * call matchadd("MK2","!MARK2")
autocmd BufWinEnter * call matchadd("MK3","!MARK3")
autocmd BufWinEnter * call matchadd("FIXME","FIXME")
"}}}
" Diff Syntax Highlighting:"{{{
" ----------------------------------------------------------------------------
" Diff
"		diffOldFile
"		diffNewFile
"		diffFile
"		diffOnly
"		diffIdentical
"		diffDiffer
"		diffBDiffer
"		diffIsA
"		diffNoEOL
"		diffCommon
hi! link diffRemoved Constant
"		diffChanged
hi! link diffAdded Special
"		diffLine
"		diffSubname
"		diffComment

" Tabline
hi! link TabLineFill StatusLineNC
hi! link TabLineSel  StatusLine
" hi! link TabLine Pmenu
hi! TabLine ctermfg=none ctermbg=none cterm=none
"}}}

" vim: fdm=marker:sw=2:ts=2:tw=80
