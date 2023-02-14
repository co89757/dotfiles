set nocompatible              " be iMproved, required
set number "set line #
set shell=/bin/bash
inoremap jj <ESC>
filetype off                  " required
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
" Move within quickfix window entries by ]/[q
nnoremap [q :cp<CR> 
nnoremap ]q :cn<CR>
nnoremap <F12> <C-]>
nnoremap <S-F12> <C-W-}>
" Sets how many lines of history VIM has to remember
set history=500

"Configuration for tags file
set tags=./.tags;,.tags

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
"COLIN change leader to space
let mapleader = ","
let g:mapleader = ","
let maplocalleader = "\\"
nnoremap <leader>ev :e ~/.vimrc <CR>
" Surround current word with quotes
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>a :Ack!<Space>
" open a newline above and stay in current line
nnoremap <leader>O O<esc>j
inoremap <C-v> <C-R> <C-P> "


"COLIN-remove trailing spaces on each linnoe
nnoremap <leader><Space><Space> :%s/\s\+$//<cr>
" Fast saving
nnoremap <leader>w :w!<cr>
" Tagbar toggle
nnoremap <F8> :TagbarToggle<CR>
"open nerd tree
nnoremap <F9> :NERDTreeToggle<CR>
" :W sudo saves the file
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch matchtime=3
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable
set t_Co=256
" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

set listchars=tab:>-,trail:-,eol:$ list

" Be smart when using tabs ;)
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""

