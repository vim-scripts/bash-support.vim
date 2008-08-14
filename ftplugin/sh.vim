" Vim filetype plugin file
"
"   Language :  bash
"     Plugin :  bash-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"    Version :  2.6
"   Revision :  $Id: sh.vim,v 1.14 2008/08/02 15:50:12 mehner Exp $
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
 map  <buffer>  <silent>  <A-F9>        :call BASH_SyntaxCheck()<CR><CR>
imap  <buffer>  <silent>  <A-F9>   <C-C>:call BASH_SyntaxCheck()<CR><CR>
"
 map  <buffer>  <silent>  <C-F9>        :call BASH_Run("n")<CR>
vmap  <buffer>  <silent>  <C-F9>   <C-C>:call BASH_Run("v")<CR>
imap  <buffer>  <silent>  <C-F9>   <C-C>:call BASH_Run("n")<CR>
"
 map  <buffer>  <silent>  <S-F9>        :call BASH_CmdLineArguments()<CR>
imap  <buffer>  <silent>  <S-F9>   <C-C>:call BASH_CmdLineArguments()<CR>
  "
 map  <buffer>  <silent>    <F9>        :call BASH_Debugger()<CR>:redraw!<CR>
imap  <buffer>  <silent>    <F9>   <C-C>:call BASH_Debugger()<CR>:redraw!<CR>
"
"
 map  <buffer>  <silent>  <S-F1>        :call BASH_help()<CR>
imap  <buffer>  <silent>  <S-F1>   <C-C>:call BASH_help()<CR>
"
" ---------- Key mappings  -------------------------------------
"
 map  <buffer>  <silent>  <Leader>h     	     :call BASH_help()<CR>
imap  <buffer>  <silent>  <Leader>h     	<Esc>:call BASH_help()<CR>
"
" ---------- comment menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <Leader>cl           :call BASH_LineEndComment()<CR>A
inoremap  <buffer>  <silent>  <Leader>cl      <Esc>:call BASH_LineEndComment()<CR>A
vnoremap  <buffer>  <silent>  <Leader>cl      <Esc>:call BASH_MultiLineEndComments()<CR>A

 noremap  <buffer>  <silent>  <Leader>cj           :call BASH_AdjustLineEndComm("a")<CR>
inoremap  <buffer>  <silent>  <Leader>cj      <Esc>:call BASH_AdjustLineEndComm("a")<CR>
vnoremap  <buffer>  <silent>  <Leader>cj      <Esc>:call BASH_AdjustLineEndComm("v")<CR>

 noremap  <buffer>  <silent>  <Leader>cs           :call BASH_GetLineEndCommCol()<CR>
inoremap  <buffer>  <silent>  <Leader>cs      <Esc>:call BASH_GetLineEndCommCol()<CR>

 noremap  <buffer>  <silent>  <Leader>cfr          :call BASH_CommentTemplates('frame')<CR>
inoremap  <buffer>  <silent>  <Leader>cfr     <Esc>:call BASH_CommentTemplates('frame')<CR>

 noremap  <buffer>  <silent>  <Leader>cfu          :call BASH_CommentTemplates('function')<CR>
inoremap  <buffer>  <silent>  <Leader>cfu     <Esc>:call BASH_CommentTemplates('function')<CR>

 noremap  <buffer>  <silent>  <Leader>ch           :call BASH_CommentTemplates('header')<CR>
inoremap  <buffer>  <silent>  <Leader>ch      <Esc>:call BASH_CommentTemplates('header')<CR>

 noremap    <buffer>  <silent>  <Leader>cc         :call BASH_CommentToggle()<CR>j
inoremap    <buffer>  <silent>  <Leader>cc    <Esc>:call BASH_CommentToggle()<CR>j
vnoremap    <buffer>  <silent>  <Leader>cc    <Esc>:'<,'>call BASH_CommentToggle()<CR>j

 noremap  <buffer>  <silent>  <Leader>cd      a<C-R>=BASH_InsertDateAndTime('d')<CR>
inoremap  <buffer>  <silent>  <Leader>cd       <C-R>=BASH_InsertDateAndTime('d')<CR>

 noremap  <buffer>  <silent>  <Leader>ct      a<C-R>=BASH_InsertDateAndTime('dt')<CR>
inoremap  <buffer>  <silent>  <Leader>ct       <C-R>=BASH_InsertDateAndTime('dt')<CR>

 noremap  <buffer>  <silent>  <Leader>ckb     $:call BASH_CommentClassified("BUG")     <CR>kJA
 noremap  <buffer>  <silent>  <Leader>ckt     $:call BASH_CommentClassified("TODO")    <CR>kJA
 noremap  <buffer>  <silent>  <Leader>ckr     $:call BASH_CommentClassified("TRICKY")  <CR>kJA
 noremap  <buffer>  <silent>  <Leader>ckw     $:call BASH_CommentClassified("WARNING") <CR>kJA
 noremap  <buffer>  <silent>  <Leader>ckn     $:call BASH_CommentClassified("")        <CR>kJf:a
 noremap  <buffer>  <silent>  <Leader>ce			^iecho<Space>"<End>"<Esc>j'
 noremap  <buffer>  <silent>  <Leader>cr      0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR>j'
 noremap  <buffer>  <silent>  <Leader>cv      :call BASH_CommentVimModeline()<CR>

