"
"===============================================================================
"==========  CUSTOMIZATION (vimrc)  ============================================
"===============================================================================
"
set autoread
set autowrite
set backupdir=$HOME/.vim.backupdir       " Don't forget to create this directory!
set browsedir=current                    " Which directory to use for the file browser
set incsearch
set nowrap
set shiftwidth=2
set tabstop=2
set visualbell
"
"
"-------------------------------------------------------------------------------
"  some additional hot keys
"-------------------------------------------------------------------------------
"
"     F2  -  write file without confirmation
"     F3  -  call file explorer Ex
"     F4  -  show tag under curser in the preview window
"     F6  -  list all errors           
"     F7  -  display previous error
"     F8  -  display next error   
"           
"  S-Tab  -  Fast switching between buffers (see below)
"    C-q  -  Leave the editor with Ctrl-q (see below)
"-------------------------------------------------------------------------------
"
map   <silent> <F2>    :write<CR>
map   <silent> <F3>    :Explore<CR>
nmap  <silent> <F4>    :exe ":ptag ".expand("<cword>")<CR>
map   <silent> <F6>    :copen<CR>
map   <silent> <F7>    :cp<CR>
map   <silent> <F8>    :cn<CR>
"
imap  <silent> <F2>    <Esc>:write<CR>
imap  <silent> <F3>    <Esc>:Explore<CR>
imap  <silent> <F4>    <Esc>:exe ":ptag ".expand("<cword>")<CR>
imap  <silent> <F6>    <Esc>:copen<CR>
imap  <silent> <F7>    <Esc>:cp<CR>
imap  <silent> <F8>    <Esc>:cn<CR>
"
"-------------------------------------------------------------------------------
" Fast switching between buffers
" The current buffer will be written before switching to the next one.
"-------------------------------------------------------------------------------
"
 map  <silent> <s-tab>       :if &modifiable && !&readonly && &modified <cr> :w<cr> :endif<cr> :bp<cr> 
imap  <silent> <s-tab>  <Esc>:if &modifiable && !&readonly && &modified <cr> :w<cr> :endif<cr> :bp<cr> 
"
"
"-------------------------------------------------------------------------------
" Leave the editor with Ctrl-q : Write all changed buffers and exit Vim
"-------------------------------------------------------------------------------
nmap	<C-q> 		:wqa<CR>
"
"
"-------------------------------------------------------------------------------
" use font with clearly distinguishable brackets : ()[]{}
"-------------------------------------------------------------------------------
" 
set guifont=-b&h-lucidatypewriter-medium-r-normal-*-*-140-*-*-m-*-iso10646-1
"
"
"-------------------------------------------------------------------------------
" Change to the directory the file in your current buffer is in
"-------------------------------------------------------------------------------
if has("autocmd")
	autocmd BufEnter * :lcd %:p:h
endif " has("autocmd")
"
"-------------------------------------------------------------------------------
" use of dictionaries
" 
" dictionary : List of file names that are used to lookup words
"              for keyword completion commands
"   complete : search the files defined by the 'dictionary' option
"-------------------------------------------------------------------------------
"
set dictionary=$HOME/.vim/wordlists/german.list
set complete+=k
"
"
"-------------------------------------------------------------------------------
" filename completion
" 
"   wildmenu : command-line completion operates in an enhanced 	mode
" wildignore : A file that matches with one of these
"              patterns is ignored when completing file or directory names.
"-------------------------------------------------------------------------------
" 
set wildmenu
set wildignore=*.bak,*.o,*.e,*~
"
"
"-------------------------------------------------------------------------------
" print options  (pc = percentage of the media size)
"-------------------------------------------------------------------------------
" 
set printoptions=left:8pc,right:3pc
"

highlight Cursor guibg=Blue guifg=NONE


"-------------------------------------------------------------------------------
" bash-support.vim
"-------------------------------------------------------------------------------

let g:BASH_AuthorName      = ""
let g:BASH_AuthorRef       = ""
let g:BASH_Email           = ""
let g:BASH_Company         = ""
let g:BASH_Project         = ""
let g:BASH_CopyrightHolder = ""

let g:BASH_Dictionary_File = $HOME."/.vim/wordlists/bash.list"

" ----------  Insert header into new Bash files  ----------
if has("autocmd")
	autocmd BufNewFile  *.sh                 call BASH_CommentTemplates('header')
endif " has("autocmd")





