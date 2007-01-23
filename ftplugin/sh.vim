" Vim filetype plugin file
"
" Language   :  bash
" Plugin     :  bash-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Version    :  2.0
" Last Change:  01.01.2007
"
" -----------------------------------------------------------------
"
" Only do this when not done yet for this buffer
" 
if exists("b:did_BASH_ftplugin")
  finish
endif
let b:did_BASH_ftplugin = 1
"
" ---------- BASH dictionary -----------------------------------
"
" This will enable keyword completion for bash
" using Vim's dictionary feature |i_CTRL-X_CTRL-K|.
" 
if exists("g:BASH_Dictionary_File")
    silent! exec 'setlocal dictionary+='.g:BASH_Dictionary_File
endif    
"
" ---------- hot keys ------------------------------------------
"
"   Alt-F9   run syntax check
"  Ctrl-F9   update file and run script
" Shift-F9   command line arguments
"
 map  <buffer>  <silent>  <A-F9>        <Esc>:call BASH_SyntaxCheck()<CR><CR>
imap  <buffer>  <silent>  <A-F9>        <Esc>:call BASH_SyntaxCheck()<CR><CR>
"
" <C-C> seems to be essential here:
"
vmap  <buffer>  <silent>  <C-F9>        <C-C>:call BASH_Run("v")<CR>
nmap  <buffer>  <silent>  <C-F9>        <C-C>:call BASH_Run("n")<CR>
imap  <buffer>  <silent>  <C-F9>   <C-C><C-C>:call BASH_Run("n")<CR>
"
 map  <buffer>  <silent>  <S-F9>             :call BASH_CmdLineArguments()<CR>
imap  <buffer>  <silent>  <S-F9>        <Esc>:call BASH_CmdLineArguments()<CR>
  "
 map  <buffer>  <silent>    <F9>        <C-C>:call BASH_Debugger()<CR>:redraw!<CR>
imap  <buffer>  <silent>    <F9>   <C-C><C-C>:call BASH_Debugger()<CR>:redraw!<CR>
"
"
 map  <buffer>  <silent>  <S-F1>             :call BASH_help()<CR>
imap  <buffer>  <silent>  <S-F1>        <Esc>:call BASH_help()<CR>
"
" ---------- Key mappings  -------------------------------------
"
 map  <buffer>  <silent>  <Leader>h     	<Esc>:call BASH_help()<CR>
"
nmap  <buffer>  <silent>  <Leader>cl      <Esc><Esc>:call BASH_LineEndComment()<CR>A
vmap  <buffer>  <silent>  <Leader>cl      <Esc><Esc>:call BASH_MultiLineEndComments()<CR>A
nmap  <buffer>  <silent>  <Leader>cs      <Esc><Esc>:call BASH_GetLineEndCommCol()<CR>
nmap  <buffer>  <silent>  <Leader>cf      :call BASH_CommentTemplates('frame')<CR>
nmap  <buffer>  <silent>  <Leader>cu      :call BASH_CommentTemplates('function')<CR>
vmap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>

nmap  <buffer>  <silent>  <Leader>cc      <Esc><Esc>:s/^/\#/<CR><Esc>:nohlsearch<CR>j"
vmap  <buffer>  <silent>  <Leader>cc      <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>j"
nmap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>j"
nmap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:'<,'>s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>j"

nmap  <buffer>  <silent>  <Leader>cd      i<C-R>=strftime("%x")<CR>
nmap  <buffer>  <silent>  <Leader>ct      i<C-R>=strftime("%x %X %Z")<CR>
nmap  <buffer>  <silent>  <Leader>ckb     $<Esc>:call BASH_CommentClassified("BUG")     <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckt     $<Esc>:call BASH_CommentClassified("TODO")    <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckr     $<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckw     $<Esc>:call BASH_CommentClassified("WARNING") <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckn     $<Esc>:call BASH_CommentClassified("")        <CR>kJf:a
nnoremap  <buffer>  <silent>  <Leader>ce			<Esc><Esc>^iecho<Space>"<Esc>$a"<Esc>j'
nnoremap  <buffer>  <silent>  <Leader>cr      <Esc><Esc>0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR><Esc>j'
nmap  <buffer>  <silent>  <Leader>cv      :call BASH_CommentVimModeline()<CR>

nnoremap  <buffer>  <silent>  <Leader>ac      ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
nnoremap  <buffer>  <silent>  <Leader>al      oelif <CR>then<Esc>1kA

nnoremap  <buffer>  <silent>  <Leader>af      <Esc><Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
nnoremap  <buffer>  <silent>  <Leader>ai      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
nnoremap  <buffer>  <silent>  <Leader>ae      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
nnoremap  <buffer>  <silent>  <Leader>as      <Esc><Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
nnoremap  <buffer>  <silent>  <Leader>at      <Esc><Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
nnoremap  <buffer>  <silent>  <Leader>aw      <Esc><Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i

inoremap  <buffer>  <silent>  <Leader>af      <Esc><Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>ai      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>ae      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>as      <Esc><Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>at      <Esc><Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>aw      <Esc><Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i

vnoremap  <buffer>  <silent>  <Leader>af      <Esc><Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "v" )<CR>
vnoremap  <buffer>  <silent>  <Leader>ai      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "v" )<CR>
vnoremap  <buffer>  <silent>  <Leader>ae      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "v" )<CR>
vnoremap  <buffer>  <silent>  <Leader>as      <Esc><Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "v" )<CR>
vnoremap  <buffer>  <silent>  <Leader>at      <Esc><Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "v" )<CR>
vnoremap  <buffer>  <silent>  <Leader>aw      <Esc><Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "v" )<CR>

nmap  <buffer>  <silent>  <Leader>au			:call BASH_CodeFunction("a")<CR>O
vmap  <buffer>  <silent>  <Leader>au			<Esc><Esc>:call BASH_CodeFunction("v")<CR>

nnoremap  <buffer>  <silent>  <Leader>ao      ^iecho<Space>-e<Space>"\n"<Esc>2hi
vnoremap  <buffer>  <silent>  <Leader>ao      secho<Space>-e<Space>"\n"<Esc>2hP

if !has('win32')
	nmap  <buffer>  <silent>  <Leader>re      <Esc>:call BASH_MakeScriptExecutable()<CR>
endif
 map  <buffer>  <silent>  <Leader>rr      <Esc>:call BASH_Run("n")<CR>
vmap  <buffer>  <silent>  <Leader>rr      <Esc>:call BASH_Run("v")<CR>
 map  <buffer>  <silent>  <Leader>rc      <Esc>:call BASH_SyntaxCheck()<CR>
 map  <buffer>  <silent>  <Leader>ra      <Esc>:call BASH_CmdLineArguments()<CR>
 map  <buffer>  <silent>  <Leader>rd      <Esc>:call BASH_Debugger()<CR>:redraw!<CR>
 map  <buffer>  <silent>  <Leader>rs      <Esc>:call BASH_Settings()<CR>
if has("gui_running") && has("unix")
 map  <buffer>  <silent>  <Leader>rt      <Esc>:call BASH_XtermSize()<CR>
endif
 map  <buffer>  <silent>  <Leader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm()<CR>

 map  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("n")<CR>
vmap  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("v")<CR>
"