" Copy using Ctrl-C in v-mode to system clipboard. 
" Note :echo has('clipboard') needs to return 1 for this to work
" Otherwise, please install vim-gtk or vim-gtk3 package
vnoremap <C-c> "+y
" Search and replace visual-selected word with Ctrl+R in v-mode
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" Visual mode pressing * or # searches for the current selection
" Supemapr useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>
" surround with 
vnoremap <leader>s' c'<C-r>"'<Esc>
vnoremap <leader>s( c(<C-r>")<Esc>
vnoremap <leader>s" c"<C-r>""<Esc>
vnoremap <leader>s` c`<C-r>"`<Esc>
" in markdown files surround selection in code block ```
au FileType markdown vnoremap <leader>sb c```<CR><C-r>"<CR>```<CR><Esc>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk
" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /
map <c-space> ?

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Close the current buffer
map <leader>bx :Bclose<cr>

" Close all the buffers
map <leader>ba :bufdo bd<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tx :tabclose<cr>
map <leader>tm :tabmove
map <leader>t<leader> :tabnext

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()


" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=escape(expand("%:p:h"), " ")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif


""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ L:\ %l\ \ C:\ %c

set background=dark
  
"set colorscheme
colorscheme lucius

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfunc
augroup deletetrailws
  autocmd!
  autocmd BufWrite *.py :call DeleteTrailingWS()
  autocmd BufWrite *.go :call DeleteTrailingWS()
  autocmd BufWrite *.md :call DeleteTrailingWS()
  autocmd BufWrite *.cc :call DeleteTrailingWS()
  autocmd BufWrite *.vim :call DeleteTrailingWS()
  autocmd BufWrite *.java :call DeleteTrailingWS()
  autocmd BufWrite *.sh :call DeleteTrailingWS()
augroup END 


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ag searching and cope displaying
"    requires ag.vim - it's much better than vimgrep/grep
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you Ag after the selected text
" vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" Open Ag and put the cursor in the right position
" map <leader>g :Ag

" When you press <leader>r you can search and replace the selected text
" vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with Ag, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
" map <leader>cc :botright cope<cr>
" map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
" map <leader>n :cn<cr>
" map <leader>p :cp<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
map <leader>x :e ~/buffer.md<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
  call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'gv'
      call CmdLine("Ack '" . l:pattern . "' " )
  elseif a:direction == 'replace'
      call CmdLine("%s" . '/'. l:pattern . '/')
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

"show all snippets available for current buffer
function! GetAllSnippets()
  call UltiSnips#SnippetsInCurrentScope(1)
  let list = []
  for [key, info] in items(g:current_ulti_dict_info)
    let parts = split(info.location, ':')
    call add(list, {
      \"key": key,
      \"path": parts[0],
      \"linenr": parts[1],
      \"description": info.description,
      \})
  endfor
  return list
endfunction

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" =>  Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()
Plug 'mattn/emmet-vim', {'for':'html'}
Plug 'jiangmiao/auto-pairs'
Plug 'majutsushi/tagbar'
" Plug 'ludovicchabant/vim-gutentags'
" Plug 'w0rp/ale'
Plug 'Yggdroot/LeaderF'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mileszs/ack.vim'
"Custom text objects
"new text-objs:
"  i, and a, : parameter object
"  ii and ai : identation object e.g vii dii cii 
"  if and af : function object e.g. vif dif cif on functions
"  new text-objs:
"    i, and a, : parameter object
"    ii and ai : identation object e.g vii dii cii 
"    if and af : function object e.g. vif dif cif on functions
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function'
Plug 'sgur/vim-textobj-parameter'

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'scrooloose/nerdcommenter'
Plug 'Chiel92/vim-autoformat'
" Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
"Plug 'fatih/vim-go'  "Optional for go dev
Plug 'skywind3000/asyncrun.vim'
" Plug 'Valloric/YouCompleteMe' "Optional heavyweight Plug for cpp dev. 
Plug 'vim-airline/vim-airline' 
Plug 'SirVer/ultisnips'
" Snippets are separated from the engine. Add this if you want them:
Plug 'honza/vim-snippets'
" Keep Plugin commands between vundle#begin/end.
" All of your Plugins must be added before the following line
call plug#end()
" ------------------------------END of vim-plug --------------------------
" Enable FZF, add to runtimepth
set rtp+=~/.fzf

filetype plugin indent on    " required

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" =>  Plugins Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"Vim Airline Configs
let g:airline#extensions#tabline#enabled = 1

"NERD Commenter configs
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCompactSexyComs = 1
let g:NERDSpaceDelims = 1

"YOU_COMPLETE_ME Configs
" let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
" let g:ycm_show_diagnostics_ui = 0
" let g:ycm_error_symbol = 'X'
" let g:ycm_warning_symbol = '!'
" let g:ycm_collect_identifiers_from_tags_files = 1

"LeaderF configs
let g:Lf_ShortcutF = '<C-P>'
let g:Lf_RootMarkers = ['.project','.root','.git','.svn']
let g:Lf_CacheDirectory =expand('~/.vim/cache')
let g:Lf_ShowDevIcons = 0
nnoremap <S-P> :LeaderfFunction<CR>
nnoremap <S-T> :LeaderfBuffer<CR>

""""""""""Ack.vim configs""""""""""""
if executable('rg')
  let g:ackprg = 'rg --vimgrep --type-not sql --smart-case' 
endif
"Empty ack search searches for <cword>
let g:ack_use_cword_for_empty_search = 1
"Do not jump to 1st match
cnoreabbrev Ack Ack!
"Maps <leader>/ 

""""""""AsyncRun configs""""""""
let g:asyncrun_open = 6
let g:asyncrun_bell = 1 
let g:asyncrun_rootmarks = ['.svn','.git','.root','Makefile']
nnoremap <F6> :call asyncrun#quickfix_toggle(6)<CR>
augroup asyncrun
  autocmd!
  autocmd FileType sh nnoremap <buffer> <silent> <F5>  :AsyncRun bash "$(VIM_FILEPATH)" <CR>
  autocmd FileType go nnoremap <buffer> <silent> <S-C-B>  :AsyncRun go build "$(VIM_FILEDIR)" <CR>
  autocmd FileType cpp  nnoremap <buffer> <silent> <S-C-B> :AsyncRun g++ -g -Wall -std=c++11 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <CR>
  autocmd FileType python nnoremap <buffer> <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR)  python3 "$(VIM_FILEPATH)" <cr>
  autocmd FileType cpp  nnoremap <buffer> <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <CR>
augroup END

"GitGutter Configs
"You can jump between hunks with [c and ]c. You can preview, stage, and undo hunks with <leader>hp, <leader>hs, and <leader>hu respectively.
"  nnoremap <Leader>ha <Plug>GitGutterStageHunk

" "GutenTags configs
let g:gutentags_project_root = ['.root','.svn','.git','.project']
let g:gutentags_ctags_tagfile = '.tags'
let s:vim_tags =expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags
"

" detect ~/.cache/tags create if not exist
if !isdirectory(s:vim_tags)
    silent! call mkdir(s:vim_tags, 'p')
endif

"
"ALE configs
let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_sign_error = 'X'
let g:ale_sign_warning = '!'
let g:ale_echo_msg_error_str='E'
let g:ale_sign_column_always = 0
let g:ale_echo_msg_warning_str='W'
let g:ale_echo_msg_format='[%linter%] %s [%severity%]'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:ale_cpp_clangcheck_options='-- -Wall -std=c++11 -x c++'
let g:ale_cpp_gcc_options ='-Wall -std=c++11'
let g:airline#extensions#ale#enabled = 1
hi! clear SpellBad
hi! clear SpellCap
hi! clear SpellRare
hi SpellBad cterm=undercurl ctermfg=red 
hi SpellCap cterm=undercurl ctermfg=blue
hi SpellRare cterm=undercurl ctermfg=magenta

"
"Autoformat configuration
noremap <F3> :Autoformat<CR>
autocmd BufWrite *.h,*.cc,*cpp,*.py :Autoformat
"Papercolor theme conifg
" let g:PaperColor_Theme_Options = {
"   \   'language': {
"   \     'python': {
"   \       'highlight_builtins' : 1
"   \     },
"   \     'cpp': {
"   \       'highlight_standard_library': 1
"   \     },
"   \     'c': {
"   \       'highlight_builtins' : 1
"   \     }
"   \   }
"   \ }


" UltiSnip Confgis """"""""""""""""""""""""""""""""""""""""""""
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-k>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=['~/.vim/UltiSnips','UltiSnips']


