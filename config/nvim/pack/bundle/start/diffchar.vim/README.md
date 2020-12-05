# diffchar.vim
*Highlight the exact differences, based on characters and words*
```
 ____   _  ____  ____  _____  _   _  _____  ____   
|    | | ||    ||    ||     || | | ||  _  ||  _ |  
|  _  || ||  __||  __||     || | | || | | || | ||  
| | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
| |_| || ||  __||  __||  |   |     ||     ||  __  |
|     || || |   | |   |  |__ |  _  ||  _  || |  | |
|____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
```

#### Introduction

This plugin has been developed in order to make diff mode more useful. Vim
highlights all the text in between the first and last different characters on
a changed line. But this plugin will find the exact differences between them,
character by character - so called *DiffChar*.

For example, in diff mode:  
![example1](example1.png)

This plugin will exactly show the changed and added units:  
![example2](example2.png)

This plugin will synchronously show/reset the highlights of the exact
differences as soon as the diff mode begins/ends since a `g:DiffModeSync` is
enabled as a default. And the exact differences will be kept updated while
editing.

You can use `:SDChar` and `:RDChar` commands to manually show and reset the
highlights on all or some of lines. To toggle the highlights, use `:TDChar` 
command.

This plugin shows the differences based on a `g:DiffUnit`. Its default is
'Word1' and it handles a \w\+ word and a \W character as a difference unit.
There are other types of word provided and you can also set 'Char' to compare
character by character.

In diff mode, the corresponding changed lines are compared between two
windows. You can set a matching color to a `g:DiffColors` to make it easy to
find the corresponding units between two windows. As a default, all the
changed units are highlighted with `hl-DiffText`. In addition, `hl-DiffAdd` is
always used for the added units and both the previous and next character of
the deleted units are shown in bold/underline.

When the diff mode begins, this plugin detects the limited number of the
`hl-DiffChange` lines, specified by a `g:DiffMaxLines`, in the current visible
and upper/lower lines of the window. Whenever a cursor is moved onto another
line and then the window is scrolled up or down, it dynamically detects the
`hl-DiffChange` lines again. Which means, independently of the file size, the
number of lines to be detected and then the time consumed are always constant.
You can specify a positive value as the actual number of `hl-DiffChange`
lines. The height of the current window is used instead if its value is less
than it. A negative value is also allowed as multiples of the window height.
If 0 is specified, it disables and statically detects all `hl-DiffChange`
lines once the diff mode begins. Its default is -3 and detects three times as
many lines as the window height.

While showing the exact differences, when the cursor is moved on a difference
unit, you can see its corresponding unit with `hl-Cursor` in another window,
based on `g:DiffPairVisible`. In addition, the corresponding unit is echoed in
the command line or displayed in a popup-window just below the cursor
position, if you change its default. And if `g:DiffPairVisible` is enabled, a
balloon window is appeared to display the corresponding unit where the mouse
is pointing.

You can use `]b` or `]e` to jump cursor to start or end position of the next
difference unit, and `[b` or `[e` to the start or end position of the previous
unit. Those keymaps are configurable in your vimrc and so on.

Like line-based `:diffget`/`:diffput` and `do`/`dp` vim commands, you can use
`<Leader>g` and `<Leader>p` commands in normal mode to get and put each
difference unit, where the cursor is on, between 2 buffers and undo its
difference.

In order to check the actual differences in a line, you can use `:EDChar`
command and echo the lines for range. A changed, added, and deleted unit is
shown as `[-...-][+...+]`, `[+...+]`, and `[-...-]` respectively, while showing its
highlight. If a strike highlighting is available such as on GUI and some
terminal, the deleted unit is highlighted with the strike instead and `[+`, `+]`,
`[-`, and `-]` are eliminated. This command tries to shorten some equivalent units
and show `...` instead, if the line is too long to fit on the command line.
The line number is shown if `number` or `relativenumber` option is set in the
window. When [!] is used, nothing is shorten and all lines are displayed.

This plugin has been using "An O(NP) Sequence Comparison Algorithm" developed
by S.Wu, et al., which always finds an optimum sequence. But if there are many
lines to be detected, it takes time to complete the diff tracing. To make it
more efficient, this plugin tries to use the external diff command if
available.

