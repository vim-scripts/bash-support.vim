" Vim filetype plugin file
"
"   Language :  bash
"     Plugin :  bash-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"    Version :  2.2
"   Revision :  $Id: sh.vim,v 1.9 2007/11/18 11:12:31 mehner Exp $
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
" ---------- comment menu ----------------------------------------------------
"
nnoremap  <buffer>  <silent>  <Leader>cl      <Esc><Esc>:call BASH_LineEndComment()<CR>A
vnoremap  <buffer>  <silent>  <Leader>cl      <Esc><Esc>:call BASH_MultiLineEndComments()<CR>A
inoremap  <buffer>  <silent>  <Leader>cl      <Esc><Esc>:call BASH_MultiLineEndComments()<CR>A

nnoremap  <buffer>  <silent>  <Leader>cj      <Esc><Esc>:call BASH_AdjustLineEndComm("a")<CR>
vnoremap  <buffer>  <silent>  <Leader>cj      <Esc><Esc>:call BASH_AdjustLineEndComm("v")<CR>
inoremap  <buffer>  <silent>  <Leader>cj      <Esc><Esc>:call BASH_AdjustLineEndComm("a")<CR>

nnoremap  <buffer>  <silent>  <Leader>cs      <Esc><Esc>:call BASH_GetLineEndCommCol()<CR>

nnoremap  <buffer>  <silent>  <Leader>cfr               :call BASH_CommentTemplates('frame')<CR>
inoremap  <buffer>  <silent>  <Leader>cfr     <Esc><Esc>:call BASH_CommentTemplates('frame')<CR>

nnoremap  <buffer>  <silent>  <Leader>cfu               :call BASH_CommentTemplates('function')<CR>
inoremap  <buffer>  <silent>  <Leader>cfu     <Esc><Esc>:call BASH_CommentTemplates('function')<CR>

nnoremap  <buffer>  <silent>  <Leader>ch                :call BASH_CommentTemplates('header')<CR>
inoremap  <buffer>  <silent>  <Leader>ch      <Esc><Esc>:call BASH_CommentTemplates('header')<CR>

vnoremap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>

nnoremap  <buffer>  <silent>  <Leader>cc      <Esc><Esc>:s/^/\#/<CR><Esc>:nohlsearch<CR>j"
vnoremap  <buffer>  <silent>  <Leader>cc      <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>j"
nnoremap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>j"
nnoremap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:'<,'>s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>j"

nnoremap  <buffer>  <silent>  <Leader>cd      a<C-R>=BASH_InsertDateAndTime('d')<CR>
inoremap  <buffer>  <silent>  <Leader>cd       <C-R>=BASH_InsertDateAndTime('d')<CR>

nnoremap  <buffer>  <silent>  <Leader>ct      a<C-R>=BASH_InsertDateAndTime('dt')<CR>
inoremap  <buffer>  <silent>  <Leader>ct       <C-R>=BASH_InsertDateAndTime('dt')<CR>

nnoremap  <buffer>  <silent>  <Leader>ckb     $<Esc>:call BASH_CommentClassified("BUG")     <CR>kJA
nnoremap  <buffer>  <silent>  <Leader>ckt     $<Esc>:call BASH_CommentClassified("TODO")    <CR>kJA
nnoremap  <buffer>  <silent>  <Leader>ckr     $<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kJA
nnoremap  <buffer>  <silent>  <Leader>ckw     $<Esc>:call BASH_CommentClassified("WARNING") <CR>kJA
nnoremap  <buffer>  <silent>  <Leader>ckn     $<Esc>:call BASH_CommentClassified("")        <CR>kJf:a
nnoremap  <buffer>  <silent>  <Leader>ce			<Esc><Esc>^iecho<Space>"<Esc>$a"<Esc>j'
nnoremap  <buffer>  <silent>  <Leader>cr      <Esc><Esc>0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR><Esc>j'
nnoremap  <buffer>  <silent>  <Leader>cv      :call BASH_CommentVimModeline()<CR>
"
" ---------- statement menu ----------------------------------------------------
"
nnoremap  <buffer>  <silent>  <Leader>sc      ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
inoremap  <buffer>  <silent>  <Leader>sc      <Esc><Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a

