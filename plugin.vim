" ---------------- USE vim-plug for plugins -----------------------
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

" Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
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
"----------------------------------------------- PLUGIN CONFIGURATIONS ---------------------------------------------------------


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