This plugin works on each tab page individually. You can use a tab page
variable (t:), instead of a global one (g:), to specify different options on
each tab page. Note that this plugin can not handle more than two diff mode
windows in a tab page. If it would happen, to prevent any trouble, all
highlighted DiffChar units are to be reset in the tab page.

This plugin has been always positively supporting mulltibyte characters.

#### Commands

* `:[range]SDChar`
  * Show the highlights of difference units for [range]
* `:[range]RDChar`
  * Reset the highlights of difference units for [range]
* `:[range]TDChar`
  * Toggle to show/reset the highlights for [range]
* `:[range]EDChar[!]`
  * Echo the line for [range], by showing each corresponding unit together
    in `[+...+]`/`[-...-]` or strike highlighting. Some equivalent units may be
    shown as `...`. The line number is shown if `number` or `relativenumber`
    option is set in the window. When [!] is used, all lines and all units
    are displayed.

#### Keymaps

* `<Plug>JumpDiffCharPrevStart` (default: `[b`)
  * Jump cursor to the start position of the previous difference unit
* `<Plug>JumpDiffCharNextStart` (default: `]b`)
  * Jump cursor to the start position of the next difference unit
* `<Plug>JumpDiffCharPrevEnd` (default: `[e`)
  * Jump cursor to the end position of the previous difference unit
* `<Plug>JumpDiffCharNextEnd` (default: `]e`)
  * Jump cursor to the end position of the next difference unit
* `<Plug>GetDiffCharPair` (default: `<Leader>g`)
  * Get a corresponding difference unit from another buffer to undo difference
* `<Plug>PutDiffCharPair` (default: `<Leader>p`)
  * Put a corresponding difference unit to another buffer to undo difference

#### Options

* `g:DiffUnit`, `t:DiffUnit` - Type of difference unit
  * 'Word1'  : \w\\+ word and any \W single character (default)
  * 'Word2'  : non-space and space words
  * 'Word3'  : \\< or \\> character class boundaries
  * 'Char'   : any single character
  * 'CSV(,)' : separated by characters such as ',', ';', and '\t'
* `g:DiffColors`, `t:DiffColors` - Matching colors for changed units (always `hl-DiffAdd` for added units)
  * 0   : always `hl-DiffText` (default)
  * 1   : 4 colors in fixed order
  * 2   : 8 colors in fixed order
  * 3   : 16 colors in fixed order
  * 100 : all colors defined in highlight option in dynamic random order
* `g:DiffPairVisible`, `t:DiffPairVisible` - Make a corresponding unit visible when cursor is onto a difference unit
  * 0 : disable
  * 1 : highlight with `hl-Cursor` (default)
  * 2 : highlight with `hl-Cursor` + echo in the command line
  * 3 : highlight with `hl-Cursor` + popup-window at the cursor position
* `g:DiffModeSync`, `t:DiffModeSync`- Synchronously show/reset/update with diff mode
  * 0 : disable
  * 1 : enable (default)
* `g:DiffMaxLines`, `t:DiffMaxLines` - A maximum number of `hl-DiffChange` lines to be dynamically detected
  * -n : multiples of the window height (default as -3)
  * n  : the actual number of lines
  * 0  : disable (detect all `hl-DiffChange` lines once diff mode begins)

#### Demo

![demo](demo.gif)
```viml
:windo diffthis | windo set wrap
<space>...       " move a cursor forward on line 1 and
\g               " get each unit pair from another buffer, then
u                " undo to resume original line 1
...              " move a mouse cursor over on line 3 and show a balloon
:diffoff!

:let t:DiffColors = 2
:windo diffthis | windo set wrap
:EDChar          " echo line 1 together with corresponding diff unit
:%EDChar!        " echo all lines along with the line number
:diffoff!

:let t:DiffPairVisible = 3
:windo diffthis | windo set wrap
]b               " jump to the start of the next unit and
[e               " the end of the previous unit on line 1, then
                 " show the corresponding diff unit in popup-window
:diffoff!
```