inoremap  <buffer>  <silent>  <Leader>ckb     <C-C>$:call BASH_CommentClassified("BUG")     <CR>kJA
inoremap  <buffer>  <silent>  <Leader>ckt     <C-C>$:call BASH_CommentClassified("TODO")    <CR>kJA
inoremap  <buffer>  <silent>  <Leader>ckr     <C-C>$:call BASH_CommentClassified("TRICKY")  <CR>kJA
inoremap  <buffer>  <silent>  <Leader>ckw     <C-C>$:call BASH_CommentClassified("WARNING") <CR>kJA
inoremap  <buffer>  <silent>  <Leader>ckn     <C-C>$:call BASH_CommentClassified("")        <CR>kJf:a
inoremap  <buffer>  <silent>  <Leader>ce			<C-C>^iecho<Space>"<End>"<Esc>j'
inoremap  <buffer>  <silent>  <Leader>cr      <C-C>0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR>j'
inoremap  <buffer>  <silent>  <Leader>cv      <C-C>:call BASH_CommentVimModeline()<CR>
"
" ---------- statement menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <Leader>sc           ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
inoremap  <buffer>  <silent>  <Leader>sc      <Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a

 noremap  <buffer>  <silent>  <Leader>sl           oelif <CR>then<Esc>1kA
inoremap  <buffer>  <silent>  <Leader>sl      <Esc>oelif <CR>then<Esc>1kA

 noremap  <buffer>  <silent>  <Leader>sf           :call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>sf      <Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>sf      <Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <Leader>si           :call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>si      <Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>si      <Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "v" )<CR>

 noremap  <buffer>  <silent>  <Leader>sie          :call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>sie     <Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>sie     <Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "v" )<CR>

 noremap  <buffer>  <silent>  <Leader>ss           :call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>ss      <Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>ss      <Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <Leader>st           :call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>st      <Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>st      <Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <Leader>sw           :call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <Leader>sw      <Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <Leader>sw      <Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <Leader>sfu			     :call BASH_CodeFunction("a")<CR>O
inoremap  <buffer>  <silent>  <Leader>sfu			<Esc>:call BASH_CodeFunction("a")<CR>O
vnoremap  <buffer>  <silent>  <Leader>sfu			<Esc>:call BASH_CodeFunction("v")<CR>

 noremap  <buffer>  <silent>  <Leader>se      ^iecho<Space>-e<Space>"\n"<Esc>2hi
inoremap  <buffer>  <silent>  <Leader>se        echo<Space>-e<Space>"\n"<Esc>2hi
vnoremap  <buffer>  <silent>  <Leader>se       secho<Space>-e<Space>"\n"<Esc>2hP

 noremap  <buffer>  <silent>  <Leader>sp      ^iprintf<Space>"\n"<Esc>2hi
inoremap  <buffer>  <silent>  <Leader>sp        printf<Space>"\n"<Esc>2hi
vnoremap  <buffer>  <silent>  <Leader>sp       sprintf<Space>"\n"<Esc>2hP
"
" ---------- snippet menu ----------------------------------------------------
"
 noremap    <buffer>  <silent>  <Leader>nr         :call BASH_CodeSnippets("r")<CR>
 noremap    <buffer>  <silent>  <Leader>nw         :call BASH_CodeSnippets("w")<CR>
vnoremap    <buffer>  <silent>  <Leader>nw    <C-C>:call BASH_CodeSnippets("wv")<CR>
 noremap    <buffer>  <silent>  <Leader>ne         :call BASH_CodeSnippets("e")<CR>
"
" ---------- run menu ----------------------------------------------------
"
if !has('win32')
	 map  <buffer>  <silent>  <Leader>re           :call BASH_MakeScriptExecutable()<CR>
	imap  <buffer>  <silent>  <Leader>re      <Esc>:call BASH_MakeScriptExecutable()<CR>
endif
 map  <buffer>  <silent>  <Leader>rr           :call BASH_Run("n")<CR>
 map  <buffer>  <silent>  <Leader>rc           :call BASH_SyntaxCheck()<CR>
 map  <buffer>  <silent>  <Leader>ra           :call BASH_CmdLineArguments()<CR>
 map  <buffer>  <silent>  <Leader>rd           :call BASH_Debugger()<CR>:redraw!<CR>
 map  <buffer>  <silent>  <Leader>rs           :call BASH_Settings()<CR>

imap  <buffer>  <silent>  <Leader>rr      <Esc>:call BASH_Run("n")<CR>
imap  <buffer>  <silent>  <Leader>rc      <Esc>:call BASH_SyntaxCheck()<CR>
imap  <buffer>  <silent>  <Leader>ra      <Esc>:call BASH_CmdLineArguments()<CR>
imap  <buffer>  <silent>  <Leader>rd      <Esc>:call BASH_Debugger()<CR>:redraw!<CR>
imap  <buffer>  <silent>  <Leader>rs      <Esc>:call BASH_Settings()<CR>

vmap  <buffer>  <silent>  <Leader>rr      <Esc>:call BASH_Run("v")<CR>

if has("gui_running") && has("unix")
	 map  <buffer>  <silent>  <Leader>rt           :call BASH_XtermSize()<CR>
	imap  <buffer>  <silent>  <Leader>rt      <Esc>:call BASH_XtermSize()<CR>
endif

 map  <buffer>  <silent>  <Leader>ro           :call BASH_Toggle_Gvim_Xterm()<CR>
imap  <buffer>  <silent>  <Leader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm()<CR>

 map  <buffer>  <silent>  <Leader>rh           :call BASH_Hardcopy("n")<CR>
imap  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("n")<CR>
vmap  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("v")<CR>
"
