" Vim filetype plugin file
"
"   Language :  bash
"     Plugin :  bash-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
"    Version :  2.10
"   Revision :  $Id: sh.vim,v 1.21 2009/01/30 14:23:10 mehner Exp $
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
" ---------- Do we have a mapleader other than '\' ? ------------
"
if exists("g:BASH_MapLeader")
	let maplocalleader	= g:BASH_MapLeader
endif    
"
let	s:MSWIN =		has("win16") || has("win32") || has("win64") || has("win95")
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
if has("gui_running")
	"
	 map  <buffer>  <silent>  <S-F1>        :call BASH_HelpBASHsupport()<CR>
	imap  <buffer>  <silent>  <S-F1>   <C-C>:call BASH_HelpBASHsupport()<CR>
	"
	 map  <buffer>  <silent>  <A-F9>        :call BASH_SyntaxCheck()<CR><CR>
	imap  <buffer>  <silent>  <A-F9>   <C-C>:call BASH_SyntaxCheck()<CR><CR>
	"
	 map  <buffer>  <silent>  <C-F9>        :call BASH_Run("n")<CR>
	imap  <buffer>  <silent>  <C-F9>   <C-C>:call BASH_Run("n")<CR>
	if !s:MSWIN
		vmap  <buffer>  <silent>  <C-F9>   <C-C>:call BASH_Run("v")<CR>
	endif
	"
	map   <buffer>  <silent>  <S-F9>        :call BASH_CmdLineArguments()<CR>
	imap  <buffer>  <silent>  <S-F9>   <C-C>:call BASH_CmdLineArguments()<CR>
endif
"
if !s:MSWIN
	 map  <buffer>  <silent>    <F9>        :call BASH_Debugger()<CR>:redraw!<CR>
	imap  <buffer>  <silent>    <F9>   <C-C>:call BASH_Debugger()<CR>:redraw!<CR>
endif
"
"
" ---------- help ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>hh            :call BASH_help('h')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hh       <Esc>:call BASH_help('h')<CR>
"
 noremap  <buffer>  <silent>  <LocalLeader>hm            :call BASH_help('m')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hm       <Esc>:call BASH_help('m')<CR>
"
 noremap  <buffer>  <silent>  <LocalLeader>hp           :call BASH_HelpBASHsupport()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>hp      <Esc>:call BASH_HelpBASHsupport()<CR>
"
" ---------- comment menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>cl           :call BASH_LineEndComment()<CR>A
inoremap  <buffer>  <silent>  <LocalLeader>cl      <Esc>:call BASH_LineEndComment()<CR>A
vnoremap  <buffer>  <silent>  <LocalLeader>cl      <Esc>:call BASH_MultiLineEndComments()<CR>A

 noremap  <buffer>  <silent>  <LocalLeader>cj           :call BASH_AdjustLineEndComm("a")<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cj      <Esc>:call BASH_AdjustLineEndComm("a")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>cj      <Esc>:call BASH_AdjustLineEndComm("v")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>cs           :call BASH_GetLineEndCommCol()<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cs      <Esc>:call BASH_GetLineEndCommCol()<CR>

 noremap  <buffer>  <silent>  <LocalLeader>cfr          :call BASH_CommentTemplates('frame')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cfr     <Esc>:call BASH_CommentTemplates('frame')<CR>

 noremap  <buffer>  <silent>  <LocalLeader>cfu          :call BASH_CommentTemplates('function')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cfu     <Esc>:call BASH_CommentTemplates('function')<CR>

 noremap  <buffer>  <silent>  <LocalLeader>ch           :call BASH_CommentTemplates('header')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>ch      <Esc>:call BASH_CommentTemplates('header')<CR>

 noremap    <buffer>  <silent>  <LocalLeader>cc         :call BASH_CommentToggle()<CR>j
inoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:call BASH_CommentToggle()<CR>j
vnoremap    <buffer>  <silent>  <LocalLeader>cc    <Esc>:'<,'>call BASH_CommentToggle()<CR>j

 noremap  <buffer>  <silent>  <LocalLeader>cd      a<C-R>=BASH_InsertDateAndTime('d')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>cd       <C-R>=BASH_InsertDateAndTime('d')<CR>

 noremap  <buffer>  <silent>  <LocalLeader>ct      a<C-R>=BASH_InsertDateAndTime('dt')<CR>