nnoremap  <buffer>  <silent>  <Leader>sl      oelif <CR>then<Esc>1kA
inoremap  <buffer>  <silent>  <Leader>sl      <Esc><Esc>oelif <CR>then<Esc>1kA

nnoremap  <buffer>  <silent>  <Leader>sf      <Esc><Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>sf      <Esc><Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>sf      <Esc><Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "v" )<CR>

nnoremap  <buffer>  <silent>  <Leader>si      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>si      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>si      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "v" )<CR>

nnoremap  <buffer>  <silent>  <Leader>sie      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>sie      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>sie      <Esc><Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "v" )<CR>

nnoremap  <buffer>  <silent>  <Leader>ss      <Esc><Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>ss      <Esc><Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>ss      <Esc><Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "v" )<CR>

nnoremap  <buffer>  <silent>  <Leader>st      <Esc><Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>st      <Esc><Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>st      <Esc><Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "v" )<CR>

nnoremap  <buffer>  <silent>  <Leader>sw      <Esc><Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>sw      <Esc><Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>sw      <Esc><Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "v" )<CR>

nnoremap  <buffer>  <silent>  <Leader>sfu			:call BASH_CodeFunction("a")<CR>O
inoremap  <buffer>  <silent>  <Leader>sfu			<Esc><Esc>:call BASH_CodeFunction("a")<CR>O
vnoremap  <buffer>  <silent>  <Leader>sfu			<Esc><Esc>:call BASH_CodeFunction("v")<CR>

nnoremap  <buffer>  <silent>  <Leader>se      ^iecho<Space>-e<Space>"\n"<Esc>2hi
inoremap  <buffer>  <silent>  <Leader>se      echo<Space>-e<Space>"\n"<Esc>2hi
vnoremap  <buffer>  <silent>  <Leader>se      secho<Space>-e<Space>"\n"<Esc>2hP
"
" ---------- snippet menu ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>nr    <Esc>:call BASH_CodeSnippets("r")<CR>
 noremap    <buffer>  <silent>  <Leader>nw    <Esc>:call BASH_CodeSnippets("w")<CR>
vnoremap    <buffer>  <silent>  <Leader>nw    <Esc>:call BASH_CodeSnippets("wv")<CR>
 noremap    <buffer>  <silent>  <Leader>ne    <Esc>:call BASH_CodeSnippets("e")<CR>
"
" ---------- run menu ----------------------------------------------------
"
if !has('win32')
	nmap  <buffer>  <silent>  <Leader>re      <Esc>:call BASH_MakeScriptExecutable()<CR>
endif
nmap  <buffer>  <silent>  <Leader>rr      <Esc>:call BASH_Run("n")<CR>
vmap  <buffer>  <silent>  <Leader>rr      <Esc>:call BASH_Run("v")<CR>
 map  <buffer>  <silent>  <Leader>rc      <Esc>:call BASH_SyntaxCheck()<CR>
 map  <buffer>  <silent>  <Leader>ra      <Esc>:call BASH_CmdLineArguments()<CR>
 map  <buffer>  <silent>  <Leader>rd      <Esc>:call BASH_Debugger()<CR>:redraw!<CR>
 map  <buffer>  <silent>  <Leader>rs      <Esc>:call BASH_Settings()<CR>
if has("gui_running") && has("unix")
 map  <buffer>  <silent>  <Leader>rt      <Esc>:call BASH_XtermSize()<CR>
endif
 map  <buffer>  <silent>  <Leader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm()<CR>

nmap  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("n")<CR>
vmap  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("v")<CR>
"
