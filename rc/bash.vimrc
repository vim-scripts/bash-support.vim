"
"-------------------------------------------------------------------------------
" bash-support.vim
"-------------------------------------------------------------------------------
"
let g:BASH_AuthorName      = ""
let g:BASH_AuthorRef       = ""
let g:BASH_Email           = ""
let g:BASH_Company         = ""
let g:BASH_Project         = ""
let g:BASH_CopyrightHolder = ""
"
let g:BASH_LoadMenus       = "yes"
"
" ----------  Insert header into new Bash files  ----------
if has("autocmd")
	autocmd BufNewFile  *.sh                 call BASH_CommentTemplates('header')
endif " has("autocmd")
"
"