inoremap  <buffer>  <silent>  <LocalLeader>ct       <C-R>=BASH_InsertDateAndTime('dt')<CR>

 noremap  <buffer>  <silent>  <LocalLeader>ckb     $:call BASH_CommentClassified("BUG")     <CR>kJA
 noremap  <buffer>  <silent>  <LocalLeader>ckt     $:call BASH_CommentClassified("TODO")    <CR>kJA
 noremap  <buffer>  <silent>  <LocalLeader>ckr     $:call BASH_CommentClassified("TRICKY")  <CR>kJA
 noremap  <buffer>  <silent>  <LocalLeader>ckw     $:call BASH_CommentClassified("WARNING") <CR>kJA
 noremap  <buffer>  <silent>  <LocalLeader>ckn     $:call BASH_CommentClassified("")        <CR>kJf:a
 noremap  <buffer>  <silent>  <LocalLeader>ce      ^iecho<Space>"<End>"<Esc>j'
 noremap  <buffer>  <silent>  <LocalLeader>cr      0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR>j'
 noremap  <buffer>  <silent>  <LocalLeader>cv      :call BASH_CommentVimModeline()<CR>

inoremap  <buffer>  <silent>  <LocalLeader>ckb     <C-C>$:call BASH_CommentClassified("BUG")     <CR>kJA
inoremap  <buffer>  <silent>  <LocalLeader>ckt     <C-C>$:call BASH_CommentClassified("TODO")    <CR>kJA
inoremap  <buffer>  <silent>  <LocalLeader>ckr     <C-C>$:call BASH_CommentClassified("TRICKY")  <CR>kJA
inoremap  <buffer>  <silent>  <LocalLeader>ckw     <C-C>$:call BASH_CommentClassified("WARNING") <CR>kJA
inoremap  <buffer>  <silent>  <LocalLeader>ckn     <C-C>$:call BASH_CommentClassified("")        <CR>kJf:a
inoremap  <buffer>  <silent>  <LocalLeader>ce      <C-C>^iecho<Space>"<End>"<Esc>j'
inoremap  <buffer>  <silent>  <LocalLeader>cr      <C-C>0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR>j'
inoremap  <buffer>  <silent>  <LocalLeader>cv      <C-C>:call BASH_CommentVimModeline()<CR>
"
" ---------- statement menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>sc           ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
inoremap  <buffer>  <silent>  <LocalLeader>sc      <Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a

 noremap  <buffer>  <silent>  <LocalLeader>sl           :call BASH_FlowControl( "elif _ ",      "then",   "",       "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>sl      <Esc>:call BASH_FlowControl( "elif _ ",      "then",   "",       "a" )<CR>i

 noremap  <buffer>  <silent>  <LocalLeader>sf           :call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>sf      <Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <LocalLeader>sf      <Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sfo          :call BASH_FlowControl( "for (( COUNTER=0; COUNTER<_0; COUNTER++ ))",    "do",   "done",     "a" )<CR>
inoremap  <buffer>  <silent>  <LocalLeader>sfo     <Esc>:call BASH_FlowControl( "for (( COUNTER=0; COUNTER<_0; COUNTER++ ))",    "do",   "done",     "a" )<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>sfo     <Esc>:call BASH_FlowControl( "for (( COUNTER=0; COUNTER<_0; COUNTER++ ))",    "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>si           :call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>si      <Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i
vnoremap  <buffer>  <silent>  <LocalLeader>si      <Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sie          :call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>sie     <Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i
vnoremap  <buffer>  <silent>  <LocalLeader>sie     <Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>ss           :call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>ss      <Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <LocalLeader>ss      <Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>st           :call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>st      <Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <LocalLeader>st      <Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sw           :call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i
inoremap  <buffer>  <silent>  <LocalLeader>sw      <Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i
vnoremap  <buffer>  <silent>  <LocalLeader>sw      <Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "v" )<CR>

 noremap  <buffer>  <silent>  <LocalLeader>sfu          :call BASH_CodeFunction("a")<CR>O
inoremap  <buffer>  <silent>  <LocalLeader>sfu     <Esc>:call BASH_CodeFunction("a")<CR>O
vnoremap  <buffer>  <silent>  <LocalLeader>sfu     <Esc>:call BASH_CodeFunction("v")<CR>

 noremap  <buffer>  <silent>  <LocalLeader>se      ^iecho<Space>-e<Space>"\n"<Esc>2hi
inoremap  <buffer>  <silent>  <LocalLeader>se        echo<Space>-e<Space>"\n"<Esc>2hi
vnoremap  <buffer>  <silent>  <LocalLeader>se       secho<Space>-e<Space>"\n"<Esc>2hP

 noremap  <buffer>  <silent>  <LocalLeader>sp      ^iprintf<Space>"%s\n"<Esc>2hi
inoremap  <buffer>  <silent>  <LocalLeader>sp        printf<Space>"%s\n"<Esc>2hi
vnoremap  <buffer>  <silent>  <LocalLeader>sp       sprintf<Space>"%s\n"<Esc>2hP
"
" ---------- snippet menu ----------------------------------------------------
"
 noremap  <buffer>  <silent>  <LocalLeader>nr         :call BASH_CodeSnippets("r")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>nw         :call BASH_CodeSnippets("w")<CR>
vnoremap  <buffer>  <silent>  <LocalLeader>nw    <C-C>:call BASH_CodeSnippets("wv")<CR>
 noremap  <buffer>  <silent>  <LocalLeader>ne         :call BASH_CodeSnippets("e")<CR>
"
" ---------- run menu ----------------------------------------------------
"
if !s:MSWIN
   map  <buffer>  <silent>  <LocalLeader>re           :call BASH_MakeScriptExecutable()<CR>
  imap  <buffer>  <silent>  <LocalLeader>re      <Esc>:call BASH_MakeScriptExecutable()<CR>
endif

 map  <buffer>  <silent>  <LocalLeader>rr           :call BASH_Run("n")<CR>
imap  <buffer>  <silent>  <LocalLeader>rr      <Esc>:call BASH_Run("n")<CR>
 map  <buffer>  <silent>  <LocalLeader>ra           :call BASH_CmdLineArguments()<CR>
imap  <buffer>  <silent>  <LocalLeader>ra      <Esc>:call BASH_CmdLineArguments()<CR>

if !s:MSWIN
	 map  <buffer>  <silent>  <LocalLeader>rc           :call BASH_SyntaxCheck()<CR>
	imap  <buffer>  <silent>  <LocalLeader>rc      <Esc>:call BASH_SyntaxCheck()<CR>

	 map  <buffer>  <silent>  <LocalLeader>rd           :call BASH_Debugger()<CR>:redraw!<CR>
	imap  <buffer>  <silent>  <LocalLeader>rd      <Esc>:call BASH_Debugger()<CR>:redraw!<CR>

	vmap  <buffer>  <silent>  <LocalLeader>rr      <Esc>:call BASH_Run("v")<CR>

	if has("gui_running")
		 map  <buffer>  <silent>  <LocalLeader>rt           :call BASH_XtermSize()<CR>
		imap  <buffer>  <silent>  <LocalLeader>rt      <Esc>:call BASH_XtermSize()<CR>
	endif
endif

 map  <buffer>  <silent>  <LocalLeader>rh           :call BASH_Hardcopy("n")<CR>
imap  <buffer>  <silent>  <LocalLeader>rh      <Esc>:call BASH_Hardcopy("n")<CR>
vmap  <buffer>  <silent>  <LocalLeader>rh      <Esc>:call BASH_Hardcopy("v")<CR>
"
 map  <buffer>  <silent>  <LocalLeader>rs           :call BASH_Settings()<CR>
imap  <buffer>  <silent>  <LocalLeader>rs      <Esc>:call BASH_Settings()<CR>

if s:MSWIN
	 map  <buffer>  <silent>  <LocalLeader>ro           :call BASH_Toggle_Gvim_Xterm_MS()<CR>
	imap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm_MS()<CR>
else
	 map  <buffer>  <silent>  <LocalLeader>ro           :call BASH_Toggle_Gvim_Xterm()<CR>
	imap  <buffer>  <silent>  <LocalLeader>ro      <Esc>:call BASH_Toggle_Gvim_Xterm()<CR>
endif

"-------------------------------------------------------------------------------
" additional mapping : single quotes around a Word (non-whitespaces)
"                      masks the normal mode command '' (jump to the position
"                      before the latest jump)
" additional mapping : double quotes around a Word (non-whitespaces)
" additional mapping : parentheses around a word (word characters)
"-------------------------------------------------------------------------------
nnoremap		<buffer>	 ''		ciW''<Esc>P
nnoremap		<buffer>	 ""		ciW""<Esc>P
"nnoremap		<buffer>	 {{ 	ciw{}<Esc>PF{
