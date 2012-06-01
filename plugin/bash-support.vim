"#################################################################################
"
"       Filename:  bash-support.vim
"
"    Description:  BASH support     (VIM Version 7.0+)
"
"                  Write BASH-scripts by inserting comments, statements, tests,
"                  variables and builtins.
"
"  Configuration:  There are some personal details which should be configured
"                    (see the files README.bashsupport and bashsupport.txt).
"
"   Dependencies:  The environmnent variables $HOME und $SHELL are used.
"
"   GVIM Version:  7.0+
"
"         Author:  Dr.-Ing. Fritz Mehner, FH Südwestfalen, 58644 Iserlohn, Germany
"          Email:  mehner@fh-swf.de
"
"        Version:  see variable  g:BASH_Version  below
"        Created:  26.02.2001
"        License:  Copyright (c) 2001-2012, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"       Revision:  $Id: bash-support.vim,v 1.115 2012/05/31 10:52:34 mehner Exp $
"
"------------------------------------------------------------------------------
"
" Prevent duplicate loading:
"
if exists("g:BASH_Version") || &cp
 finish
endif
let g:BASH_Version= "3.10"  						" version number of this script; do not change
"
if v:version < 700
  echohl WarningMsg | echo 'plugin bash-support.vim needs Vim version >= 7'| echohl None
endif
"
"#################################################################################
"
" Platform specific items:
"
"
let	s:MSWIN =		has("win16") || has("win32") || has("win64") || has("win95")
"
let s:installation						= '*undefined*'
let s:BASH_GlobalTemplateFile	= ''
let s:BASH_GlobalTemplateDir	= ''
"
if	s:MSWIN
  " ==========  MS Windows  ======================================================
	"
	" change '\' to '/' to avoid interpretation as escape character
	if match(	substitute( expand("<sfile>"), '\', '/', 'g' ),
				\		substitute( expand("$HOME"),   '\', '/', 'g' ) ) == 0
		" USER INSTALLATION ASSUMED
		let s:installation						= 'local'
		let s:plugin_dir  						= substitute( expand('<sfile>:p:h:h'), '\', '/', 'g' )
		let s:BASH_LocalTemplateFile	= s:plugin_dir.'/bash-support/templates/Templates'
		let s:BASH_LocalTemplateDir		= fnamemodify( s:BASH_LocalTemplateFile, ":p:h" ).'/'
	else
		" SYSTEM WIDE INSTALLATION
		let s:installation						= 'system'
		let s:plugin_dir  						= $VIM.'/vimfiles'
		let s:BASH_GlobalTemplateDir	= s:plugin_dir.'/bash-support/templates'
		let s:BASH_GlobalTemplateFile	= s:BASH_GlobalTemplateDir.'/Templates'
		let s:BASH_LocalTemplateFile	= $HOME.'/vimfiles/bash-support/templates/Templates'
		let s:BASH_LocalTemplateDir		= fnamemodify( s:BASH_LocalTemplateFile, ":p:h" ).'/'
	end
	"
	let s:BASH_BASH									= 'bash.exe'
	let s:BASH_Man        					= 'man.exe'
	let s:BASH_OutputGvim						= 'xterm'
else
  " ==========  Linux/Unix  ======================================================
	"
	if match( expand("<sfile>"), resolve( expand("$HOME") ) ) == 0
		" USER INSTALLATION ASSUMED
		let s:installation						= 'local'
		let s:plugin_dir  						= expand('<sfile>:p:h:h')
		let s:BASH_LocalTemplateFile	= s:plugin_dir.'/bash-support/templates/Templates'
		let s:BASH_LocalTemplateDir		= fnamemodify( s:BASH_LocalTemplateFile, ":p:h" ).'/'
	else
		" SYSTEM WIDE INSTALLATION
		let s:installation						= 'system'
		let s:plugin_dir  						= $VIM.'/vimfiles'
		let s:BASH_GlobalTemplateDir	= s:plugin_dir.'/bash-support/templates'
		let s:BASH_GlobalTemplateFile	= s:BASH_GlobalTemplateDir.'/Templates'
		let s:BASH_LocalTemplateFile	= $HOME.'/.vim/bash-support/templates/Templates'
		let s:BASH_LocalTemplateDir		= fnamemodify( s:BASH_LocalTemplateFile, ":p:h" ).'/'
	end
	"
	let s:BASH_BASH									= $SHELL
	let s:BASH_Man        					= 'man'
	let s:BASH_OutputGvim						= 'vim'
  " ==============================================================================
endif
"
"
"------------------------------------------------------------------------------
"
	let s:BASH_CodeSnippets  				= s:plugin_dir.'/bash-support/codesnippets/'
"
"  g:BASH_Dictionary_File  must be global
"
if !exists("g:BASH_Dictionary_File")
	let g:BASH_Dictionary_File     = s:plugin_dir.'/bash-support/wordlists/bash.list'
endif
"
"  Modul global variables    {{{1
"
let s:BASH_MenuHeader							= 'yes'
let s:BASH_Root										= 'B&ash.'
let s:BASH_Debugger               = 'term'
let s:BASH_bashdb                 = 'bashdb'
let s:BASH_LineEndCommColDefault  = 49
let s:BASH_LoadMenus              = 'yes'
let s:BASH_CreateMenusDelayed     = 'no'
let s:BASH_TemplateOverriddenMsg	= 'no'
let s:BASH_SyntaxCheckOptionsGlob = ''
"
let s:BASH_XtermDefaults          = '-fa courier -fs 12 -geometry 80x24'
let s:BASH_GuiSnippetBrowser      = 'gui'										" gui / commandline
let s:BASH_GuiTemplateBrowser     = 'gui'										" gui / explorer / commandline
let s:BASH_Printheader            = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:BASH_Wrapper                = s:plugin_dir.'/bash-support/scripts/wrapper.sh'
"
let s:BASH_Errorformat    			= '%f:\ %s\ %l:\ %m'
let s:BASH_FormatDate						= '%x'
let s:BASH_FormatTime						= '%X %Z'
let s:BASH_FormatYear						= '%Y'
"
let s:BASH_Ctrl_j								= 'on'
let s:BASH_TJT									= '[ 0-9a-zA-Z_]*'
let s:BASH_TemplateJumpTarget1  = '<+'.s:BASH_TJT.'+>\|{+'.s:BASH_TJT.'+}'
let s:BASH_TemplateJumpTarget2  = '<-'.s:BASH_TJT.'->\|{-'.s:BASH_TJT.'-}'
let s:BASH_FileFormat						= 'unix'
"
"------------------------------------------------------------------------------
"  Some variables for internal use only
"------------------------------------------------------------------------------
let s:BASH_Active         = -1                    " state variable controlling the Bash-menus
let s:BASH_SetCounter     = 0                     "
let s:BASH_Set_Txt        = "SetOptionNumber_"
let s:BASH_Shopt_Txt      = "ShoptOptionNumber_"
"
"------------------------------------------------------------------------------
"  Look for global variables (if any)    {{{1
"------------------------------------------------------------------------------
function! BASH_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  BASH_CheckGlobal  ----------
"
call BASH_CheckGlobal('BASH_BASH                  ')
call BASH_CheckGlobal('BASH_Errorformat           ')
call BASH_CheckGlobal('BASH_CodeSnippets          ')
call BASH_CheckGlobal('BASH_Ctrl_j                ')
call BASH_CheckGlobal('BASH_Debugger              ')
call BASH_CheckGlobal('BASH_bashdb                ')
call BASH_CheckGlobal('BASH_FileFormat            ')
call BASH_CheckGlobal('BASH_FormatDate            ')
call BASH_CheckGlobal('BASH_FormatTime            ')
call BASH_CheckGlobal('BASH_FormatYear            ')
call BASH_CheckGlobal('BASH_GuiSnippetBrowser     ')
call BASH_CheckGlobal('BASH_GuiTemplateBrowser    ')
call BASH_CheckGlobal('BASH_LineEndCommColDefault ')
call BASH_CheckGlobal('BASH_LoadMenus             ')
call BASH_CheckGlobal('BASH_CreateMenusDelayed    ')
call BASH_CheckGlobal('BASH_Man                   ')
call BASH_CheckGlobal('BASH_MenuHeader            ')
call BASH_CheckGlobal('BASH_OutputGvim            ')
call BASH_CheckGlobal('BASH_Printheader           ')
call BASH_CheckGlobal('BASH_Root                  ')
call BASH_CheckGlobal('BASH_SyntaxCheckOptionsGlob')
call BASH_CheckGlobal('BASH_TemplateOverriddenMsg ')
call BASH_CheckGlobal('BASH_XtermDefaults         ')
call BASH_CheckGlobal('BASH_GlobalTemplateFile    ')

if exists('g:BASH_GlobalTemplateFile') && !empty(g:BASH_GlobalTemplateFile)
	let s:BASH_GlobalTemplateDir	= fnamemodify( s:BASH_GlobalTemplateFile, ":h" )
endif
"
" set default geometry if not specified
"
if match( s:BASH_XtermDefaults, "-geometry\\s\\+\\d\\+x\\d\\+" ) < 0
	let s:BASH_XtermDefaults	= s:BASH_XtermDefaults." -geometry 80x24"
endif
"
" escape the printheader
"
let s:BASH_Printheader  = escape( s:BASH_Printheader, ' %' )
"
"------------------------------------------------------------------------------
"  Control variables (not user configurable)
"------------------------------------------------------------------------------
let s:Attribute                = { 'below':'', 'above':'', 'start':'', 'append':'', 'insert':'' }
let s:BASH_Attribute           = {}
let s:BASH_ExpansionLimit      = 10
let s:BASH_FileVisited         = []
"
let s:BASH_MacroNameRegex        = '\([a-zA-Z][a-zA-Z0-9_]*\)'
let s:BASH_MacroLineRegex				 = '^\s*|'.s:BASH_MacroNameRegex.'|\s*=\s*\(.*\)'
let s:BASH_MacroCommentRegex		 = '^§'
let s:BASH_ExpansionRegex				 = '|?'.s:BASH_MacroNameRegex.'\(:\a\)\?|'
let s:BASH_NonExpansionRegex		 = '|'.s:BASH_MacroNameRegex.'\(:\a\)\?|'
"
let s:BASH_TemplateNameDelimiter = '-+_,\. '
let s:BASH_TemplateLineRegex		 = '^==\s*\([a-zA-Z][0-9a-zA-Z'.s:BASH_TemplateNameDelimiter
let s:BASH_TemplateLineRegex		.= ']\+\)\s*==\s*\([a-z]\+\s*==\)\?'
let s:BASH_TemplateIf						 = '^==\s*IF\s\+|STYLE|\s\+IS\s\+'.s:BASH_MacroNameRegex.'\s*=='
let s:BASH_TemplateEndif				 = '^==\s*ENDIF\s*=='
"
let s:BASH_ExpansionCounter     = {}
let s:BASH_TJT									= '[ 0-9a-zA-Z_]*'
let s:BASH_TemplateJumpTarget1  = '<+'.s:BASH_TJT.'+>\|{+'.s:BASH_TJT.'+}'
let s:BASH_TemplateJumpTarget2  = '<-'.s:BASH_TJT.'->\|{-'.s:BASH_TJT.'-}'
let s:BASH_Macro                = {'|AUTHOR|'         : 'first name surname',
											\						 '|AUTHORREF|'      : '',
											\						 '|COMPANY|'        : '',
											\						 '|COPYRIGHTHOLDER|': '',
											\						 '|EMAIL|'          : '',
											\						 '|LICENSE|'        : 'GNU General Public License',
											\						 '|ORGANIZATION|'   : '',
											\						 '|PROJECT|'        : '',
											\		 				 '|STYLE|'          : ''
											\						}
let	s:BASH_MacroFlag						= {	':l' : 'lowercase'			,
											\							':u' : 'uppercase'			,
											\							':c' : 'capitalize'		,
											\							':L' : 'legalize name'	,
											\						}
let s:BASH_ActualStyle					= 'default'
let s:BASH_ActualStyleLast			= s:BASH_ActualStyle
let s:BASH_Template             = { 'default' : {} }
let s:BASH_TemplatesLoaded			= 'no'

let s:MsgInsNotAvail	= "insertion not available for a fold"
let s:BASH_saved_option					= {}
"
"------------------------------------------------------------------------------
"  BASH Menu Initialization      {{{1
"------------------------------------------------------------------------------
function!	BASH_InitMenu ()
	"
	"===============================================================================================
	"----- menu Main menu entry -------------------------------------------   {{{2
	"===============================================================================================
	"
	"-------------------------------------------------------------------------------
	"----- Menu : root menu  ---------------------------------------------------------------------
	"-------------------------------------------------------------------------------
	if s:BASH_MenuHeader == "yes"
		call BASH_InitMenuHeader()
	endif
	"
	"-------------------------------------------------------------------------------
	"----- menu Comments   {{{2
	"-------------------------------------------------------------------------------
	exe " menu           ".s:BASH_Root.'&Comments.end-of-&line\ comment<Tab>\\cl                    :call BASH_EndOfLineComment()<CR>'
	exe "imenu           ".s:BASH_Root.'&Comments.end-of-&line\ comment<Tab>\\cl               <Esc>:call BASH_EndOfLineComment()<CR>'
	exe "vmenu <silent>  ".s:BASH_Root.'&Comments.end-of-&line\ comment<Tab>\\cl               <Esc>:call BASH_MultiLineEndComments()<CR>A'

	exe " menu <silent>  ".s:BASH_Root.'&Comments.ad&just\ end-of-line\ com\.<Tab>\\cj              :call BASH_AdjustLineEndComm()<CR>'
	exe "imenu <silent>  ".s:BASH_Root.'&Comments.ad&just\ end-of-line\ com\.<Tab>\\cj         <Esc>:call BASH_AdjustLineEndComm()<CR>'
	exe "vmenu <silent>  ".s:BASH_Root.'&Comments.ad&just\ end-of-line\ com\.<Tab>\\cj              :call BASH_AdjustLineEndComm()<CR>'

	exe " menu <silent>  ".s:BASH_Root.'&Comments.&set\ end-of-line\ com\.\ col\.<Tab>\\cs          :call BASH_GetLineEndCommCol()<CR>'
	exe "imenu <silent>  ".s:BASH_Root.'&Comments.&set\ end-of-line\ com\.\ col\.<Tab>\\cs     <Esc>:call BASH_GetLineEndCommCol()<CR>'

	exe " menu <silent>  ".s:BASH_Root.'&Comments.&frame\ comment<Tab>\\cfr                         :call BASH_InsertTemplate("comment.frame")<CR>'
	exe "imenu <silent>  ".s:BASH_Root.'&Comments.&frame\ comment<Tab>\\cfr                    <Esc>:call BASH_InsertTemplate("comment.frame")<CR>'
	exe " menu <silent>  ".s:BASH_Root.'&Comments.f&unction\ description<Tab>\\cfu                  :call BASH_InsertTemplate("comment.function")<CR>'
	exe "imenu <silent>  ".s:BASH_Root.'&Comments.f&unction\ description<Tab>\\cfu             <Esc>:call BASH_InsertTemplate("comment.function")<CR>'
	exe " menu <silent>  ".s:BASH_Root.'&Comments.file\ &header<Tab>\\ch                            :call BASH_InsertTemplate("comment.file-description")<CR>'
	exe "imenu <silent>  ".s:BASH_Root.'&Comments.file\ &header<Tab>\\ch                       <Esc>:call BASH_InsertTemplate("comment.file-description")<CR>'

	exe "amenu ".s:BASH_Root.'&Comments.-Sep1-                    :'
	exe " menu <silent>  ".s:BASH_Root."&Comments.toggle\\ &comment<Tab>\\\\cc        :call BASH_CommentToggle()<CR>j"
	exe "imenu <silent>  ".s:BASH_Root."&Comments.toggle\\ &comment<Tab>\\\\cc   <Esc>:call BASH_CommentToggle()<CR>j"
	exe "vmenu <silent>  ".s:BASH_Root."&Comments.toggle\\ &comment<Tab>\\\\cc        :call BASH_CommentToggle()<CR>j"
	exe "amenu ".s:BASH_Root.'&Comments.-SEP2-                    :'

	exe " menu ".s:BASH_Root.'&Comments.&date<Tab>\\cd                       :call BASH_InsertDateAndTime("d")<CR>'
	exe "imenu ".s:BASH_Root.'&Comments.&date<Tab>\\cd                  <Esc>:call BASH_InsertDateAndTime("d")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.&date<Tab>\\cd                 s<Esc>:call BASH_InsertDateAndTime("d")<CR>'
	exe " menu ".s:BASH_Root.'&Comments.date\ &time<Tab>\\ct                 :call BASH_InsertDateAndTime("dt")<CR>'
	exe "imenu ".s:BASH_Root.'&Comments.date\ &time<Tab>\\ct            <Esc>:call BASH_InsertDateAndTime("dt")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.date\ &time<Tab>\\ct           s<Esc>:call BASH_InsertDateAndTime("dt")<CR>'
	"
	exe "amenu ".s:BASH_Root.'&Comments.-SEP3-                    :'
	"
	exe " noremenu ".s:BASH_Root.'&Comments.&echo\ "<line>"<Tab>\\ce       :call BASH_echo_comment()<CR>j'
	exe "inoremenu ".s:BASH_Root.'&Comments.&echo\ "<line>"<Tab>\\ce  <C-C>:call BASH_echo_comment()<CR>j'
	exe " noremenu ".s:BASH_Root.'&Comments.&remove\ echo<Tab>\\cr         :call BASH_remove_echo()<CR>j'
	exe "inoremenu ".s:BASH_Root.'&Comments.&remove\ echo<Tab>\\cr    <C-C>:call BASH_remove_echo()<CR>j'
	"
	exe "amenu ".s:BASH_Root.'&Comments.-SEP4-                    :'
	"
	"----- Submenu : BASH-Comments : Script Sections  ----------------------------------------------------------
	"
	if s:BASH_MenuHeader == "yes"
	exe "amenu ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.Comments-1<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.-Sep1-                :'
	endif
	"
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.GLOBALS            :call BASH_InsertTemplate("comment.file-sections-globals"   )<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.CMD\.LINE          :call BASH_InsertTemplate("comment.file-sections-cmdline"   )<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.SAN\.CHECKS        :call BASH_InsertTemplate("comment.file-sections-sanchecks" )<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.FUNCT\.DEF\.       :call BASH_InsertTemplate("comment.file-sections-functdef"  )<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.TRAPS              :call BASH_InsertTemplate("comment.file-sections-traps"     )<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.MAIN\ SCRIPT       :call BASH_InsertTemplate("comment.file-sections-mainscript")<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.STAT+CLEANUP       :call BASH_InsertTemplate("comment.file-sections-statistics")<CR>'
	"
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.GLOBALS       <C-C>:call BASH_InsertTemplate("comment.file-sections-globals"   )<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.CMD\.LINE     <C-C>:call BASH_InsertTemplate("comment.file-sections-cmdline"   )<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.SAN\.CHECKS   <C-C>:call BASH_InsertTemplate("comment.file-sections-sanchecks" )<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.FUNCT\.DEF\.  <C-C>:call BASH_InsertTemplate("comment.file-sections-functdef"  )<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.TRAPS         <C-C>:call BASH_InsertTemplate("comment.file-sections-traps"     )<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.MAIN\ SCRIPT  <C-C>:call BASH_InsertTemplate("comment.file-sections-mainscript")<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.&script\ sections<Tab>\\css.STAT+CLEANUP  <C-C>:call BASH_InsertTemplate("comment.file-sections-statistics")<CR>'
	"
	"----- Submenu : BASH-Comments : Keywords  ----------------------------------------------------------
	"
	if s:BASH_MenuHeader == "yes"
	exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.Comments-2<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.-Sep1-              :'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).Comments-3<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).-Sep1-               :'
	endif
	"
	exe " menu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&BUG<Tab>\\ckb                :call BASH_InsertTemplate("comment.keyword-bug")       <CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&TODO<Tab>\\ckt               :call BASH_InsertTemplate("comment.keyword-todo")      <CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.T&RICKY<Tab>\\ckr             :call BASH_InsertTemplate("comment.keyword-tricky")    <CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WARNING<Tab>\\ckw            :call BASH_InsertTemplate("comment.keyword-warning")   <CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WORKAROUND<Tab>\\cko         :call BASH_InsertTemplate("comment.keyword-workaround")<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&new\ keyword<Tab>\\ckn       :call BASH_InsertTemplate("comment.keyword-keyword")   <CR>'
	"
	exe "imenu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&BUG<Tab>\\ckb           <C-C>:call BASH_InsertTemplate("comment.keyword-bug")     <CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&TODO<Tab>\\ckt          <C-C>:call BASH_InsertTemplate("comment.keyword-todo")    <CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.T&RICKY<Tab>\\ckr        <C-C>:call BASH_InsertTemplate("comment.keyword-tricky")  <CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WARNING<Tab>\\ckw       <C-C>:call BASH_InsertTemplate("comment.keyword-warning") <CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&WORKAROUND<Tab>\\cko    <C-C>:call BASH_InsertTemplate("comment.keyword-workaround") <CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:<Tab>\\ckc.&new\ keyword<Tab>\\ckn  <C-C>:call BASH_InsertTemplate("comment.keyword-keyword")        <CR>'
	"
	"----- Submenu : BASH-Comments : Tags  ----------------------------------------------------------
	"
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR                :call BASH_InsertMacroValue("AUTHOR")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHORREF             :call BASH_InsertMacroValue("AUTHORREF")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY               :call BASH_InsertMacroValue("COMPANY")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COPYRIGHTHOLDER       :call BASH_InsertMacroValue("COPYRIGHTHOLDER")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL                 :call BASH_InsertMacroValue("EMAIL")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&LICENSE               :call BASH_InsertMacroValue("LICENSE")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&ORGANIZATION          :call BASH_InsertMacroValue("ORGANIZATION")<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT               :call BASH_InsertMacroValue("PROJECT")<CR>'

	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>:call BASH_InsertMacroValue("AUTHOR")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHORREF        <Esc>:call BASH_InsertMacroValue("AUTHORREF")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>:call BASH_InsertMacroValue("COMPANY")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COPYRIGHTHOLDER  <Esc>:call BASH_InsertMacroValue("COPYRIGHTHOLDER")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>:call BASH_InsertMacroValue("EMAIL")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&LICENSE          <Esc>:call BASH_InsertMacroValue("LICENSE")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&ORGANIZATION     <Esc>:call BASH_InsertMacroValue("ORGANIZATION")<CR>a'
	exe "imenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>:call BASH_InsertMacroValue("PROJECT")<CR>a'

	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR          s<Esc>:call BASH_InsertMacroValue("AUTHOR")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHORREF       s<Esc>:call BASH_InsertMacroValue("AUTHORREF")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY         s<Esc>:call BASH_InsertMacroValue("COMPANY")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COPYRIGHTHOLDER s<Esc>:call BASH_InsertMacroValue("COPYRIGHTHOLDER")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL           s<Esc>:call BASH_InsertMacroValue("EMAIL")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&LICENSE         s<Esc>:call BASH_InsertMacroValue("LICENSE")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&ORGANIZATION    s<Esc>:call BASH_InsertMacroValue("ORGANIZATION")<CR>a'
	exe "vmenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT         s<Esc>:call BASH_InsertMacroValue("PROJECT")<CR>a'

	exe " menu ".s:BASH_Root.'&Comments.&vim\ modeline<Tab>\\cv               :call BASH_CommentVimModeline()<CR>'
	exe "imenu ".s:BASH_Root.'&Comments.&vim\ modeline<Tab>\\cv          <Esc>:call BASH_CommentVimModeline()<CR>'
	"
	"-------------------------------------------------------------------------------
	"----- menu Statements   {{{2
	"-------------------------------------------------------------------------------

	exe "anoremenu ".s:BASH_Root.'&Statements.&case<Tab>\\sc	     				:call BASH_InsertTemplate("statements.case")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.e&lif<Tab>\\sei							:call BASH_InsertTemplate("statements.elif")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.&for\ in<Tab>\\sf						:call BASH_InsertTemplate("statements.for-in")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.&for\ ((\.\.\.))<Tab>\\sfo	:call BASH_InsertTemplate("statements.for")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.&if<Tab>\\si								:call BASH_InsertTemplate("statements.if")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.if-&else<Tab>\\sie					:call BASH_InsertTemplate("statements.if-else")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.&select<Tab>\\ss						:call BASH_InsertTemplate("statements.select")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.un&til<Tab>\\su							:call BASH_InsertTemplate("statements.until")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.&while<Tab>\\sw							:call BASH_InsertTemplate("statements.while")<CR>'

	exe "inoremenu ".s:BASH_Root.'&Statements.&case<Tab>\\sc	     				<Esc>:call BASH_InsertTemplate("statements.case")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.e&lif<Tab>\\sei							<Esc>:call BASH_InsertTemplate("statements.elif")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&for\ in<Tab>\\sf						<Esc>:call BASH_InsertTemplate("statements.for-in")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&for\ ((\.\.\.))<Tab>\\sfo	<Esc>:call BASH_InsertTemplate("statements.for")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&if<Tab>\\si								<Esc>:call BASH_InsertTemplate("statements.if")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.if-&else<Tab>\\sie					<Esc>:call BASH_InsertTemplate("statements.if-else")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&select<Tab>\\ss						<Esc>:call BASH_InsertTemplate("statements.select")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.un&til<Tab>\\su							<Esc>:call BASH_InsertTemplate("statements.until")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&while<Tab>\\sw							<Esc>:call BASH_InsertTemplate("statements.while")<CR>'

	exe "vnoremenu ".s:BASH_Root.'&Statements.&for\ in<Tab>\\sf						<Esc>:call BASH_InsertTemplate("statements.for-in", "v")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&for\ ((\.\.\.))<Tab>\\sfo	<Esc>:call BASH_InsertTemplate("statements.for", "v")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&if<Tab>\\si								<Esc>:call BASH_InsertTemplate("statements.if", "v")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.if-&else<Tab>\\sie					<Esc>:call BASH_InsertTemplate("statements.if-else", "v")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&select<Tab>\\ss						<Esc>:call BASH_InsertTemplate("statements.select", "v")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.un&til<Tab>\\su							<Esc>:call BASH_InsertTemplate("statements.until", "v")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&while<Tab>\\sw							<Esc>:call BASH_InsertTemplate("statements.while", "v")<CR>'
	"
	exe "anoremenu ".s:BASH_Root.'&Statements.-SEP3-          :'

	exe "anoremenu ".s:BASH_Root.'&Statements.&break										obreak '
	exe "anoremenu ".s:BASH_Root.'&Statements.co&ntinue									ocontinue '
	exe "anoremenu ".s:BASH_Root.'&Statements.e&xit											oexit '
	exe "anoremenu ".s:BASH_Root.'&Statements.f&unction<Tab>\\sfu 			:call BASH_InsertTemplate("statements.function")<CR>'
	exe "anoremenu ".s:BASH_Root.'&Statements.&return										oreturn '
	exe "anoremenu ".s:BASH_Root.'&Statements.s&hift										oshift '
	exe "anoremenu ".s:BASH_Root.'&Statements.&trap											otrap '
	"
	exe "inoremenu ".s:BASH_Root.'&Statements.&break								<Esc>obreak '
	exe "inoremenu ".s:BASH_Root.'&Statements.co&ntinue							<Esc>ocontinue '
	exe "inoremenu ".s:BASH_Root.'&Statements.e&xit									<Esc>oexit '
	exe "inoremenu ".s:BASH_Root.'&Statements.f&unction<Tab>\\sfu 			<Esc>:call BASH_InsertTemplate("statements.function")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.f&unction<Tab>\\sfu 			<Esc>:call BASH_InsertTemplate("statements.function", "v")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&return								<Esc>oreturn '
	exe "inoremenu ".s:BASH_Root.'&Statements.s&hift								<Esc>oshift '
	exe "inoremenu ".s:BASH_Root.'&Statements.&trap									<Esc>otrap '
	"
	"
	exe "anoremenu ".s:BASH_Root.'&Statements.-SEP1-          :'

	exe "anoremenu ".s:BASH_Root.'&Statements.&$(\.\.\.)			a$()<Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&$(\.\.\.)			 $()<Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&$(\.\.\.)			s$()<Esc>P'

	exe "anoremenu ".s:BASH_Root.'&Statements.$&{\.\.\.}			a${}<Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.$&{\.\.\.}			 ${}<Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.$&{\.\.\.}			s${}<Esc>P'
	"
	exe " noremenu ".s:BASH_Root.'&Statements.$&((\.\.\.))		a$(())<Esc>hi'
	exe "inoremenu ".s:BASH_Root.'&Statements.$&((\.\.\.))		 $(())<Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.$&((\.\.\.))		s$(())<Esc>hP'
	"
	exe "anoremenu ".s:BASH_Root.'&Statements.&printf\ \ "%s"<Tab>\\sp		     :call BASH_InsertTemplate("statements.printf")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&printf\ \ "%s"<Tab>\\sp		<Esc>:call BASH_InsertTemplate("statements.printf")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&printf\ \ "%s"<Tab>\\sp		<Esc>:call BASH_InsertTemplate("statements.printf", "v")<CR>'
	"
	exe "anoremenu ".s:BASH_Root.'&Statements.ech&o\ \ -e\ ""<Tab>\\se		     :call BASH_InsertTemplate("statements.echo")<CR>'
	exe "inoremenu ".s:BASH_Root.'&Statements.ech&o\ \ -e\ ""<Tab>\\se		<Esc>:call BASH_InsertTemplate("statements.echo")<CR>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.ech&o\ \ -e\ ""<Tab>\\se 	<Esc>:call BASH_InsertTemplate("statements.echo", "v")<CR>'
	"
	exe "amenu  ".s:BASH_Root.'&Statements.-SEP5-                                 :'
	exe "anoremenu ".s:BASH_Root.'&Statements.&array\ elem\.\ \ \ ${\.[\.]}<tab>\\sa\       a${[]}<Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&array\ elem\.\ \ \ ${\.[\.]}<tab>\\sa\        ${[]}<Left><Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&array\ elem\.\ \ \ ${\.[\.]}<tab>\\sa\       s${[]}<Left><Left><Esc>P'

	exe "anoremenu ".s:BASH_Root.'&Statements.&arr\.\ elem\.s\ (all)\ \ \ ${\.[@]}<tab>\\saa     	a${[@]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&arr\.\ elem\.s\ (all)\ \ \ ${\.[@]}<tab>\\saa     	 ${[@]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&arr\.\ elem\.s\ (all)\ \ \ ${\.[@]}<tab>\\saa     	s${[@]}<Left><Left><Left><Esc>P'

	exe "anoremenu ".s:BASH_Root.'&Statements.arr\.\ elem\.s\ (&1\ word)\ \ \ ${\.[*]}<tab>\\sa1 		a${[*]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.arr\.\ elem\.s\ (&1\ word)\ \ \ ${\.[*]}<tab>\\sa1 		 ${[*]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.arr\.\ elem\.s\ (&1\ word)\ \ \ ${\.[*]}<tab>\\sa1 		s${[*]}<Left><Left><Left><Esc>P'

	exe "anoremenu ".s:BASH_Root.'&Statements.&subarray\ \ \ ${\.[@]::}<tab>\\ssa     	a${[@]::}<Left><Left><Left><Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.&subarray\ \ \ ${\.[@]::}<tab>\\ssa     	 ${[@]::}<Left><Left><Left><Left><Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.&subarray\ \ \ ${\.[@]::}<tab>\\ssa     	s${[@]::}<Left><Left><Left><Left><Left><Esc>P'

	exe "anoremenu ".s:BASH_Root.'&Statements.no\.\ of\ ele&m\.s\ \ \ ${#\.[@]}<tab>\\san		a${#[@]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.no\.\ of\ ele&m\.s\ \ \ ${#\.[@]}<tab>\\san		 ${#[@]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.no\.\ of\ ele&m\.s\ \ \ ${#\.[@]}<tab>\\san		s${#[@]}<Left><Left><Left><Esc>P'

	exe "anoremenu ".s:BASH_Root.'&Statements.list\ of\ in&dices\ \ \ ${!\.[*]}<tab>\\sai   a${![*]}<Left><Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Statements.list\ of\ in&dices\ \ \ ${!\.[*]}<tab>\\sai    ${![*]}<Left><Left><Left><Left>'
	exe "vnoremenu ".s:BASH_Root.'&Statements.list\ of\ in&dices\ \ \ ${!\.[*]}<tab>\\sai   s${![*]}<Left><Left><Left><Esc>P'
	"
	if s:BASH_CodeSnippets != ""
		exe " menu  <silent> ".s:BASH_Root.'S&nippets.read\ code\ snippet<Tab>\\nr        :call BASH_CodeSnippets("r")<CR>'
		exe "imenu  <silent> ".s:BASH_Root.'S&nippets.read\ code\ snippet<Tab>\\nr   <C-C>:call BASH_CodeSnippets("r")<CR>'
		exe " menu  <silent> ".s:BASH_Root.'S&nippets.write\ code\ snippet<Tab>\\nw       :call BASH_CodeSnippets("w")<CR>'
		exe "imenu  <silent> ".s:BASH_Root.'S&nippets.write\ code\ snippet<Tab>\\nw  <C-C>:call BASH_CodeSnippets("w")<CR>'
		exe "vmenu  <silent> ".s:BASH_Root.'S&nippets.write\ code\ snippet<Tab>\\nw  <C-C>:call BASH_CodeSnippets("wv")<CR>'
		exe " menu  <silent> ".s:BASH_Root.'S&nippets.edit\ code\ snippet<Tab>\\ne        :call BASH_CodeSnippets("e")<CR>'
		exe "imenu  <silent> ".s:BASH_Root.'S&nippets.edit\ code\ snippet<Tab>\\ne   <C-C>:call BASH_CodeSnippets("e")<CR>'
		exe "amenu  <silent> ".s:BASH_Root.'S&nippets.-SEP6-                    		  :'
	endif
  "
  exe "amenu  <silent>  ".s:BASH_Root.'S&nippets.edit\ &local\ templates<Tab>\\ntl          :call BASH_BrowseTemplateFiles("Local")<CR>'
  exe "imenu  <silent>  ".s:BASH_Root.'S&nippets.edit\ &local\ templates<Tab>\\ntl     <C-C>:call BASH_BrowseTemplateFiles("Local")<CR>'
	if s:installation == 'system'
		exe "amenu  <silent>  ".s:BASH_Root.'S&nippets.edit\ &global\ templates<Tab>\\ntg         :call BASH_BrowseTemplateFiles("Global")<CR>'
		exe "imenu  <silent>  ".s:BASH_Root.'S&nippets.edit\ &global\ templates<Tab>\\ntg    <C-C>:call BASH_BrowseTemplateFiles("Global")<CR>'
	endif
  exe "amenu  <silent>  ".s:BASH_Root.'S&nippets.reread\ &templates<Tab>\\ntr               :call BASH_RereadTemplates("yes")<CR>'
  exe "imenu  <silent>  ".s:BASH_Root.'S&nippets.reread\ &templates <Tab>\\ntr         <C-C>:call BASH_RereadTemplates("yes")<CR>'
  exe "amenu            ".s:BASH_Root.'S&nippets.switch\ template\ st&yle<Tab>\\nts         :BashStyle<Space>'
  exe "imenu            ".s:BASH_Root.'S&nippets.switch\ template\ st&yle<Tab>\\nts    <C-C>:BashStyle<Space>'
	"
	"-------------------------------------------------------------------------------
	"----- menu Tests   {{{2
	"-------------------------------------------------------------------------------
	exe " noremenu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e															    					a[ -e  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		a[ -s  ]<Left><Left>'
	"
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e																						[ -e  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		[ -s  ]<Left><Left>'
	"
	exe "imenu ".s:BASH_Root.'&Tests.-Sep1-                         :'
	"
	"---------- submenu arithmetic tests -----------------------------------------------------------
	"
	exe " noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq									 a[  -eq  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne									 a[  -ne  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt											 a[  -lt  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le			 a[  -le  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt									 a[  -gt  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge		 a[  -ge  ]<Esc>F-hi'
	"
	exe "inoremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq										[  -eq  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne										[  -ne  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt												[  -lt  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le				[  -le  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt										[  -gt  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge			[  -ge  ]<Esc>F-hi'
	"
	"---------- submenu file exists and has permission ---------------------------------------------
	"
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r								 a[ -r  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w								 a[ -w  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x							 a[ -x  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u			 a[ -u  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g			 a[ -g  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k a[ -k  ]<Left><Left>'
	"
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r									[ -r  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w									[ -w  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x								[ -x  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u				[ -u  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g				[ -g  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k	[ -k  ]<Left><Left>'
	"
	"---------- submenu file exists and has type ----------------------------------------------------
	"
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a						<Esc>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			a[ -b  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	a[ -c  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								a[ -d  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>-p			a[ -p  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						a[ -f  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										a[ -S  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						a[ -L  ]<Left><Left>'
	"
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a			<Esc>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			 [ -b  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	 [ -c  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								 [ -d  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>p-			 [ -p  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						 [ -f  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										 [ -S  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						 [ -L  ]<Left><Left>'
	"
	"---------- submenu string comparison ------------------------------------------------------------
	"
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z									  a[ -z  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n								a[ -n  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal\ (1)<Tab>=															a[  =  ]<Esc>bhi'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ e&qual\ (2)<Tab>==														a[  ==  ]<Esc>bhi'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=												a[  !=  ]<Esc>bhi'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><	a[  <  ]<Esc>bhi'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>		a[  >  ]<Esc>bhi'
	exe " noremenu ".s:BASH_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												a[[  =~  ]]<Esc>2bhi'
	"
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z										 [ -z  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n								 [ -n  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal\ (1)<Tab>=															 [  =  ]<Esc>bhi'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ e&qual\ (2)<Tab>==														 [  ==  ]<Esc>bhi'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=												 [  !=  ]<Esc>bhi'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><	 [  <  ]<Esc>bhi'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>		 [  >  ]<Esc>bhi'
	exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												 [[  =~  ]]<Esc>2bhi'
	"
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O							 a[ -O  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G							 a[ -G  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N	 a[ -N  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t				 a[ -t  ]<Left><Left>'
	exe " noremenu ".s:BASH_Root.'&Tests.-Sep3-                         :'
	exe " noremenu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt								 a[  -nt  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																			 a[  -ot  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef		 a[  -ef  ]<Esc>F-hi'
	exe " noremenu ".s:BASH_Root.'&Tests.-Sep4-                         :'
	exe " noremenu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																 a[ -o  ]<Left><Left>'
	"
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O                [ -O  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G								[ -G  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N		[ -N  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t					[ -t  ]<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'&Tests.-Sep3-                         :'
	exe "inoremenu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt									[  -nt  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																				[  -ot  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef			[  -ef  ]<Esc>F-hi'
	exe "inoremenu ".s:BASH_Root.'&Tests.-Sep4-                         :'
	exe "inoremenu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																	[ -o  ]<Left><Left>'
	"
	"-------------------------------------------------------------------------------
	"----- menu Parameter Substitution   {{{2
	"-------------------------------------------------------------------------------

	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.&substitution\ <tab>${\ }                               :call BASH_InsertTemplate("paramsub.substitution")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.use\ &default\ value<tab>${\ :-\ }                      :call BASH_InsertTemplate("paramsub.use-default-value")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.&assign\ default\ value<tab>${\ :=\ }                   :call BASH_InsertTemplate("paramsub.assign-default-value")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.display\ &error\ if\ null\ or\ unset<tab>${\ :?\ }      :call BASH_InsertTemplate("paramsub.display-error")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.use\ alternate\ &value<tab>${\ :+\ }                    :call BASH_InsertTemplate("paramsub.use-alternate-value")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.&substring\ expansion<tab>${\ :\ :\ }                   :call BASH_InsertTemplate("paramsub.substring-expansion")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.list\ of\ var\.s\ &beginning\ with\ prefix<tab>${!\ *}  :call BASH_InsertTemplate("paramsub.names-matching-prefix")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.&indirect\ parameter\ expansion<tab>${!\ }               :call BASH_InsertTemplate("paramsub.indirect-parameter-expansion")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.-Sep1-           :'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.parameter\ &length\ in\ characters<Tab>${#\ }           :call BASH_InsertTemplate("paramsub.parameter-length")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.match\ beginning;\ del\.\ &shortest\ part<Tab>${\ #\ }  :call BASH_InsertTemplate("paramsub.remove-matching-prefix-pattern")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.match\ beginning;\ del\.\ &longest\ part<Tab>${\ ##\ }  :call BASH_InsertTemplate("paramsub.remove-all-matching-prefix-pattern")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.match\ end;\ delete\ s&hortest\ part<Tab>${\ %\ }       :call BASH_InsertTemplate("paramsub.remove-matching-suffix-pattern")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.match\ end;\ delete\ l&ongest\ part<Tab>${\ %%\ }       :call BASH_InsertTemplate("paramsub.remove-all-matching-suffix-pattern")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &first<Tab>${\ /\ /\ }                 :call BASH_InsertTemplate("paramsub.pattern-substitution")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &all<Tab>${\ //\ /\ }                  :call BASH_InsertTemplate("paramsub.pattern-substitution-all")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &begin<Tab>${\ /#\ /\ }                :call BASH_InsertTemplate("paramsub.pattern-substitution-begin")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &end<Tab>${\ /%\ /\ }                  :call BASH_InsertTemplate("paramsub.pattern-substitution-end")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.&lowercase\ to\ uppercase<Tab>${\ ^\ }                   :call BASH_InsertTemplate("paramsub.first-lower-to-upper")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.each\ l&owercase\ to\ uppercase<Tab>${\ ^^\ }            :call BASH_InsertTemplate("paramsub.all-lower-to-upper")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.&uppercase\ to\ lowercase<Tab>${\ ,\ }                   :call BASH_InsertTemplate("paramsub.first-upper-to-lower")<CR>'
	exe " noremenu <silent> ".s:BASH_Root.'&ParamSub.each\ u&ppercase\ to\ lowercase<Tab>${\ ,,\ }            :call BASH_InsertTemplate("paramsub.all-upper-to-lower")<CR>'

	exe "vnoremenu <silent> ".s:BASH_Root.'&ParamSub.s&ubstitution\ <tab>${\ }                               <C-C>:call BASH_InsertTemplate("paramsub.substitution", "v")<CR>'
	"
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.&substitution\ <tab>${\ }                               <C-C>:call BASH_InsertTemplate("paramsub.substitution")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.use\ &default\ value<tab>${\ :-\ }                      <C-C>:call BASH_InsertTemplate("paramsub.use-default-value")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.&assign\ default\ value<tab>${\ :=\ }                   <C-C>:call BASH_InsertTemplate("paramsub.assign-default-value")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.display\ &error\ if\ null\ or\ unset<tab>${\ :?\ }      <C-C>:call BASH_InsertTemplate("paramsub.display-error")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.use\ alternate\ &value<tab>${\ :+\ }                    <C-C>:call BASH_InsertTemplate("paramsub.use-alternate-value")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.&substring\ expansion<tab>${\ :\ :\ }                   <C-C>:call BASH_InsertTemplate("paramsub.substring-expansion")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.list\ of\ var\.s\ &beginning\ with\ prefix<tab>${!\ *}  <C-C>:call BASH_InsertTemplate("paramsub.names-matching-prefix")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.&indirect\ parameter\ expansion<tab>${!\ }               <C-C>:call BASH_InsertTemplate("paramsub.indirect-parameter-expansion")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.-Sep1-           :'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.parameter\ &length\ in\ characters<Tab>${#\ }           <C-C>:call BASH_InsertTemplate("paramsub.parameter-length")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.match\ beginning;\ del\.\ &shortest\ part<Tab>${\ #\ }  <C-C>:call BASH_InsertTemplate("paramsub.remove-matching-prefix-pattern")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.match\ beginning;\ del\.\ &longest\ part<Tab>${\ ##\ }  <C-C>:call BASH_InsertTemplate("paramsub.remove-all-matching-prefix-pattern")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.match\ end;\ delete\ s&hortest\ part<Tab>${\ %\ }       <C-C>:call BASH_InsertTemplate("paramsub.remove-matching-suffix-pattern")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.match\ end;\ delete\ l&ongest\ part<Tab>${\ %%\ }       <C-C>:call BASH_InsertTemplate("paramsub.remove-all-matching-suffix-pattern")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &first<Tab>${\ /\ /\ }                 <C-C>:call BASH_InsertTemplate("paramsub.pattern-substitution")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &all<Tab>${\ //\ /\ }                  <C-C>:call BASH_InsertTemplate("paramsub.pattern-substitution-all")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &begin<Tab>${\ /#\ /\ }                <C-C>:call BASH_InsertTemplate("paramsub.pattern-substitution-begin")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.substitute,\ match\ &end<Tab>${\ /%\ /\ }                  <C-C>:call BASH_InsertTemplate("paramsub.pattern-substitution-end")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.&lowercase\ to\ uppercase<Tab>${\ ^\ }                   <C-C>:call BASH_InsertTemplate("paramsub.first-lower-to-upper")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.each\ l&owercase\ to\ uppercase<Tab>${\ ^^\ }            <C-C>:call BASH_InsertTemplate("paramsub.all-lower-to-upper")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.&uppercase\ to\ lowercase<Tab>${\ ,\ }                   <C-C>:call BASH_InsertTemplate("paramsub.first-upper-to-lower")<CR>'
	exe "inoremenu <silent> ".s:BASH_Root.'&ParamSub.each\ u&ppercase\ to\ lowercase<Tab>${\ ,,\ }            <C-C>:call BASH_InsertTemplate("paramsub.all-upper-to-lower")<CR>'
	"-------------------------------------------------------------------------------
	"----- menu Special Variables   {{{2
	"-------------------------------------------------------------------------------

	exe " noremenu ".s:BASH_Root.'Spec&Vars.&number\ of\ posit\.\ param\.<tab>${#}							 a${#}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.&all\ posit\.\ param\.\ (quoted\ spaces)<tab>${*}		 a${*}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.all\ posit\.\ param\.\ (&unquoted\ spaces)<tab>${@}	 a${@}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.n&umber\ of\ posit\.\ parameters<tab>${#@}	         a${#@}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.&return\ code\ of\ last\ command<tab>${?}						 a${?}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.&PID\ of\ this\ shell<tab>${$}											 a${$}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.&flags\ set<tab>${-}																 a${-}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.&last\ argument\ of\ prev\.\ command<tab>${_}				 a${_}'
	exe " noremenu ".s:BASH_Root.'Spec&Vars.PID\ of\ last\ &background\ command<tab>${!}				 a${!}'
	"
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.&number\ of\ posit\.\ param\.<tab>${#}								${#}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.&all\ posit\.\ param\.\ (quoted\ spaces)<tab>${*}			${*}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.all\ posit\.\ param\.\ (&unquoted\ spaces)<tab>${@}		${@}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.n&umber\ of\ posit\.\ parameters<tab>${#@}	        	${#@}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.&return\ code\ of\ last\ command<tab>${?}							${?}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.&PID\ of\ this\ shell<tab>${$}												${$}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.&flags\ set<tab>${-}																	${-}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.&last\ argument\ of\ prev\.\ command<tab>${_}					${_}'
	exe "inoremenu ".s:BASH_Root.'Spec&Vars.PID\ of\ last\ &background\ command<tab>${!}					${!}'
	"
	"-------------------------------------------------------------------------------
	"----- menu Environment Variables   {{{2
	"-------------------------------------------------------------------------------
	"
	call BASH_EnvirMenus ( s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION', s:BashEnvironmentVariables[0:16] )
	"
	call BASH_EnvirMenus ( s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME', s:BashEnvironmentVariables[17:32] )
	"
	call BASH_EnvirMenus ( s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG', s:BashEnvironmentVariables[33:49] )
	"
	call BASH_EnvirMenus ( s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE', s:BashEnvironmentVariables[50:65] )
	"
	call BASH_EnvirMenus ( s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID', s:BashEnvironmentVariables[66:86] )
	"
	"-------------------------------------------------------------------------------
	"----- menu Builtins  a-l   {{{2
	"-------------------------------------------------------------------------------
	call BASH_BuiltinMenus ( s:BASH_Root.'&Builtins.Builtins\ \ &a-f', s:BashBuiltins[0:21] )
	call BASH_BuiltinMenus ( s:BASH_Root.'&Builtins.Builtins\ \ &g-r', s:BashBuiltins[22:41] )
	call BASH_BuiltinMenus ( s:BASH_Root.'&Builtins.Builtins\ \ &s-w', s:BashBuiltins[42:57] )
	"
	"
	"-------------------------------------------------------------------------------
	"----- menu set   {{{2
	"-------------------------------------------------------------------------------
	"
	exe "amenu ".s:BASH_Root.'s&et.&allexport<Tab>-a       oset -o allexport  '
	exe "amenu ".s:BASH_Root.'s&et.&braceexpand<Tab>-B     oset -o braceexpand'
	exe "amenu ".s:BASH_Root.'s&et.emac&s                  oset -o emacs      '
	exe "amenu ".s:BASH_Root.'s&et.&errexit<Tab>-e         oset -o errexit    '
	exe "amenu ".s:BASH_Root.'s&et.e&rrtrace<Tab>-E        oset -o errtrace   '
	exe "amenu ".s:BASH_Root.'s&et.func&trace<Tab>-T       oset -o functrace  '
	exe "amenu ".s:BASH_Root.'s&et.&hashall<Tab>-h         oset -o hashall    '
	exe "amenu ".s:BASH_Root.'s&et.histexpand\ (&1)<Tab>-H oset -o histexpand '
	exe "amenu ".s:BASH_Root.'s&et.hist&ory                oset -o history    '
	exe "amenu ".s:BASH_Root.'s&et.i&gnoreeof              oset -o ignoreeof  '
	exe "amenu ".s:BASH_Root.'s&et.&keyword<Tab>-k         oset -o keyword    '
	exe "amenu ".s:BASH_Root.'s&et.&monitor<Tab>-m         oset -o monitor    '
	exe "amenu ".s:BASH_Root.'s&et.no&clobber<Tab>-C       oset -o noclobber  '
	exe "amenu ".s:BASH_Root.'s&et.&noexec<Tab>-n          oset -o noexec     '
	exe "amenu ".s:BASH_Root.'s&et.nog&lob<Tab>-f          oset -o noglob     '
	exe "amenu ".s:BASH_Root.'s&et.notif&y<Tab>-b          oset -o notify     '
	exe "amenu ".s:BASH_Root.'s&et.no&unset<Tab>-u         oset -o nounset    '
	exe "amenu ".s:BASH_Root.'s&et.onecm&d<Tab>-t          oset -o onecmd     '
	exe "amenu ".s:BASH_Root.'s&et.physical\ (&2)<Tab>-P   oset -o physical   '
	exe "amenu ".s:BASH_Root.'s&et.pipe&fail               oset -o pipefail   '
	exe "amenu ".s:BASH_Root.'s&et.posix\ (&3)             oset -o posix      '
	exe "amenu ".s:BASH_Root.'s&et.&privileged<Tab>-p      oset -o privileged '
	exe "amenu ".s:BASH_Root.'s&et.&verbose<Tab>-v         oset -o verbose    '
	exe "amenu ".s:BASH_Root.'s&et.v&i                     oset -o vi         '
	exe "amenu ".s:BASH_Root.'s&et.&xtrace<Tab>-x          oset -o xtrace     '
	"
	exe "vmenu ".s:BASH_Root.'s&et.&allexport<Tab>-a       <Esc>:call BASH_set("allexport  ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&braceexpand<Tab>-B     <Esc>:call BASH_set("braceexpand")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.emac&s                  <Esc>:call BASH_set("emacs      ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&errexit<Tab>-e         <Esc>:call BASH_set("errexit    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.e&rrtrace<Tab>-E        <Esc>:call BASH_set("errtrace   ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.func&trace<Tab>-T       <Esc>:call BASH_set("functrace  ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&hashall<Tab>-h         <Esc>:call BASH_set("hashall    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.histexpand\ (&1)<Tab>-H <Esc>:call BASH_set("histexpand ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.hist&ory                <Esc>:call BASH_set("history    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.i&gnoreeof              <Esc>:call BASH_set("ignoreeof  ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&keyword<Tab>-k         <Esc>:call BASH_set("keyword    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&monitor<Tab>-m         <Esc>:call BASH_set("monitor    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.no&clobber<Tab>-C       <Esc>:call BASH_set("noclobber  ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&noexec<Tab>-n          <Esc>:call BASH_set("noexec     ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.nog&lob<Tab>-f          <Esc>:call BASH_set("noglob     ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.notif&y<Tab>-b          <Esc>:call BASH_set("notify     ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.no&unset<Tab>-u         <Esc>:call BASH_set("nounset    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.onecm&d<Tab>-t          <Esc>:call BASH_set("onecmd     ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.physical\ (&2)<Tab>-P   <Esc>:call BASH_set("physical   ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.pipe&fail               <Esc>:call BASH_set("pipefail   ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.posix\ (&3)             <Esc>:call BASH_set("posix      ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&privileged<Tab>-p      <Esc>:call BASH_set("privileged ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&verbose<Tab>-v         <Esc>:call BASH_set("verbose    ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.v&i                     <Esc>:call BASH_set("vi         ")<CR>'
	exe "vmenu ".s:BASH_Root.'s&et.&xtrace<Tab>-x          <Esc>:call BASH_set("xtrace     ")<CR>'
	"
	"-------------------------------------------------------------------------------
	"----- menu shopt   {{{2
	"-------------------------------------------------------------------------------
	call	BASH_ShoptMenus ( s:BASH_Root.'sh&opt.shopt\ \ &a-g', s:BashShopt[0:20] )
	call	BASH_ShoptMenus ( s:BASH_Root.'sh&opt.shopt\ \ &h-x', s:BashShopt[21:39] )
	"
	"------------------------------------------------------------------------------
	"----- menu Regex    {{{2
	"------------------------------------------------------------------------------
	"
	exe "anoremenu ".s:BASH_Root.'Rege&x.match\ \ \ [[\ =~\ ]]<Tab>\\xm      a[[  =~  ]]<Left><Left><Left><Left><Left><Left><Left>'
	exe "inoremenu ".s:BASH_Root.'Rege&x.match\ \ \ [[\ =~\ ]]<Tab>\\xm       [[  =~  ]]<Left><Left><Left><Left><Left><Left><Left>'
	exe "amenu     ".s:BASH_Root.'Rege&x.-Sep01-      :'
	"
	exe "anoremenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )      a*(\|)<Left><Left>'
	exe "anoremenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )     a+(\|)<Left><Left>'
	exe "anoremenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )   a?(\|)<Left><Left>'
	exe "anoremenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )    a@(\|)<Left><Left>'
	exe "anoremenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )     a!(\|)<Left><Left>'
	"
	exe "inoremenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )       *(\|)<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )      +(\|)<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )    ?(\|)<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )     @(\|)<Left><Left>'
	exe "inoremenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )      !(\|)<Left><Left>'
	"
	exe "vnoremenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )      s*(\|)<Esc>hPla'
	exe "vnoremenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )     s+(\|)<Esc>hPla'
	exe "vnoremenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )   s?(\|)<Esc>hPla'
	exe "vnoremenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )    s@(\|)<Esc>hPla'
	exe "vnoremenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )     s!(\|)<Esc>hPla'
	"
	exe "amenu ".s:BASH_Root.'Rege&x.-Sep1-      :'
  "
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&alnum:]<Tab>\\pan   a[:alnum:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:alp&ha:]<Tab>\\pal   a[:alpha:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:asc&ii:]<Tab>\\pas   a[:ascii:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&blank:]<Tab>\\pb   a[:blank:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&cntrl:]<Tab>\\pc   a[:cntrl:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&digit:]<Tab>\\pd   a[:digit:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&graph:]<Tab>\\pg   a[:graph:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&lower:]<Tab>\\pl   a[:lower:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&print:]<Tab>\\ppr  a[:print:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:pu&nct:]<Tab>\\ppu  a[:punct:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&space:]<Tab>\\ps   a[:space:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&upper:]<Tab>\\pu   a[:upper:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&word:]<Tab>\\pw    a[:word:]'
  exe "anoremenu ".s:BASH_Root.'Rege&x.[:&xdigit:]<Tab>\\px  a[:xdigit:]'
  "
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&alnum:]<Tab>\\pan   [:alnum:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:alp&ha:]<Tab>\\pal   [:alpha:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:asc&ii:]<Tab>\\pas   [:ascii:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&blank:]<Tab>\\pb    [:blank:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&cntrl:]<Tab>\\pc    [:cntrl:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&digit:]<Tab>\\pd    [:digit:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&graph:]<Tab>\\pg    [:graph:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&lower:]<Tab>\\pl    [:lower:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&print:]<Tab>\\ppr   [:print:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:pu&nct:]<Tab>\\ppu   [:punct:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&space:]<Tab>\\ps    [:space:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&upper:]<Tab>\\pu    [:upper:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&word:]<Tab>\\pw     [:word:]'
  exe "inoremenu ".s:BASH_Root.'Rege&x.[:&xdigit:]<Tab>\\px   [:xdigit:]'
	"
	exe "amenu ".s:BASH_Root.'Rege&x.-Sep2-      :'
	"
	exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&0]}         a${BASH_REMATCH[0]}'
	exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&1]}         a${BASH_REMATCH[1]}'
	exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&2]}         a${BASH_REMATCH[2]}'
	exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&3]}         a${BASH_REMATCH[3]}'
	"
	exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&0]}    <Esc>a${BASH_REMATCH[0]}'
	exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&1]}    <Esc>a${BASH_REMATCH[1]}'
	exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&2]}    <Esc>a${BASH_REMATCH[2]}'
	exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&3]}    <Esc>a${BASH_REMATCH[3]}'
	"
	"
	"-------------------------------------------------------------------------------
	"----- menu I/O redirection   {{{2
	"-------------------------------------------------------------------------------
	"
	exe " menu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file<Tab><												a<Space><<Space>'
	exe " menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file<Tab>>												a<Space>><Space>'
	exe " menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append<Tab>>>							a<Space>>><Space>'
	exe " menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ STDERR<Tab>>&2				      			a<Space>>&2'
	"
	exe " menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file<Tab>n>						a<Space>><Space><ESC>2hi'
	exe " menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file;\ append<Tab>n>> 	a<Space>>><Space><ESC>3hi'
	exe " menu ".s:BASH_Root.'&I/O-Redir.take\ file\ descr\.\ n\ from\ file<Tab>n< 						a<Space><<Space><ESC>2hi'
	"
	exe " menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.\ n<Tab>n>&			a<Space>>& <ESC>2hi'
	exe " menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.\ n<Tab>n<&			a<Space><& <ESC>2hi'
	exe " menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file<Tab>&>					a<Space>&> '
	"
	exe " menu ".s:BASH_Root.'&I/O-Redir.close\ STDIN<Tab><&-																	a<Space><&- '
	exe " menu ".s:BASH_Root.'&I/O-Redir.close\ STDOUT<Tab>>&-																a<Space>>&- '
	exe " menu ".s:BASH_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n<Tab>n<&-				a<Space><&- <ESC>3hi'
	exe " menu ".s:BASH_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n<Tab>n>&-				a<Space>>&- <ESC>3hi'
	exe " menu ".s:BASH_Root.'&I/O-Redir.append\ STDOUT\ and\ STDERR<Tab>&>>            			a<Space>&>> '
	"
	exe "imenu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file<Tab><												<Space><<Space>'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file<Tab>>												<Space>><Space>'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append<Tab>>>							<Space>>><Space>'
	"
	exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file<Tab>n>						<Space>><Space><ESC>2hi'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ n\ to\ file;\ append<Tab>n>> 	<Space>>><Space><ESC>3hi'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.take\ file\ descr\.\ n\ from\ file<Tab>n< 						<Space><<Space><ESC>2hi'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ STDERR<Tab>>&2				      			<Space>>&2'
	"
	exe "imenu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.\ n<Tab>n>&			<Space>>& <Left><Left><Left>'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.\ n<Tab>n<&			<Space><& <Left><Left><Left>'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file<Tab>&>					<Space>&> '
	"
	exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ STDIN<Tab><&-																	<Space><&- '
	exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ STDOUT<Tab>>&-																<Space>>&- '
	exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n<Tab>n<&-				<Space><&- <ESC>3hi'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n<Tab>n>&-				<Space>>&- <ESC>3hi'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.append\ STDOUT\ and\ STDERR<Tab>&>>            			<Space>&>> '
	"
	"
	exe " menu ".s:BASH_Root.'&I/O-Redir.here-document<Tab><<-label														a<<-EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
	exe "imenu ".s:BASH_Root.'&I/O-Redir.here-document<Tab><<-label														<<-EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
	exe "vmenu ".s:BASH_Root.'&I/O-Redir.here-document<Tab><<-label														S<<-EOF<CR>EOF<CR># ===== end of here-document =====<ESC>kPk^i'
	"
	"------------------------------------------------------------------------------
	"----- menu Run    {{{2
	"------------------------------------------------------------------------------
	"   run the script from the local directory
	"   ( the one in the current buffer ; other versions may exist elsewhere ! )
	"

	exe " menu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab>\\rr\ \r<C-F9>            :call BASH_Run("n")<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab>\\rr\ \r<C-F9>       <C-C>:call BASH_Run("n")<CR>'
	if	!s:MSWIN
		exe "vmenu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab>\\rr\ \r<C-F9>       <C-C>:call BASH_Run("v")<CR>'
	endif
	"
	"   set execution right only for the user ( may be user root ! )
	"
	exe " menu <silent> ".s:BASH_Root.'&Run.script\ cmd\.\ line\ &arg\.<Tab>\\ra\ \ <S-F9>            :call BASH_ScriptCmdLineArguments()<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Run.script\ cmd\.\ line\ &arg\.<Tab>\\ra\ \ <S-F9>       <C-C>:call BASH_ScriptCmdLineArguments()<CR>'
	"
	exe " menu <silent> ".s:BASH_Root.'&Run.Bash\ cmd\.\ line\ &arg\.<Tab>\\rba                       :call BASH_BashCmdLineArguments()<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Run.Bash\ cmd\.\ line\ &arg\.<Tab>\\rba                  <C-C>:call BASH_BashCmdLineArguments()<CR>'
	"
	exe " menu <silent> ".s:BASH_Root.'&Run.save\ +\ &check\ syntax<Tab>\\rc\ \ <A-F9>      :call BASH_SyntaxCheck()<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Run.save\ +\ &check\ syntax<Tab>\\rc\ \ <A-F9> <C-C>:call BASH_SyntaxCheck()<CR>'
	exe " menu <silent> ".s:BASH_Root.'&Run.syntax\ check\ o&ptions<Tab>\\rco               :call BASH_SyntaxCheckOptionsLocal()<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Run.syntax\ check\ o&ptions<Tab>\\rco          <C-C>:call BASH_SyntaxCheckOptionsLocal()<CR>'
	"
	if	!s:MSWIN
		exe " menu <silent> ".s:BASH_Root.'&Run.start\ &debugger<Tab>\\rd\ \ \ \ <F9>           :call BASH_Debugger()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.start\ &debugger<Tab>\\rd\ \ \ \ <F9>      <C-C>:call BASH_Debugger()<CR>'
		exe " menu <silent> ".s:BASH_Root.'&Run.make\ script\ &executable<Tab>\\re              :call BASH_MakeScriptExecutable()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.make\ script\ &executable<Tab>\\re         <C-C>:call BASH_MakeScriptExecutable()<CR>'
	endif
	"
	exe "amenu          ".s:BASH_Root.'&Run.-Sep1-                                 :'
	"
	if	s:MSWIN
		exe " menu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ printer\.ps<Tab>\\rh           :call BASH_Hardcopy("n")<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ printer\.ps<Tab>\\rh      <C-C>:call BASH_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ printer\.ps<Tab>\\rh      <C-C>:call BASH_Hardcopy("v")<CR>'
	else
		exe " menu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps<Tab>\\rh           :call BASH_Hardcopy("n")<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps<Tab>\\rh      <C-C>:call BASH_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps<Tab>\\rh      <C-C>:call BASH_Hardcopy("v")<CR>'
	endif
	exe " menu          ".s:BASH_Root.'&Run.-SEP2-                                 :'
	exe " menu <silent> ".s:BASH_Root.'&Run.plugin\ &settings<Tab>\\rs                       :call BASH_Settings()<CR>'
	exe "imenu <silent> ".s:BASH_Root.'&Run.plugin\ &settings<Tab>\\rs                  <C-C>:call BASH_Settings()<CR>'
	"
	exe "imenu          ".s:BASH_Root.'&Run.-SEP3-                                 :'
	"
	if	!s:MSWIN
		exe " menu  <silent>  ".s:BASH_Root.'&Run.x&term\ size<Tab>\\rt                       :call BASH_XtermSize()<CR>'
		exe "imenu  <silent>  ".s:BASH_Root.'&Run.x&term\ size<Tab>\\rt                  <C-C>:call BASH_XtermSize()<CR>'
	endif
	"
	if	s:MSWIN
		if s:BASH_OutputGvim == "buffer"
			exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro          :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro     <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
		else
			exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro          :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro     <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
		endif
	else
		if s:BASH_OutputGvim == "vim"
			exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro          :call BASH_Toggle_Gvim_Xterm()<CR>'
			exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
		else
			if s:BASH_OutputGvim == "buffer"
				exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			else
				exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			endif
		endif
	endif
	"
	"===============================================================================================
	"----- menu help     {{{2
	"===============================================================================================
	"
	exe " menu  <silent>  ".s:BASH_Root.'&Help.&Bash\ manual<Tab>\\hb                    :call BASH_help("b")<CR>'
	exe "imenu  <silent>  ".s:BASH_Root.'&Help.&Bash\ manual<Tab>\\hb               <C-C>:call BASH_help("b")<CR>'
	"
	exe " menu  <silent>  ".s:BASH_Root.'&Help.&help\ (Bash\ builtins)<Tab>\\hh          :call BASH_help("h")<CR>'
	exe "imenu  <silent>  ".s:BASH_Root.'&Help.&help\ (Bash\ builtins)<Tab>\\hh     <C-C>:call BASH_help("h")<CR>'
	"
	exe " menu  <silent>  ".s:BASH_Root.'&Help.&manual\ (utilities)<Tab>\\hm             :call BASH_help("m")<CR>'
	exe "imenu  <silent>  ".s:BASH_Root.'&Help.&manual\ (utilities)<Tab>\\hm        <C-C>:call BASH_help("m")<CR>'
	"
	exe " menu  <silent>  ".s:BASH_Root.'&Help.bash-&support<Tab>\\hbs           :call BASH_HelpBASHsupport()<CR>'
	exe "imenu  <silent>  ".s:BASH_Root.'&Help.bash-&support<Tab>\\hbs      <C-C>:call BASH_HelpBASHsupport()<CR>'
	"
endfunction		" ---------- end of function  BASH_InitMenu  ----------

"------------------------------------------------------------------------------
"  BASH Menu Header Initialization      {{{1
"------------------------------------------------------------------------------
function! BASH_InitMenuHeader ()
	exe "amenu ".s:BASH_Root.'Bash          :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'-Sep0-        :'
	exe "amenu ".s:BASH_Root.'&Comments.Comments<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Comments.-Sep0-              :'
	exe "amenu ".s:BASH_Root.'&Statements.Statements<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Statements.-Sep0-               :'
	exe "amenu ".s:BASH_Root.'&Snippets.Snippets<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Snippets.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'&Tests.Tests<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Tests.-Sep0-           :'
	exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.Tests-1<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.Tests-2<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.-Sep0-           :'
	exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.Tests-3<Tab>Bash       :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.-Sep0-                 :'
	exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.Tests-4<Tab>Bash                 :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.-Sep0-                           :'
	exe "amenu ".s:BASH_Root.'&ParamSub.ParamSub<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&ParamSub.-Sep0-            :'
	exe "amenu ".s:BASH_Root.'Spec&Vars.SpecVars<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'Spec&Vars.-Sep0-            :'
	exe "amenu ".s:BASH_Root.'E&nviron.Environ<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'E&nviron.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.Environ-1<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.Environ-2<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.-Sep0-               :'
	exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.Environ-3<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.-Sep0-               :'
	exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.Environ-4<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.Environ-5<Tab>Bash      :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.-Sep0-                  :'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Builtins.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins\ \ &a-f.Builtins\ 1<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins\ \ &a-f.-Sep0-                :'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins\ \ &g-r.Builtins\ 2<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins\ \ &g-r.-Sep0-                :'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins\ \ &s-w.Builtins\ 3<Tab>Bash  :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Builtins.Builtins\ \ &s-w.-Sep0-                :'
	exe "amenu ".s:BASH_Root.'s&et.set<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'s&et.-Sep0-         :'
	exe "amenu ".s:BASH_Root.'sh&opt.shopt<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'sh&opt.-Sep0-           :'
	exe "amenu ".s:BASH_Root.'sh&opt.shopt\ \ &a-g.shopt\ 1<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'sh&opt.shopt\ \ &a-g.-Sep0-            :'
	exe "amenu ".s:BASH_Root.'sh&opt.shopt\ \ &h-x.shopt\ 2<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'sh&opt.shopt\ \ &h-x.-Sep0-            :'
	exe "amenu ".s:BASH_Root.'Rege&x.Regex<Tab>bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'Rege&x.-Sep0-           :'
	exe "amenu ".s:BASH_Root.'&I/O-Redir.I/O-Redir<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&I/O-Redir.-Sep0-             :'
	exe "amenu ".s:BASH_Root.'&Run.Run<Tab>Bash   :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Run.-Sep0-         :'
	exe "amenu ".s:BASH_Root.'&Help.Help<Tab>Bash :call BASH_MenuTitle()<CR>'
	exe "amenu ".s:BASH_Root.'&Help.-Sep0-        :'
endfunction    " ----------  end of function BASH_InitMenuHeader  ----------

function! BASH_MenuTitle ()
	echo "This is a menu title."
endfunction    " ----------  end of function BASH_MenuTitle  ----------

let	s:BashEnvironmentVariables  = [
	\	'&BASH',        'BASH&PID',               'BASH_&ALIASES',
	\	'BASH_ARG&C',   'BASH_ARG&V',             'BASH_C&MDS',       'BASH_C&OMMAND',
	\	'BASH_&ENV',    'BASH_E&XECUTION_STRING', 'BASH_&LINENO',     'BASH&OPTS',      'BASH_&REMATCH',
	\	'BASH_&SOURCE', 'BASH_S&UBSHELL',         'BASH_VERS&INFO',   'BASH_VERSIO&N',  'BASH_XTRACEFD',
	\	'&CDPATH',      'C&OLUMNS',               'CO&MPREPLY',       'COM&P_CWORD',
	\	'COMP_&KEY',    'COMP_&LINE',             'COMP_POI&NT',      'COMP_&TYPE',
	\	'COMP_WORD&BREAKS', 'COMP_&WORDS',
	\	'&DIRSTACK',    '&EMAC&S',                '&EUID',            '&FCEDIT',
	\	'F&IGNORE',     'F&UNCNAME',              '&GLOBIGNORE',      'GRO&UPS',
	\	'&HISTCMD',     'HI&STCONTROL',           'HIS&TFILE',        'HIST&FILESIZE',
	\	'HISTIG&NORE',  'HISTSI&ZE',              'HISTTI&MEFORMAT',  'H&OME',
	\	'HOSTFIL&E',    'HOSTN&AME',              'HOSTT&YPE',        '&IFS',
	\	'IGNO&REEOF',   'INPUTR&C',               '&LANG',            '&LC_ALL',
	\	'LC_&COLLATE',  'LC_C&TYPE',              'LC_M&ESSAGES',     'LC_&NUMERIC',
	\	'L&INENO',      'LINE&S',                 '&MACHTYPE',        'M&AIL',
	\	'MAILCHEC&K',   'MAIL&PATH',              '&OLDPWD',          'OPTAR&G',
	\	'OPTER&R',      'OPTIN&D',                'OST&YPE',          '&PATH',
	\	'P&IPESTATUS',  'P&OSIXLY_CORRECT',       'PPI&D',            'PROMPT_&COMMAND',
	\	'PROMPT_&DIRTRIM',
	\	'PS&1',         'PS&2',                   'PS&3',             'PS&4',
	\	'P&WD',         '&RANDOM',                'REPL&Y',           '&SECONDS',
	\	'S&HELL',       'SH&ELLOPTS',             'SH&LVL',           '&TIMEFORMAT',
	\	'T&MOUT',       'TMP&DIR',                '&UID',
	\	]

let s:BashBuiltins  = [
  \ '&alias',   'b&g',      '&bind',     'brea&k',    'b&uiltin',  '&caller',
  \ 'c&d',      'c&ommand', 'co&mpgen',  'com&plete', 'c&ontinue', 'comp&opt',
  \ 'd&eclare', 'di&rs',    'diso&wn',   'ec&ho',     'e&nable',   'e&val',
  \ 'e&xec',    'ex&it',    'expor&t',   '&false',    'f&c',       'f&g',
  \ '&getopts', '&hash',    'help',      'h&istory',  '&jobs',
  \ '&kill',    '&let',     'l&ocal',    'logout',    '&mapfile',   '&popd',
  \ 'print&f',  'p&ushd',   'p&wd',      '&read',     'read&array', 'readonl&y',
  \ 'retur&n',  '&set',
  \ 's&hift',   's&hopt',   's&ource',   'susp&end',  '&test',
  \ 'ti&mes',   't&rap',    'true',      't&ype',     'ty&peset',   '&ulimit',
  \ 'umas&k',   'un&alias', 'u&nset',    '&wait',
  \ ]

let	s:BashShopt = [
	\	'autocd',        'cdable_vars',      'cdspell',       'checkhash',
	\	'checkjobs',     'checkwinsize',     'cmdhist',       'compat31',       'compat32',       'compat40',
	\	'dirspell',      'dotglob',          'execfail',      'expand_aliases',
	\	'extdebug',      'extglob',          'extquote',      'failglob',
	\	'force_fignore', 'globstar',         'gnu_errfmt',    'histappend',    'histreedit',
	\	'histverify',    'hostcomplete',     'huponexit',     'interactive_comments',
	\	'lithist',       'login_shell',      'mailwarn',      'no_empty_cmd_completion',
	\	'nocaseglob',    'nocasematch',      'nullglob',      'progcomp',
	\	'promptvars',    'restricted_shell', 'shift_verbose', 'sourcepath',
	\	'xpg_echo',
	\	]

"------------------------------------------------------------------------------
"  Build the list for the Bash help tab completion
"------------------------------------------------------------------------------
let s:BASH_Builtins     = s:BashBuiltins[:]
let index	= 0
while index < len( s:BASH_Builtins )
	let s:BASH_Builtins[index]	= substitute( s:BASH_Builtins[index], '&', '', '' )
	let index = index + 1
endwhile

"------------------------------------------------------------------------------
"  BASH_EnvirMenus: generate the  menu entries for environmnent variables  {{{1
"------------------------------------------------------------------------------
function! BASH_EnvirMenus ( menupath, liblist )
	for item in a:liblist
		let replacement	= substitute( item, '[&\\]*', '','g' )
		exe " noremenu  ".a:menupath.'.'.item.'          a${'.replacement.'}'
		exe "inoremenu  ".a:menupath.'.'.item.'           ${'.replacement.'}'
	endfor
endfunction    " ----------  end of function BASH_EnvirMenus  ----------

"------------------------------------------------------------------------------
"  BASH_BuiltinMenus: generate the  menu entries for environmnent variables  {{{1
"------------------------------------------------------------------------------
function! BASH_BuiltinMenus ( menupath, liblist )
	for item in a:liblist
		let replacement	= substitute( item, '[&\\]*', '','g' )
		exe " noremenu  ".a:menupath.'.'.item.'          a'.replacement.' '
		exe "inoremenu  ".a:menupath.'.'.item.'           '.replacement.' '
	endfor
endfunction    " ----------  end of function BASH_BuiltinMenus  ----------

"------------------------------------------------------------------------------
"  BASH_ShoptMenus: generate the  menu entries for environmnent variables  {{{1
"------------------------------------------------------------------------------
function! BASH_ShoptMenus ( menupath, liblist )
	for item in a:liblist
		let replacement	= substitute( item, '[&\\]*', '','g' )
		exe " noremenu  ".a:menupath.'.'.item.'                oshopt -s '.replacement
		exe "inoremenu  ".a:menupath.'.'.item.'                 shopt -s '.replacement
		exe "vnoremenu  ".a:menupath.'.'.item.'   <Esc>:call BASH_shopt("'.replacement.'")<CR>'
	endfor
endfunction    " ----------  end of function BASH_ShoptMenus  ----------

"------------------------------------------------------------------------------
"  BASH_RereadTemplates     {{{1
"  rebuild commands and the menu from the (changed) template file
"------------------------------------------------------------------------------
function! BASH_RereadTemplates ( displaymsg )
	let s:style							= 'default'
	let s:BASH_Template     = { 'default' : {} }
	let s:BASH_FileVisited  = []
	let	messsage							= ''
	"
	if s:installation == 'system'
		"-------------------------------------------------------------------------------
		" system installation
		"-------------------------------------------------------------------------------
		if filereadable( s:BASH_GlobalTemplateFile )
			call BASH_ReadTemplates( s:BASH_GlobalTemplateFile )
		else
			echomsg "Global template file '".s:BASH_GlobalTemplateFile."' not readable."
			return
		endif
		let	messsage	= "Templates read from '".s:BASH_GlobalTemplateFile."'"
		"
		if filereadable( s:BASH_LocalTemplateFile )
			call BASH_ReadTemplates( s:BASH_LocalTemplateFile )
			let messsage	= messsage." and '".s:BASH_LocalTemplateFile."'"
			if s:BASH_Macro['|AUTHOR|'] == 'YOUR NAME'
				echomsg "Please set your personal details in file '".s:BASH_LocalTemplateFile."'."
			endif
		else
			let template	= [ '|AUTHOR|    = YOUR NAME',
						\						'|COPYRIGHT| = Copyright (c) |YEAR|, |AUTHOR|'
						\		]
			if finddir( s:BASH_LocalTemplateDir ) == ''
				" try to create a local template directory
				if exists("*mkdir")
					try
						call mkdir( s:BASH_LocalTemplateDir, "p" )
						" write a default local template file
						call writefile( template, s:BASH_LocalTemplateFile )
					catch /.*/
					endtry
				endif
			else
				" write a default local template file
				call writefile( template, s:BASH_LocalTemplateFile )
			endif
		endif
		"
	else
		"-------------------------------------------------------------------------------
		" local installation
		"-------------------------------------------------------------------------------
		if filereadable( s:BASH_LocalTemplateFile )
			call BASH_ReadTemplates( s:BASH_LocalTemplateFile )
			let	messsage	= "Templates read from '".s:BASH_LocalTemplateFile."'"
		else
			echomsg "Local template file '".s:BASH_LocalTemplateFile."' not readable."
			return
		endif
		"
	endif
	if a:displaymsg == 'yes'
		echomsg messsage.'.'
	endif

endfunction    " ----------  end of function BASH_RereadTemplates  ----------
"
"------------------------------------------------------------------------------
"  BASH_BrowseTemplateFiles     {{{1
"------------------------------------------------------------------------------
function! BASH_BrowseTemplateFiles ( type )
	let	templatefile	= eval( 's:BASH_'.a:type.'TemplateFile' )
	let	templatedir		= eval('s:BASH_'.a:type.'TemplateDir')
	if isdirectory( templatedir )
		if has("browse") && s:BASH_GuiTemplateBrowser == 'gui'
			let	l:templatefile	= browse(0,"edit a template file", templatedir, "" )
		else
				let	l:templatefile	= ''
			if s:BASH_GuiTemplateBrowser == 'explorer'
				exe ':Explore '.templatedir
			endif
			if s:BASH_GuiTemplateBrowser == 'commandline'
				let	l:templatefile	= input("edit a template file", templatedir, "file" )
			endif
		endif
		if l:templatefile != ""
			:execute "update! | split | edit ".l:templatefile
		endif
	else
		echomsg a:type." template directory '".templatedir."' does not exist."
	endif
endfunction    " ----------  end of function BASH_BrowseTemplateFiles  ----------
"
"------------------------------------------------------------------------------
"  BASH_ReadTemplates     {{{1
"  read the template file(s), build the macro and the template dictionary
"
"------------------------------------------------------------------------------
let	s:style			= 'default'
function! BASH_ReadTemplates ( templatefile )

  if !filereadable( a:templatefile )
    echohl WarningMsg
    echomsg "Bash Support template file '".a:templatefile."' does not exist or is not readable"
    echohl None
    return
  endif

	let	skipmacros	= 0
  let s:BASH_FileVisited  += [a:templatefile]

  "------------------------------------------------------------------------------
  "  read template file, start with an empty template dictionary
  "------------------------------------------------------------------------------

  let item  		= ''
	let	skipline	= 0
  for line in readfile( a:templatefile )
		" if not a comment :
    if line !~ s:BASH_MacroCommentRegex
      "
			"-------------------------------------------------------------------------------
			" IF |STYLE| IS ...
			"-------------------------------------------------------------------------------
      "
      let string  = matchlist( line, s:BASH_TemplateIf )
      if !empty(string)
				if !has_key( s:BASH_Template, string[1] )
					" new s:style
					let	s:style	= string[1]
					let	s:BASH_Template[s:style]	= {}
					continue
				endif
			endif
			"
			"-------------------------------------------------------------------------------
			" ENDIF
			"-------------------------------------------------------------------------------
      "
      let string  = matchlist( line, s:BASH_TemplateEndif )
      if !empty(string)
				let	s:style	= 'default'
				continue
			endif
      "
			"-------------------------------------------------------------------------------
      " macros and file includes
			"-------------------------------------------------------------------------------
      "
      let string  = matchlist( line, s:BASH_MacroLineRegex )
      if !empty(string) && skipmacros == 0
        let key = '|'.string[1].'|'
        let val = string[2]
        let val = substitute( val, '\s\+$', '', '' )
        let val = substitute( val, "[\"\']$", '', '' )
        let val = substitute( val, "^[\"\']", '', '' )
        "
        if key == '|includefile|' && count( s:BASH_FileVisited, val ) == 0
					let path   = fnamemodify( a:templatefile, ":p:h" )
          call BASH_ReadTemplates( path.'/'.val )    " recursive call
        else
          let s:BASH_Macro[key] = escape( val, '&' )
        endif
        continue                                     " next line
      endif
      "
      " template header
      "
      let name  = matchstr( line, s:BASH_TemplateLineRegex )
      "
      if !empty(name)
				" start with a new template
        let part  = split( name, '\s*==\s*')
        let item  = part[0]
        if has_key( s:BASH_Template[s:style], item ) && s:BASH_TemplateOverriddenMsg == 'yes'
          echomsg "style '".s:style."' / existing Bash Support template '".item."' overridden"
        endif
        let s:BASH_Template[s:style][item] = ''
				let skipmacros	= 1
        "
        let s:BASH_Attribute[item] = 'below'
        if has_key( s:Attribute, get( part, 1, 'NONE' ) )
          let s:BASH_Attribute[item] = part[1]
        endif
      else
				" add to a template
        if !empty(item)
          let s:BASH_Template[s:style][item] .= line."\n"
        endif
      endif
    endif
  endfor " ----- readfile -----
	let s:BASH_ActualStyle	= 'default'
	if !empty( s:BASH_Macro['|STYLE|'] )
		let s:BASH_ActualStyle	= s:BASH_Macro['|STYLE|']
	endif
	let s:BASH_ActualStyleLast	= s:BASH_ActualStyle
endfunction    " ----------  end of function BASH_ReadTemplates  ----------

"------------------------------------------------------------------------------
" BASH_Style{{{1
" ex-command BashStyle : callback function
"------------------------------------------------------------------------------
function! BASH_Style ( style )
	let lstyle  = substitute( a:style, '^\s\+', "", "" )	" remove leading whitespaces
	let lstyle  = substitute( lstyle, '\s\+$', "", "" )		" remove trailing whitespaces
	if has_key( s:BASH_Template, lstyle )
		if len( s:BASH_Template[lstyle] ) == 0
			echomsg "style '".lstyle."' : no templates defined"
			return
		endif
		let s:BASH_ActualStyleLast	= s:BASH_ActualStyle
		let s:BASH_ActualStyle	= lstyle
		if len( s:BASH_ActualStyle ) > 1 && s:BASH_ActualStyle != s:BASH_ActualStyleLast
			echomsg "template style is '".lstyle."'"
		endif
	else
		echomsg "style '".lstyle."' does not exist"
	endif
endfunction    " ----------  end of function BASH_Style  ----------

"------------------------------------------------------------------------------
" BASH_StyleList     {{{1
" ex-command BashStyle
"------------------------------------------------------------------------------
function!	BASH_StyleList ( ArgLead, CmdLine, CursorPos )
	" show all types / types beginning with a:ArgLead
	return filter( copy(keys(s:BASH_Template)), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function BASH_StyleList  ----------

"------------------------------------------------------------------------------
" BASH_OpenFold     {{{1
" Open fold and go to the first or last line of this fold.
"------------------------------------------------------------------------------
function! BASH_OpenFold ( mode )
	if foldclosed(".") >= 0
		" we are on a closed  fold: get end position, open fold, jump to the
		" last line of the previously closed fold
		let	foldstart	= foldclosed(".")
		let	foldend		= foldclosedend(".")
		normal zv
		if a:mode == 'below'
			exe ":".foldend
		endif
		if a:mode == 'start'
			exe ":".foldstart
		endif
	endif
endfunction    " ----------  end of function BASH_OpenFold  ----------

"------------------------------------------------------------------------------
"  BASH_InsertTemplate     {{{1
"  insert a template from the template dictionary
"  do macro expansion
"------------------------------------------------------------------------------
function! BASH_InsertTemplate ( key, ... )


	if s:BASH_TemplatesLoaded == 'no'
		call BASH_RereadTemplates('no')
		let s:BASH_TemplatesLoaded	= 'yes'
	endif

	if !has_key( s:BASH_Template[s:BASH_ActualStyle], a:key ) &&
	\  !has_key( s:BASH_Template['default'], a:key )
		echomsg "style '".a:key."' / template '".a:key
	\        ."' not found. Please check your template file in '".s:BASH_GlobalTemplateDir."'"
		return
	endif

	if &foldenable
		let	foldmethod_save	= &foldmethod
		set foldmethod=manual
	endif
  "------------------------------------------------------------------------------
  "  insert the user macros
  "------------------------------------------------------------------------------

	" use internal formatting to avoid conficts when using == below
	"
	call BASH_SaveOption( 'equalprg' )
	set equalprg=

  let mode  = s:BASH_Attribute[a:key]

	" remove <SPLIT> and insert the complete macro
	"
	if a:0 == 0
		let val = BASH_ExpandUserMacros (a:key)
		if empty(val)
			return
		endif
		let val	= BASH_ExpandSingleMacro( val, '<SPLIT>', '' )

		if mode == 'below'
			call BASH_OpenFold('below')
			let pos1  = line(".")+1
			put  =val
			let pos2  = line(".")
			" proper indenting
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
			"
		elseif mode == 'above'
			let pos1  = line(".")
			put! =val
			let pos2  = line(".")
			" proper indenting
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
			"
		elseif mode == 'start'
			normal gg
			call BASH_OpenFold('start')
			let pos1  = 1
			put! =val
			let pos2  = line(".")
			" proper indenting
			exe ":".pos1
			let ins	= pos2-pos1+1
			exe "normal ".ins."=="
			"
		elseif mode == 'append'
			if &foldenable && foldclosed(".") >= 0
				echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
				exe "set foldmethod=".foldmethod_save
				return
			else
				let pos1  = line(".")
				put =val
				let pos2  = line(".")-1
				exe ":".pos1
				:join!
			endif
			"
		elseif mode == 'insert'
			if &foldenable && foldclosed(".") >= 0
				echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
				exe "set foldmethod=".foldmethod_save
				return
			else
				let val   = substitute( val, '\n$', '', '' )
				let currentline	= getline( "." )
				let pos1  = line(".")
				let pos2  = pos1 + count( split(val,'\zs'), "\n" )
				" assign to the unnamed register "" :
				let @"=val
				normal p
				" reformat only multiline inserts and previously empty lines
				if pos2-pos1 > 0 || currentline =~ ''
					exe ":".pos1
					let ins	= pos2-pos1+1
					exe "normal ".ins."=="
				endif
			endif
			"
		endif
		"
	else
		"
		" =====  visual mode  ===============================
		"
		if  a:1 == 'v'
			let val = BASH_ExpandUserMacros (a:key)
			let val	= BASH_ExpandSingleMacro( val, s:BASH_TemplateJumpTarget2, '' )
			if empty(val)
				return
			endif

			if match( val, '<SPLIT>\s*\n' ) >= 0
				let part	= split( val, '<SPLIT>\s*\n' )
			else
				let part	= split( val, '<SPLIT>' )
			endif

			if len(part) < 2
				let part	= [ "" ] + part
				echomsg '<SPLIT> missing in template '.a:key
			endif
			"
			" 'visual' and mode 'insert':
			"   <part0><marked area><part1>
			" part0 and part1 can consist of several lines
			"
			if mode == 'insert'
				let pos1  = line(".")
				let pos2  = pos1
				" windows: recover area of the visual mode and yank, puts the selected area in the buffer
    		normal gvy
				let string	= eval('@"')
				let replacement	= part[0].string.part[1]
				" remove trailing '\n'
				let replacement   = substitute( replacement, '\n$', '', '' )
				exe ':s/'.string.'/'.replacement.'/'
			endif
			"
			" 'visual' and mode 'below':
			"   <part0>
			"   <marked area>
			"   <part1>
			" part0 and part1 can consist of several lines
			"
			if mode == 'below'

				:'<put! =part[0]
				:'>put  =part[1]

				let pos1  = line("'<") - len(split(part[0], '\n' ))
				let pos2  = line("'>") + len(split(part[1], '\n' ))
				""			echo part[0] part[1] pos1 pos2
				"			" proper indenting
				exe ":".pos1
				let ins	= pos2-pos1+1
				exe "normal ".ins."=="
			endif
			"
		endif		" ---------- end visual mode
	endif

	" restore formatter programm
	call BASH_RestoreOption( 'equalprg' )

  "------------------------------------------------------------------------------
  "  position the cursor
  "------------------------------------------------------------------------------
  exe ":".pos1
  let mtch = search( '<CURSOR>', 'c', pos2 )
	if mtch != 0
		let line	= getline(mtch)
		if line =~ '<CURSOR>$'
			call setline( mtch, substitute( line, '<CURSOR>', '', '' ) )
			if  a:0 != 0 && a:1 == 'v' && getline(".") =~ '^\s*$'
				normal J
			else
				:startinsert!
			endif
		else
			call setline( mtch, substitute( line, '<CURSOR>', '', '' ) )
			:startinsert
		endif
	else
		" to the end of the block; needed for repeated inserts
		if mode == 'below'
			exe ":".pos2
		endif
  endif

  "------------------------------------------------------------------------------
  "  marked words
  "------------------------------------------------------------------------------
	" define a pattern to highlight
	call BASH_HighlightJumpTargets ()

	if &foldenable
		" restore folding method
		exe "set foldmethod=".foldmethod_save
		normal zv
	endif

endfunction    " ----------  end of function BASH_InsertTemplate  ----------
"
"------------------------------------------------------------------------------
"  BASH_Input : Input after a highlighted prompt    {{{1
"------------------------------------------------------------------------------
function! BASH_Input ( promp, text, ... )
	echohl Search																					" highlight prompt
	call inputsave()																			" preserve typeahead
	if a:0 == 0 || empty(a:1)
		let retval	=input( a:promp, a:text )
	else
		let retval	=input( a:promp, a:text, a:1 )
	endif
	call inputrestore()																		" restore typeahead
	echohl None																						" reset highlighting
	let retval  = substitute( retval, '^\s\+', "", "" )		" remove leading whitespaces
	let retval  = substitute( retval, '\s\+$', "", "" )		" remove trailing whitespaces
	return retval
endfunction    " ----------  end of function BASH_Input ----------
"
"------------------------------------------------------------------------------
"  BASH_AdjustLineEndComm: adjust line-end comments      {{{1
"------------------------------------------------------------------------------
function! BASH_AdjustLineEndComm ( ) range
	"
	if !exists("b:BASH_LineEndCommentColumn")
		let	b:BASH_LineEndCommentColumn	= s:BASH_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	let	linenumber	= a:firstline
	exe ":".a:firstline

	" patterns to ignore when adjusting line-end comments (incomplete):
	let	AlignRegex	= [
				\	'\$#' ,
				\	'\${#}' ,
				\	'\${#\w*}' ,
				\	'\${#\w\+\[[^\]]\+\]}' ,
				\	'\${\w\+##\?.\+}' ,
				\	'\${\w\+\/#\?.\+}' ,
				\	'"[^"]*"' ,
				\	"'[^']*'" ,
				\	"`[^`]*`" ,
				\	]

	while linenumber <= a:lastline
		let	line= getline(".")

		let idx1	= 1 + match( line, '\s*#.*$', 0 )
		let idx2	= 1 + match( line,    '#.*$', 0 )

		" comment with leading whitespaces left unchanged
		if     match( line, '^\s*#' ) == 0
			let idx1	= 0
			let idx2	= 0
		endif

		for regex in AlignRegex
			if match( line, regex ) >= 0
				let start	= matchend( line, regex )
				let idx1	= 1 + match( line, '\s*#.*$', start )
				let idx2	= 1 + match( line,    '#.*$', start )
				break
			endif
		endfor

		let	ln	= line(".")
		call setpos(".", [ 0, ln, idx1, 0 ] )
		let vpos1	= virtcol(".")
		call setpos(".", [ 0, ln, idx2, 0 ] )
		let vpos2	= virtcol(".")

		if   ! (   vpos2 == b:BASH_LineEndCommentColumn
					\	|| vpos1 > b:BASH_LineEndCommentColumn
					\	|| idx2  == 0 )

			exe ":.,.retab"
			" insert some spaces
			if vpos2 < b:BASH_LineEndCommentColumn
				let	diff	= b:BASH_LineEndCommentColumn-vpos2
				call setpos(".", [ 0, ln, vpos2, 0 ] )
				let	@"	= ' '
				exe "normal	".diff."P"
			end

			" remove some spaces
			if vpos1 < b:BASH_LineEndCommentColumn && vpos2 > b:BASH_LineEndCommentColumn
				let	diff	= vpos2 - b:BASH_LineEndCommentColumn
				call setpos(".", [ 0, ln, b:BASH_LineEndCommentColumn, 0 ] )
				exe "normal	".diff."x"
			end

		end
		let linenumber=linenumber+1
		normal j
	endwhile
	" restore tab expansion settings and cursor position
	let &expandtab	= save_expandtab
	call setpos('.', save_cursor)

endfunction		" ---------- end of function  BASH_AdjustLineEndComm  ----------
"
"------------------------------------------------------------------------------
"  Comments : get line-end comment position    {{{1
"------------------------------------------------------------------------------
function! BASH_GetLineEndCommCol ()
	let actcol	= virtcol(".")
	if actcol+1 == virtcol("$")
		let	b:BASH_LineEndCommentColumn	= ''
		while match( b:BASH_LineEndCommentColumn, '^\s*\d\+\s*$' ) < 0
			let b:BASH_LineEndCommentColumn = BASH_Input( 'start line-end comment at virtual column : ', actcol, '' )
		endwhile
	else
		let	b:BASH_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:BASH_LineEndCommentColumn
endfunction		" ---------- end of function  BASH_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment    {{{1
"------------------------------------------------------------------------------
function! BASH_EndOfLineComment ( ) range
	if !exists("b:BASH_LineEndCommentColumn")
		let	b:BASH_LineEndCommentColumn	= s:BASH_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe a:firstline.','.a:lastline.'s/\s*$//'

	for line in range( a:lastline, a:firstline, -1 )
		let linelength	= virtcol( [line, "$"] ) - 1
		let	diff				= 1
		if linelength < b:BASH_LineEndCommentColumn
			let diff	= b:BASH_LineEndCommentColumn -1 -linelength
		endif
		exe "normal	".diff."A "
		call BASH_InsertTemplate('comment.end-of-line-comment')
		if line > a:firstline
			normal k
		endif
	endfor
endfunction		" ---------- end of function  BASH_EndOfLineComment  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments    {{{1
"------------------------------------------------------------------------------
function! BASH_MultiLineEndComments ( )
	"
  if !exists("b:BASH_LineEndCommentColumn")
		let	b:BASH_LineEndCommentColumn	= s:BASH_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	"
	" ----- trim whitespaces -----
  exe pos0.','.pos1.'s/\s*$//'
	"
	" ----- find the longest line -----
	let maxlength	= max( map( range(pos0, pos1), "virtcol([v:val, '$'])" ) )
	let	maxlength	= max( [b:BASH_LineEndCommentColumn, maxlength+1] )
	"
	" ----- fill lines with blanks -----
	for linenumber in range( pos0, pos1 )
		exe ":".linenumber
		if getline(linenumber) !~ '^\s*$'
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			call BASH_InsertTemplate('comment.end-of-line-comment')
		endif
	endfor
	"
	" ----- back to the begin of the marked block -----
	stopinsert
	normal '<$
	if match( getline("."), '\/\/\s*$' ) < 0
		if search( '\/\*', 'bcW', line(".") ) > 1
			normal l
		endif
		let save_cursor = getpos(".")
		if getline(".")[save_cursor[2]+1] == ' '
			normal l
		endif
	else
		normal $
	endif
endfunction		" ---------- end of function  BASH_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Comments : toggle comments (range)   {{{1
"------------------------------------------------------------------------------
function! BASH_CommentToggle () range
	let	comment=1
	for line in range( a:firstline, a:lastline )
		if match( getline(line), '^#') == -1					" no comment
			let comment = 0
			break
		endif
	endfor

	if comment == 0
			exe a:firstline.','.a:lastline."s/^/#/"
	else
			exe a:firstline.','.a:lastline."s/^#//"
	endif

endfunction    " ----------  end of function BASH_CommentToggle ----------
"
"------------------------------------------------------------------------------
"  Comments : put statement in an echo    {{{1
"------------------------------------------------------------------------------
function! BASH_echo_comment ()
	let	line	= escape( getline("."), '"' )
	let	line	= substitute( line, '^\s*', '', '' )
	call setline( line("."), 'echo "'.line.'"' )
	silent exe "normal =="
	return
endfunction    " ----------  end of function BASH_echo_comment  ----------
"
"------------------------------------------------------------------------------
"  Comments : remove echo from statement  {{{1
"------------------------------------------------------------------------------
function! BASH_remove_echo ()
	let	line	= substitute( getline("."), '\\"', '"', 'g' )
	let	line	= substitute( line, '^\s*echo\s\+"', '', '' )
	let	line	= substitute( line, '"$', '', '' )
	call setline( line("."), line )
	silent exe "normal =="
	return
endfunction    " ----------  end of function BASH_remove_echo  ----------
"
"------------------------------------------------------------------------------
"  Comments : Substitute tags    {{{1
"------------------------------------------------------------------------------
function! BASH_SubstituteTag( pos1, pos2, tag, replacement )
	"
	" loop over marked block
	"
	let	linenumber=a:pos1
	while linenumber <= a:pos2
		let line=getline(linenumber)
		"
		" loop for multiple tags in one line
		"
		let	start=0
		while match(line,a:tag,start)>=0				" do we have a tag ?
			let frst=match(line,a:tag,start)
			let last=matchend(line,a:tag,start)
			if frst!=-1
				let part1=strpart(line,0,frst)
				let part2=strpart(line,last)
				let line=part1.a:replacement.part2
				"
				" next search starts after the replacement to suppress recursion
				"
				let start=strlen(part1)+strlen(a:replacement)
			endif
		endwhile
		call setline( linenumber, line )
		let	linenumber=linenumber+1
	endwhile

endfunction    " ----------  end of function  Bash_SubstituteTag  ----------
"
"------------------------------------------------------------------------------
"  Comments : vim modeline    {{{1
"------------------------------------------------------------------------------
function! BASH_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function BASH_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  BASH_BuiltinComplete : builtin completion    {{{1
"------------------------------------------------------------------------------
function!	BASH_BuiltinComplete ( ArgLead, CmdLine, CursorPos )
	"
	" show all builtins
	"
	if empty(a:ArgLead)
		return s:BASH_Builtins
	endif
	"
	" show builtins beginning with a:ArgLead
	"
	let	expansions	= []
	for item in s:BASH_Builtins
		if match( item, '\<'.a:ArgLead.'\w*' ) == 0
			call add( expansions, item )
		endif
	endfor
	return	expansions
endfun
"
"-------------------------------------------------------------------------------
"   Comment : Script Sections             {{{1
"-------------------------------------------------------------------------------
let s:ScriptSection	= {
	\ "GLOBALS"          : "file-sections-globals"    ,
	\ "CMD\.LINE"				 : "file-sections-cmdline"    ,
	\ "SAN\.CHECKS"		   : "file-sections-sanchecks"  ,
	\ "FUNCT\.DEF\."		 : "file-sections-functdef"   ,
	\ "TRAPS"        		 : "file-sections-traps"      ,
	\ "MAIN\ SCRIPT"		 : "file-sections-mainscript" ,
	\ "STAT+CLEANUP"		 : "file-sections-statistics" ,
	\ }

function!	BASH_ScriptSectionList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( sort(keys( s:ScriptSection)) ), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function BASH_ScriptSectionList  ----------

function! BASH_ScriptSectionListInsert ( arg )
	if has_key( s:ScriptSection, a:arg )
		call BASH_InsertTemplate( 'comment.'.s:ScriptSection[a:arg] )
	else
		echomsg "entry '".a:arg."' does not exist"
	endif
endfunction    " ----------  end of function BASH_ScriptSectionListInsert  ----------
"
"-------------------------------------------------------------------------------
"   Comment : Keyword Comments             {{{1
"-------------------------------------------------------------------------------
let s:KeywordComment	= {
	\	'BUG'          : 'keyword-bug',
	\	'TODO'         : 'keyword-todo',
	\	'TRICKY'       : 'keyword-tricky',
	\	'WARNING'      : 'keyword-warning',
	\	'WORKAROUND'   : 'keyword-workaround',
	\	'new\ keyword' : 'keyword-keyword',
	\ }

function!	BASH_KeywordCommentList ( ArgLead, CmdLine, CursorPos )
	return filter( copy( sort(keys( s:KeywordComment)) ), 'v:val =~ "\\<'.a:ArgLead.'\\w*"' )
endfunction    " ----------  end of function BASH_KeywordCommentList  ----------

function! BASH_KeywordCommentListInsert ( arg )
	if has_key( s:KeywordComment, a:arg )
		call BASH_InsertTemplate( 'comment.'.s:KeywordComment[a:arg] )
	else
		echomsg "entry '".a:arg."' does not exist"
	endif
endfunction    " ----------  end of function BASH_KeywordCommentListInsert  ----------
"
"------------------------------------------------------------------------------
"  BASH_help : lookup word under the cursor or ask    {{{1
"------------------------------------------------------------------------------
let s:BASH_DocBufferName       = "BASH_HELP"
let s:BASH_DocHelpBufferNumber = -1
"
function! BASH_help( type )

	let cuc		= getline(".")[col(".") - 1]		" character under the cursor
	let	item	= expand("<cword>")							" word under the cursor
	if empty(item) || match( item, cuc ) == -1
		if a:type == 'm'
			let	item=BASH_Input('[tab compl. on] name of command line utility : ', '', 'shellcmd' )
		endif
		if a:type == 'h'
			let	item=BASH_Input('[tab compl. on] name of bash builtin : ', '', 'customlist,BASH_BuiltinComplete' )
		endif
	endif

	if empty(item) &&  a:type != 'b'
		return
	endif
	"------------------------------------------------------------------------------
	"  replace buffer content with bash help text
	"------------------------------------------------------------------------------
	"
	" jump to an already open bash help window or create one
	"
	if bufloaded(s:BASH_DocBufferName) != 0 && bufwinnr(s:BASH_DocHelpBufferNumber) != -1
		exe bufwinnr(s:BASH_DocHelpBufferNumber) . "wincmd w"
		" buffer number may have changed, e.g. after a 'save as'
		if bufnr("%") != s:BASH_DocHelpBufferNumber
			let s:BASH_DocHelpBufferNumber=bufnr(s:BASH_OutputBufferName)
			exe ":bn ".s:BASH_DocHelpBufferNumber
		endif
	else
		exe ":new ".s:BASH_DocBufferName
		let s:BASH_DocHelpBufferNumber=bufnr("%")
		setlocal buftype=nofile
		setlocal noswapfile
		setlocal bufhidden=delete
		setlocal filetype=sh		" allows repeated use of <S-F1>
		setlocal syntax=OFF
	endif
	setlocal	modifiable
	"
	"-------------------------------------------------------------------------------
	" read Bash help
	"-------------------------------------------------------------------------------
	if a:type == 'h'
		silent exe ":%!help  ".item
	endif
	"
	"-------------------------------------------------------------------------------
	" open a manual (utilities)
	"-------------------------------------------------------------------------------
	if a:type == 'm'
		"
		" Is there more than one manual ?
		"
		let manpages	= system( s:BASH_Man.' -k '.item )
		if v:shell_error
			echomsg	"shell command '".s:BASH_Man." -k ".item."' failed"
			:close
			return
		endif
		let	catalogs	= split( manpages, '\n', )
		let	manual		= {}
		"
		" Select manuals where the name exactly matches
		"
		for line in catalogs
			if line =~ '^'.item.'\s\+('
				let	itempart	= split( line, '\s\+' )
				let	catalog		= itempart[1][1:-2]
				let	manual[catalog]	= catalog
			endif
		endfor
		"
		" Build a selection list if there are more than one manual
		"
		let	catalog	= ""
		if len(keys(manual)) > 1
			for key in keys(manual)
				echo ' '.item.'  '.key
			endfor
			let defaultcatalog	= ''
			if has_key( manual, '1' )
				let defaultcatalog	= '1'
			else
				if has_key( manual, '8' )
					let defaultcatalog	= '8'
				endif
			endif
			let	catalog	= input( 'select manual section (<Enter> cancels) : ', defaultcatalog )
			if ! has_key( manual, catalog )
				:close
				:redraw
				echomsg	"no appropriate manual section '".catalog."'"
				return
			endif
		endif

		set filetype=man
		silent exe ":%!".s:BASH_Man.' '.catalog.' '.item

		if s:MSWIN
			call s:bash_RemoveSpecialCharacters()
		endif

	endif
	"
	"-------------------------------------------------------------------------------
	" open the bash manual
	"-------------------------------------------------------------------------------
	if a:type == 'b'
		silent exe ":%!man 1 bash"

		if s:MSWIN
			call s:bash_RemoveSpecialCharacters()
		endif

		if !empty(item)
				" assign to the search pattern register "" :
				let @/=item
				echo "use n/N to search for '".item."'"
		endif
	endif

	setlocal nomodifiable
endfunction		" ---------- end of function  BASH_help  ----------
"
"------------------------------------------------------------------------------
"  remove <backspace><any character> in CYGWIN man(1) output   {{{1
"  remove           _<any character> in CYGWIN man(1) output   {{{1
"------------------------------------------------------------------------------
"
function! s:bash_RemoveSpecialCharacters ( )
	let	patternunderline	= '_\%x08'
	let	patternbold				= '\%x08.'
	setlocal modifiable
	if search(patternunderline) != 0
		silent exe ':%s/'.patternunderline.'//g'
	endif
	if search(patternbold) != 0
		silent exe ':%s/'.patternbold.'//g'
	endif
	setlocal nomodifiable
	silent normal gg
endfunction		" ---------- end of function  s:bash_RemoveSpecialCharacters   ----------
"
"------------------------------------------------------------------------------
"  Run : Syntax Check, check if local options does exist    {{{1
"------------------------------------------------------------------------------
"
function! s:bash_find_option ( list, option )
	for item in a:list
		if item == a:option
			return 0
		endif
	endfor
	return -1
endfunction    " ----------  end of function s:bash_find_option  ----------
"
function! BASH_SyntaxCheckOptions( options )
	let startpos=0
	while startpos < strlen( a:options )
		" match option switch ' -O ' or ' +O '
		let startpos		= matchend ( a:options, '\s*[+-]O\s\+', startpos )
		" match option name
		let optionname	= matchstr ( a:options, '\h\w*\s*', startpos )
		" remove trailing whitespaces
		let optionname  = substitute ( optionname, '\s\+$', "", "" )
		" check name
		let found				= s:bash_find_option ( s:BashShopt, optionname )
		if found < 0
			redraw
			echohl WarningMsg | echo ' no such shopt name :  "'.optionname.'"  ' | echohl None
			return 1
		endif
		" increment start position for next search
		let startpos		=  matchend  ( a:options, '\h\w*\s*', startpos )
	endwhile
	return 0
endfunction		" ---------- end of function  BASH_SyntaxCheckOptions----------
"
"------------------------------------------------------------------------------
"  Run : Syntax Check, local options    {{{1
"------------------------------------------------------------------------------
"
function! BASH_SyntaxCheckOptionsLocal ()
	let filename = expand("%")
  if empty(filename)
		redraw
		echohl WarningMsg | echo " no file name or not a shell file " | echohl None
		return
  endif
	let	prompt	= 'syntax check options for "'.filename.'" : '

	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let	b:BASH_SyntaxCheckOptionsLocal= BASH_Input( prompt, b:BASH_SyntaxCheckOptionsLocal, '' )
	else
		let	b:BASH_SyntaxCheckOptionsLocal= BASH_Input( prompt , "", '' )
	endif

	if BASH_SyntaxCheckOptions( b:BASH_SyntaxCheckOptionsLocal ) != 0
		let b:BASH_SyntaxCheckOptionsLocal	= ""
	endif
endfunction		" ---------- end of function  BASH_SyntaxCheckOptionsLocal  ----------
"
"------------------------------------------------------------------------------
"  Run : syntax check    {{{1
"------------------------------------------------------------------------------
function! BASH_SyntaxCheck ()
	exe	":cclose"
	let	l:currentbuffer=bufname("%")
	exe	":update"
	call BASH_SaveOption( 'makeprg' )
	exe	":setlocal makeprg=".s:BASH_BASH
	let l:fullname				= expand("%:p")
	"
	" check global syntax check options / reset in case of an error
	if BASH_SyntaxCheckOptions( s:BASH_SyntaxCheckOptionsGlob ) != 0
		let s:BASH_SyntaxCheckOptionsGlob	= ""
	endif
	"
	let	options=s:BASH_SyntaxCheckOptionsGlob
	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let	options=options." ".b:BASH_SyntaxCheckOptionsLocal
	endif
	"
	" match the Bash error messages (quickfix commands)
	" errorformat will be reset by function BASH_Handle()
	" ignore any lines that didn't match one of the patterns
	"
	exe	':setlocal errorformat='.s:BASH_Errorformat
	silent exe ":make -n ".options.' -- "'.l:fullname.'"'
	exe	":botright cwindow"
	exe	':setlocal errorformat='
	call BASH_RestoreOption('makeprg')
	"
	" message in case of success
	"
	redraw!
	if l:currentbuffer ==  bufname("%")
		echohl Search | echo l:currentbuffer." : Syntax is OK" | echohl None
		nohlsearch						" delete unwanted highlighting (Vim bug?)
	endif
endfunction		" ---------- end of function  BASH_SyntaxCheck  ----------
"
"------------------------------------------------------------------------------
"  Run : debugger    {{{1
"------------------------------------------------------------------------------
function! BASH_Debugger ()
	if !executable(s:BASH_bashdb)
		echohl Search
		echo   s:BASH_bashdb' is not executable or not installed! '
		echohl None
		return
	endif
	"
	silent exe	":update"
	let	l:arguments	= exists("b:BASH_ScriptCmdLineArgs") ? " ".b:BASH_ScriptCmdLineArgs : ""
	let	Sou					= fnameescape( expand("%:p") )
	"
	"
	if has("gui_running") || &term == "xterm"
		"
		" debugger is ' bashdb'
		"
		if s:BASH_Debugger == "term"
			let dbcommand	= "!xterm ".s:BASH_XtermDefaults.' -e '.s:BASH_bashdb.' -- '.Sou.l:arguments.' &'
			silent exe dbcommand
		endif
		"
		" debugger is 'ddd'
		"
		if s:BASH_Debugger == "ddd"
			if !executable("ddd")
				echohl WarningMsg
				echo "The debugger 'ddd' does not exist or is not executable!"
				echohl None
				return
			else
				silent exe '!ddd --debugger '.s:BASH_bashdb.' '.Sou.l:arguments.' &'
			endif
		endif
	else
		" no GUI : debugger is ' bashdb'
		silent exe '!'.s:BASH_bashdb.' -- '.Sou.l:arguments
	endif
endfunction		" ---------- end of function  BASH_Debugger  ----------
"
"----------------------------------------------------------------------
"  Run : toggle output destination (Linux/Unix)    {{{1
"----------------------------------------------------------------------
function! BASH_Toggle_Gvim_Xterm ()

	if has("gui_running")
		if s:BASH_OutputGvim == "vim"
			exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm'
			exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro          :call BASH_Toggle_Gvim_Xterm()<CR>'
			exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim<Tab>\\ro     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			let	s:BASH_OutputGvim	= "buffer"
		else
			if s:BASH_OutputGvim == "buffer"
				exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim'
				exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer<Tab>\\ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
				let	s:BASH_OutputGvim	= "xterm"
			else
				" ---------- output : xterm -> gvim
				exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer'
				exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro        :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm<Tab>\\ro   <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
				let	s:BASH_OutputGvim	= "vim"
			endif
		endif
	else
		if s:BASH_OutputGvim == "vim"
			let	s:BASH_OutputGvim	= "buffer"
		else
			let	s:BASH_OutputGvim	= "vim"
		endif
	endif
	echomsg "output destination is '".s:BASH_OutputGvim."'"

endfunction    " ----------  end of function BASH_Toggle_Gvim_Xterm ----------
"
"----------------------------------------------------------------------
"  Run : toggle output destination (Windows)    {{{1
"----------------------------------------------------------------------
function! BASH_Toggle_Gvim_Xterm_MS ()
	if has("gui_running")
		if s:BASH_OutputGvim == "buffer"
			exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->term'
			exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro         :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ TERM->buffer<Tab>\\ro    <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:BASH_OutputGvim	= "xterm"
		else
			exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ TERM->buffer'
			exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro         :call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->term<Tab>\\ro    <C-C>:call BASH_Toggle_Gvim_Xterm_MS()<CR>'
			let	s:BASH_OutputGvim	= "buffer"
		endif
	endif
endfunction    " ----------  end of function BASH_Toggle_Gvim_Xterm_MS ----------
"
"------------------------------------------------------------------------------
"  Run : make script executable    {{{1
"------------------------------------------------------------------------------
function! BASH_MakeScriptExecutable ()
	let	filename	= fnameescape( expand("%:p") )
	silent exe "!chmod u+x ".filename
	redraw!
	if v:shell_error
		echohl WarningMsg
	  echo 'Could not make "'.filename.'" executable !'
	else
		echohl Search
	  echo 'Made "'.filename.'" executable.'
	endif
	echohl None
endfunction		" ---------- end of function  BASH_MakeScriptExecutable  ----------
"
"------------------------------------------------------------------------------
"  BASH_BashCmdLineArguments : Bash command line arguments       {{{1
"------------------------------------------------------------------------------
function! BASH_BashCmdLineArguments ()
	let	prompt	= 'Bash command line arguments for "'.expand("%").'" : '
	if exists("b:BASH_BashCmdLineArgs")
		let	b:BASH_BashCmdLineArgs= BASH_Input( prompt, b:BASH_BashCmdLineArgs )
	else
		let	b:BASH_BashCmdLineArgs= BASH_Input( prompt , "" )
	endif
endfunction    " ----------  end of function BASH_BashCmdLineArguments ----------
"
"------------------------------------------------------------------------------
"  Run : run    {{{1
"------------------------------------------------------------------------------
"
let s:BASH_OutputBufferName   = "Bash-Output"
let s:BASH_OutputBufferNumber = -1
"
function! BASH_Run ( mode )
	silent exe ':cclose'
"
	let	l:arguments				= exists("b:BASH_ScriptCmdLineArgs") ? " ".b:BASH_ScriptCmdLineArgs : ""
	let	l:currentbuffer   = bufname("%")
	let l:fullname				= expand("%:p")
	let l:fullnameesc			= fnameescape( l:fullname )
	"
	silent exe ":update"
	"
	if a:mode=="v"
		let tmpfile	= tempname()
		silent exe ":'<,'>write ".tmpfile
	endif

	let l:bashCmdLineArgs	= exists("b:BASH_BashCmdLineArgs") ? ' '.b:BASH_BashCmdLineArgs.' ' : ''
	"
	"------------------------------------------------------------------------------
	"  Run : run from the vim command line (Linux only)
	"------------------------------------------------------------------------------
	"
	if s:BASH_OutputGvim == "vim"
		"
		" ----- visual mode ----------
		"
		if a:mode=="v"
			echomsg  ":!".s:BASH_BASH.l:bashCmdLineArgs." < ".tmpfile." -s ".l:arguments
			exe ":!".s:BASH_BASH.l:bashCmdLineArgs." < ".tmpfile." -s ".l:arguments
			call delete(tmpfile)
			return
		endif
		"
		" ----- normal mode ----------
		"
		call BASH_SaveOption( 'makeprg' )
		exe	":setlocal makeprg=".s:BASH_BASH
		exe	':setlocal errorformat='.s:BASH_Errorformat
		"
		if a:mode=="n"
			exe ":make ".l:bashCmdLineArgs.l:fullnameesc.l:arguments
		endif
		if &term == 'xterm'
			redraw!
		endif
		"
		call BASH_RestoreOption( 'makeprg' )
		exe	":botright cwindow"

		if l:currentbuffer != bufname("%") && a:mode=="n"
			let	pattern	= '^||.*\n\?'
			setlocal modifiable
			" remove the regular script output (appears as comment)
			if search(pattern) != 0
				silent exe ':%s/'.pattern.'//'
			endif
			" read the buffer back to have it parsed and used as the new error list
			silent exe ':cgetbuffer'
			setlocal nomodifiable
			silent exe	':cc'
		endif
		"
		exe	':setlocal errorformat='
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : redirect output to an output buffer
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == "buffer"

		let	l:currentbuffernr = bufnr("%")

		if l:currentbuffer ==  bufname("%")
			"
			if bufloaded(s:BASH_OutputBufferName) != 0 && bufwinnr(s:BASH_OutputBufferNumber)!=-1
				exe bufwinnr(s:BASH_OutputBufferNumber) . "wincmd w"
				" buffer number may have changed, e.g. after a 'save as'
				if bufnr("%") != s:BASH_OutputBufferNumber
					let s:BASH_OutputBufferNumber	= bufnr(s:BASH_OutputBufferName)
					exe ":bn ".s:BASH_OutputBufferNumber
				endif
			else
				silent exe ":new ".s:BASH_OutputBufferName
				let s:BASH_OutputBufferNumber=bufnr("%")
				setlocal noswapfile
				setlocal buftype=nofile
				setlocal syntax=none
				setlocal bufhidden=delete
				setlocal tabstop=8
			endif
			"
			" run script
			"
			setlocal	modifiable
			if a:mode=="n"
				if	s:MSWIN
					silent exe ":%!".s:BASH_BASH.l:bashCmdLineArgs.' "'.l:fullname.'" '.l:arguments
				else
					silent exe ":%!".s:BASH_BASH.l:bashCmdLineArgs." ".l:fullnameesc.l:arguments
				endif
			endif
			"
			if a:mode=="v"
				silent exe ":%!".s:BASH_BASH.l:bashCmdLineArgs." < ".tmpfile." -s ".l:arguments
			endif
			setlocal	nomodifiable
			"
			" stdout is empty / not empty
			"
			if line("$")==1 && col("$")==1
				silent	exe ":bdelete"
			else
				if winheight(winnr()) >= line("$")
					exe bufwinnr(l:currentbuffernr) . "wincmd w"
				endif
			endif
			"
		endif
	endif
	"
	"------------------------------------------------------------------------------
	"  Run : run in a detached xterm
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == 'xterm'
		"
		if	s:MSWIN
			exe ':!'.s:BASH_BASH.l:bashCmdLineArgs.' "'.l:fullname.'" '.l:arguments
		else
			if a:mode=='n'
				silent exe '!xterm -title '.l:fullnameesc.' '.s:BASH_XtermDefaults
							\			.' -e '.s:BASH_Wrapper.' '.l:bashCmdLineArgs.l:fullnameesc.l:arguments.' &'
			endif
			"
			if a:mode=="v"
				let titlestring	= l:fullnameesc.'\ lines\ \ '.line("'<").'\ -\ '.line("'>")
				silent exe ':!xterm -title '.titlestring.' '.s:BASH_XtermDefaults
							\			.' -e '.s:BASH_Wrapper.' '.l:bashCmdLineArgs.tmpfile.l:arguments.' &'
			endif
		endif
		"
	endif
	"
	if !has("gui_running") &&  v:progname != 'vim'
		redraw!
	endif
endfunction    " ----------  end of function BASH_Run  ----------
"
"------------------------------------------------------------------------------
"  Run : xterm geometry    {{{1
"------------------------------------------------------------------------------
function! BASH_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:BASH_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= BASH_Input("   xterm size (COLUMNS LINES) : ", geom, '' )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= BASH_Input(" + xterm size (COLUMNS LINES) : ", geom, '' )
	endwhile
	let answer  = substitute( answer, '^\s\+', "", "" )		 				" remove leading whitespaces
	let answer  = substitute( answer, '\s\+$', "", "" )						" remove trailing whitespaces
	let answer  = substitute( answer, '\s\+', "x", "" )						" replace inner whitespaces
	let s:BASH_XtermDefaults	= substitute( s:BASH_XtermDefaults, regex, "-geometry ".answer , "" )
endfunction		" ---------- end of function  BASH_XtermDefaults  ----------
"
"
"------------------------------------------------------------------------------
"  set : option    {{{1
"------------------------------------------------------------------------------
function! BASH_set (arg)
	let	s:BASH_SetCounter	= 0
	let	save_line					= line(".")
	let	actual_line				= 0
	"
	" search for the maximum option number (if any)
	normal gg
	while actual_line < search( s:BASH_Set_Txt."\\d\\+" )
		let actual_line	= line(".")
	 	let actual_opt  = matchstr( getline(actual_line), s:BASH_Set_Txt."\\d\\+" )
		let actual_opt  = strpart( actual_opt, strlen(s:BASH_Set_Txt),strlen(actual_opt)-strlen(s:BASH_Set_Txt))
		if s:BASH_SetCounter < actual_opt
			let	s:BASH_SetCounter = actual_opt
		endif
	endwhile
	let	s:BASH_SetCounter = s:BASH_SetCounter+1
	silent exe ":".save_line
	"
	" insert option
	let zz= "set -o ".a:arg."       # ".s:BASH_Set_Txt.s:BASH_SetCounter
	normal '<
	put! =zz
	let zz= "set +o ".a:arg."       # ".s:BASH_Set_Txt.s:BASH_SetCounter
	normal '>
	put  =zz
	let	s:BASH_SetCounter	= s:BASH_SetCounter+1
endfunction		" ---------- end of function  BASH_set  ----------
"
"------------------------------------------------------------------------------
"  shopt : option    {{{1
"------------------------------------------------------------------------------
function! BASH_shopt (arg)
	let	s:BASH_SetCounter	= 0
	let	save_line					= line(".")
	let	actual_line				= 0
	"
	" search for the maximum option number (if any)
	normal gg
	while actual_line < search( s:BASH_Shopt_Txt."\\d\\+" )
		let actual_line	= line(".")
	 	let actual_opt  = matchstr( getline(actual_line), s:BASH_Shopt_Txt."\\d\\+" )
		let actual_opt  = strpart( actual_opt, strlen(s:BASH_Shopt_Txt),strlen(actual_opt)-strlen(s:BASH_Shopt_Txt))
		if s:BASH_SetCounter < actual_opt
			let	s:BASH_SetCounter = actual_opt
		endif
	endwhile
	let	s:BASH_SetCounter = s:BASH_SetCounter+1
	silent exe ":".save_line
	"
	" insert option
	let zz= "shopt -s ".a:arg."       # ".s:BASH_Shopt_Txt.s:BASH_SetCounter."\n"
	normal '<
	put! =zz
	let zz= "shopt -u ".a:arg."       # ".s:BASH_Shopt_Txt.s:BASH_SetCounter
	normal '>
	put  =zz
	let	s:BASH_SetCounter	= s:BASH_SetCounter+1
endfunction		" ---------- end of function  BASH_shopt  ----------
"
"------------------------------------------------------------------------------
"  Run : Command line arguments    {{{1
"------------------------------------------------------------------------------
function! BASH_ScriptCmdLineArguments ()
	let filename = expand("%")
  if empty(filename)
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	prompt	= 'command line arguments for "'.filename.'" : '
	if exists("b:BASH_ScriptCmdLineArgs")
		let	b:BASH_ScriptCmdLineArgs= BASH_Input( prompt, b:BASH_ScriptCmdLineArgs , 'file' )
	else
		let	b:BASH_ScriptCmdLineArgs= BASH_Input( prompt , "", 'file' )
	endif
endfunction		" ---------- end of function  BASH_ScriptCmdLineArguments  ----------
"
"------------------------------------------------------------------------------
"  Bash-Idioms : read / edit code snippet    {{{1
"------------------------------------------------------------------------------
function! BASH_CodeSnippets(arg1)
	if isdirectory(s:BASH_CodeSnippets)
		"
		" read snippet file, put content below current line
		"
		if a:arg1 == "r"
			if has("gui_running") && s:BASH_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"read a code snippet",s:BASH_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:BASH_CodeSnippets, "file" )
			end
			if filereadable(l:snippetfile)
				let	linesread= line("$")
				"
				" Prevent the alternate buffer from being set to this files
				call BASH_SaveOption('cpoptions')
				setlocal cpoptions-=a
				:execute "read ".l:snippetfile
				call BASH_RestoreOption('cpoptions')
				"
				let	linesread= line("$")-linesread-1
				if linesread>=0 && match( l:snippetfile, '\.\(ni\|noindent\)$' ) < 0
					silent exe "normal =".linesread."+"
				endif
			endif
		endif
		"
		" update current buffer / split window / edit snippet file
		"
		if a:arg1 == "e"
			if has("gui_running") && s:BASH_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"edit a code snippet",s:BASH_CodeSnippets,"")
			else
				let	l:snippetfile=input("edit snippet ", s:BASH_CodeSnippets, "file" )
			end
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer or marked area into snippet file
		"
		if a:arg1 == "w" || a:arg1 == "wv"
			if has("gui_running") && s:BASH_GuiSnippetBrowser == 'gui'
				let	l:snippetfile=browse(0,"write a code snippet",s:BASH_CodeSnippets,"")
			else
				let	l:snippetfile=input("write snippet ", s:BASH_CodeSnippets, "file" )
			end
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				if a:arg1 == "w"
					:execute ":write! ".l:snippetfile
				else
					:execute ":*write! ".l:snippetfile
				end
			endif
		endif

	else
		echo "code snippet directory ".s:BASH_CodeSnippets." does not exist (please create it)"
	endif
endfunction		" ---------- end of function  BASH_CodeSnippets  ----------
"
"------------------------------------------------------------------------------
"  Run : hardcopy    {{{1
"------------------------------------------------------------------------------
function! BASH_Hardcopy (mode)
  let outfile = expand("%")
  if empty(outfile)
    redraw
    echohl WarningMsg | echo " no file name " | echohl None
    return
  endif
	let outdir	= getcwd()
	if filewritable(outdir) != 2
		let outdir	= $HOME
	endif
	if  !s:MSWIN
		let outdir	= outdir.'/'
	endif
  let old_printheader=&printheader
  exe  ':set printheader='.s:BASH_Printheader
  " ----- normal mode ----------------
  if a:mode=="n"
    silent exe  'hardcopy > '.outdir.outfile.'.ps'
    if  !s:MSWIN
      echo 'file "'.outfile.'" printed to "'.outdir.outfile.'.ps"'
    endif
  endif
  " ----- visual mode ----------------
  if a:mode=="v"
    silent exe  "*hardcopy > ".outdir.outfile.".ps"
    if  !s:MSWIN
      echo 'file "'.outfile.'" (lines '.line("'<").'-'.line("'>").') printed to "'.outdir.outfile.'.ps"'
    endif
  endif
  exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction   " ---------- end of function  BASH_Hardcopy  ----------
"
"------------------------------------------------------------------------------
"  Run : settings    {{{1
"------------------------------------------------------------------------------
function! BASH_Settings ()
	let	txt	=     "     Bash-Support settings\n\n"
  let txt = txt.'               author name :  "'.s:BASH_Macro['|AUTHOR|']."\"\n"
  let txt = txt.'                 authorref :  "'.s:BASH_Macro['|AUTHORREF|']."\"\n"
  let txt = txt.'                   company :  "'.s:BASH_Macro['|COMPANY|']."\"\n"
  let txt = txt.'          copyright holder :  "'.s:BASH_Macro['|COPYRIGHTHOLDER|']."\"\n"
  let txt = txt.'                     email :  "'.s:BASH_Macro['|EMAIL|']."\"\n"
  let txt = txt.'                   licence :  "'.s:BASH_Macro['|LICENSE|']."\"\n"
  let txt = txt.'              organization :  "'.s:BASH_Macro['|ORGANIZATION|']."\"\n"
  let txt = txt.'                   project :  "'.s:BASH_Macro['|PROJECT|']."\"\n"
	let txt = txt.'    code snippet directory :  "'.s:BASH_CodeSnippets."\"\n"
	" ----- template files  ------------------------
	let txt = txt.'            template style :  "'.s:BASH_ActualStyle."\"\n"
	let txt = txt.'       plugin installation :  "'.s:installation."\"\n"
	if s:installation == 'system'
		let txt = txt.'global template directory :  "'.s:BASH_GlobalTemplateDir."\"\n"
		if filereadable( s:BASH_LocalTemplateFile )
			let txt = txt.'  local template directory :  "'.s:BASH_LocalTemplateDir."\"\n"
		endif
	else
		let txt = txt.'  local template directory :  "'.s:BASH_LocalTemplateDir."\"\n"
	endif
	let txt = txt.'glob. syntax check options :  "'.s:BASH_SyntaxCheckOptionsGlob."\"\n"
	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let txt = txt.' buf. syntax check options :  "'.b:BASH_SyntaxCheckOptionsLocal."\"\n"
	endif
	" ----- dictionaries ------------------------
	if g:BASH_Dictionary_File != ""
		let ausgabe= &dictionary
		let ausgabe= substitute( ausgabe, ",", ",\n                            + ", "g" )
		let txt = txt."        dictionary file(s) :  ".ausgabe."\n"
	endif
	if exists("b:BASH_BashCmdLineArgs")
		let ausgabe = b:BASH_BashCmdLineArgs
	else
		let ausgabe = ""
	endif
	let txt = txt." Bash cmd.line argument(s) :  ".ausgabe."\n"
	let txt = txt."      current output dest. :  ".s:BASH_OutputGvim."\n"
	if	!s:MSWIN
		let txt = txt.'            xterm defaults :  '.s:BASH_XtermDefaults."\n"
	endif
	let txt = txt.'                    bashdb :  "'.s:BASH_bashdb."\"\n"
	let txt = txt."\n"
	let txt = txt."       Additional hot keys\n\n"
	let txt = txt."                  Shift-F1 :  help for builtin under the cursor \n"
	let txt = txt."                   Ctrl-F9 :  update file, run script           \n"
	let txt = txt."                    Alt-F9 :  update file, run syntax check     \n"
	let txt = txt."                  Shift-F9 :  edit command line arguments       \n"
	if	!s:MSWIN
	let txt = txt."                        F9 :  debug script (".s:BASH_Debugger.")\n"
	endif
	let	txt = txt."___________________________________________________________________________\n"
	let	txt = txt." Bash-Support, Version ".g:BASH_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction		" ---------- end of function  BASH_Settings  ----------
"
"------------------------------------------------------------------------------
"  Run : help bashsupport     {{{1
"------------------------------------------------------------------------------
function! BASH_HelpBASHsupport ()
	try
		:help bashsupport
	catch
		exe ':helptags '.s:plugin_dir.'/doc'
		:help bashsupport
	endtry
endfunction    " ----------  end of function BASH_HelpBASHsupport ----------

"------------------------------------------------------------------------------
"  date and time    {{{1
"------------------------------------------------------------------------------
function! BASH_InsertDateAndTime ( format )
	if a:format == 'd'
		return strftime( s:BASH_FormatDate )
	end
	if a:format == 't'
		return strftime( s:BASH_FormatTime )
	end
	if a:format == 'dt'
		return strftime( s:BASH_FormatDate ).' '.strftime( s:BASH_FormatTime )
	end
	if a:format == 'y'
		return strftime( s:BASH_FormatYear )
	end
endfunction    " ----------  end of function BASH_InsertDateAndTime  ----------

"------------------------------------------------------------------------------
"  BASH_HighlightJumpTargets
"------------------------------------------------------------------------------
function! BASH_HighlightJumpTargets ()
	if s:BASH_Ctrl_j == 'on'
		exe 'match Search /'.s:BASH_TemplateJumpTarget1.'\|'.s:BASH_TemplateJumpTarget2.'/'
	endif
endfunction    " ----------  end of function BASH_HighlightJumpTargets  ----------

"------------------------------------------------------------------------------
"  BASH_JumpCtrlJ     {{{1
"------------------------------------------------------------------------------
function! BASH_JumpCtrlJ ()
  let match	= search( s:BASH_TemplateJumpTarget1.'\|'.s:BASH_TemplateJumpTarget2, 'c' )
	if match > 0
		" remove the target
		call setline( match, substitute( getline('.'), s:BASH_TemplateJumpTarget1.'\|'.s:BASH_TemplateJumpTarget2, '', '' ) )
	else
		" try to jump behind parenthesis or strings in the current line
		if match( getline(".")[col(".") - 1], "[\]})\"'`]"  ) != 0
			call search( "[\]})\"'`]", '', line(".") )
		endif
		normal l
	endif
	return ''
endfunction    " ----------  end of function BASH_JumpCtrlJ  ----------

"------------------------------------------------------------------------------
"  BASH_ExpandUserMacros     {{{1
"------------------------------------------------------------------------------
function! BASH_ExpandUserMacros ( key )

	if has_key( s:BASH_Template[s:BASH_ActualStyle], a:key )
		let template 								= s:BASH_Template[s:BASH_ActualStyle][ a:key ]
	else
		let template 								= s:BASH_Template['default'][ a:key ]
	endif
	let	s:BASH_ExpansionCounter	= {}										" reset the expansion counter

  "------------------------------------------------------------------------------
  "  renew the predefined macros and expand them
	"  can be replaced, with e.g. |?DATE|
  "------------------------------------------------------------------------------
	let	s:BASH_Macro['|BASENAME|']	= toupper(expand("%:t:r"))
  let s:BASH_Macro['|DATE|']  		= BASH_DateAndTime('d')
  let s:BASH_Macro['|FILENAME|']	= expand("%:t")
  let s:BASH_Macro['|PATH|']  		= expand("%:p:h")
  let s:BASH_Macro['|SUFFIX|']		= expand("%:e")
  let s:BASH_Macro['|TIME|']  		= BASH_DateAndTime('t')
  let s:BASH_Macro['|YEAR|']  		= BASH_DateAndTime('y')

  "------------------------------------------------------------------------------
  "  delete jump targets if mapping for C-j is off
  "------------------------------------------------------------------------------
	if s:BASH_Ctrl_j == 'off'
		let template	= substitute( template, s:BASH_TemplateJumpTarget1.'\|'.s:BASH_TemplateJumpTarget2, '', 'g' )
	endif

  "------------------------------------------------------------------------------
  "  look for replacements
  "------------------------------------------------------------------------------
	while match( template, s:BASH_ExpansionRegex ) != -1
		let macro				= matchstr( template, s:BASH_ExpansionRegex )
		let replacement	= substitute( macro, '?', '', '' )
		let template		= substitute( template, macro, replacement, "g" )

		let match	= matchlist( macro, s:BASH_ExpansionRegex )

		if !empty( match[1] )
			let macroname	= '|'.match[1].'|'
			"
			" notify flag action, if any
			let flagaction	= ''
			if has_key( s:BASH_MacroFlag, match[2] )
				let flagaction	= ' (-> '.s:BASH_MacroFlag[ match[2] ].')'
			endif
			"
			" ask for a replacement
			if has_key( s:BASH_Macro, macroname )
				let	name	= BASH_Input( match[1].flagaction.' : ', BASH_ApplyFlag( s:BASH_Macro[macroname], match[2] ) )
			else
				let	name	= BASH_Input( match[1].flagaction.' : ', '' )
			endif
			if empty(name)
				return ""
			endif
			"
			" keep the modified name
			let s:BASH_Macro[macroname]  			= BASH_ApplyFlag( name, match[2] )
		endif
	endwhile

  "------------------------------------------------------------------------------
  "  do the actual macro expansion
	"  loop over the macros found in the template
  "------------------------------------------------------------------------------
	while match( template, s:BASH_NonExpansionRegex ) != -1

		let macro			= matchstr( template, s:BASH_NonExpansionRegex )
		let match			= matchlist( macro, s:BASH_NonExpansionRegex )

		if !empty( match[1] )
			let macroname	= '|'.match[1].'|'

			if has_key( s:BASH_Macro, macroname )
				"-------------------------------------------------------------------------------
				"   check for recursion
				"-------------------------------------------------------------------------------
				if has_key( s:BASH_ExpansionCounter, macroname )
					let	s:BASH_ExpansionCounter[macroname]	+= 1
				else
					let	s:BASH_ExpansionCounter[macroname]	= 0
				endif
				if s:BASH_ExpansionCounter[macroname]	>= s:BASH_ExpansionLimit
					echomsg "recursion terminated for recursive macro ".macroname
					return template
				endif
				"-------------------------------------------------------------------------------
				"   replace
				"-------------------------------------------------------------------------------
				let replacement = BASH_ApplyFlag( s:BASH_Macro[macroname], match[2] )
				let template 		= substitute( template, macro, replacement, "g" )
			else
				"
				" macro not yet defined
				let s:BASH_Macro['|'.match[1].'|']  		= ''
			endif
		endif

	endwhile

  return template
endfunction    " ----------  end of function BASH_ExpandUserMacros  ----------

"------------------------------------------------------------------------------
"  BASH_ApplyFlag     {{{1
"------------------------------------------------------------------------------
function! BASH_ApplyFlag ( val, flag )
	"
	" l : lowercase
	if a:flag == ':l'
		return  tolower(a:val)
	endif
	"
	" u : uppercase
	if a:flag == ':u'
		return  toupper(a:val)
	endif
	"
	" c : capitalize
	if a:flag == ':c'
		return  toupper(a:val[0]).a:val[1:]
	endif
	"
	" L : legalized name
	if a:flag == ':L'
		return  BASH_LegalizeName(a:val)
	endif
	"
	" flag not valid
	return a:val
endfunction    " ----------  end of function BASH_ApplyFlag  ----------
"
"------------------------------------------------------------------------------
"  BASH_ExpandSingleMacro     {{{1
"------------------------------------------------------------------------------
function! BASH_ExpandSingleMacro ( val, macroname, replacement )
  return substitute( a:val, escape(a:macroname, '$' ), a:replacement, "g" )
endfunction    " ----------  end of function BASH_ExpandSingleMacro  ----------

"------------------------------------------------------------------------------
"  BASH_InsertMacroValue     {{{1
"------------------------------------------------------------------------------
function! BASH_InsertMacroValue ( key )
	if s:BASH_Macro['|'.a:key.'|'] == ''
		echomsg 'the tag |'.a:key.'| is empty'
		return
	endif
	"
	if &foldenable && foldclosed(".") >= 0
		echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
		return
	endif
	if col(".") > 1
		exe 'normal! a'.s:BASH_Macro['|'.a:key.'|']
	else
		exe 'normal! i'.s:BASH_Macro['|'.a:key.'|']
	endif
endfunction    " ----------  end of function BASH_InsertMacroValue  ----------

"------------------------------------------------------------------------------
"  insert date and time     {{{1
"------------------------------------------------------------------------------
function! BASH_InsertDateAndTime ( format )
	if &foldenable && foldclosed(".") >= 0
		echohl WarningMsg | echomsg s:MsgInsNotAvail  | echohl None
		return ""
	endif
	if col(".") > 1
		exe 'normal a'.BASH_DateAndTime(a:format)
	else
		exe 'normal i'.BASH_DateAndTime(a:format)
	endif
endfunction    " ----------  end of function BASH_InsertDateAndTime  ----------

"------------------------------------------------------------------------------
"  generate date and time     {{{1
"------------------------------------------------------------------------------
function! BASH_DateAndTime ( format )
	if a:format == 'd'
		return strftime( s:BASH_FormatDate )
	elseif a:format == 't'
		return strftime( s:BASH_FormatTime )
	elseif a:format == 'dt'
		return strftime( s:BASH_FormatDate ).' '.strftime( s:BASH_FormatTime )
	elseif a:format == 'y'
		return strftime( s:BASH_FormatYear )
	endif
endfunction    " ----------  end of function BASH_DateAndTime  ----------
"
"------------------------------------------------------------------------------
"  BASH_CreateMenusDelayed   {{{1
"------------------------------------------------------------------------------
let s:BASH_MenusVisible = 'no'								" state : 0 = not visible / 1 = visible
"
function! BASH_CreateMenusDelayed ()
	if s:BASH_CreateMenusDelayed == 'yes' && s:BASH_MenusVisible == 'no'
		call BASH_CreateGuiMenus()
	endif
endfunction    " ----------  end of function BASH_CreateMenusDelayed  ----------
"
"------------------------------------------------------------------------------
"  BASH_CreateGuiMenus    {{{1
"------------------------------------------------------------------------------
function! BASH_CreateGuiMenus ()
	if s:BASH_MenusVisible == 'no'
		aunmenu <silent> &Tools.Load\ Bash\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1021 &Tools.Unload\ Bash\ Support <C-C>:call BASH_RemoveGuiMenus()<CR>
		call BASH_InitMenu()
		let s:BASH_MenusVisible = 'yes'
	endif
endfunction    " ----------  end of function BASH_CreateGuiMenus  ----------

"------------------------------------------------------------------------------
"  BASH_ToolMenu    {{{1
"------------------------------------------------------------------------------
function! BASH_ToolMenu ()
	amenu   <silent> 40.1000 &Tools.-SEP100- :
	amenu   <silent> 40.1021 &Tools.Load\ Bash\ Support <C-C>:call BASH_CreateGuiMenus()<CR>
endfunction    " ----------  end of function BASH_ToolMenu  ----------

"------------------------------------------------------------------------------
"  BASH_RemoveGuiMenus    {{{1
"------------------------------------------------------------------------------
function! BASH_RemoveGuiMenus ()
	if s:BASH_MenusVisible == 'yes'
		exe "aunmenu <silent> ".s:BASH_Root
		"
		aunmenu <silent> &Tools.Unload\ Bash\ Support
		call BASH_ToolMenu()
		"
		let s:BASH_MenusVisible = 'no'
	endif
endfunction    " ----------  end of function BASH_RemoveGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  BASH_SaveOption    {{{1
"  param 1 : option name
"  param 2 : characters to be escaped (optional)
"------------------------------------------------------------------------------
function! BASH_SaveOption ( option, ... )
	exe 'let escaped =&'.a:option
	if a:0 == 0
		let escaped	= escape( escaped, ' |"\' )
	else
		let escaped	= escape( escaped, ' |"\'.a:1 )
	endif
	let s:BASH_saved_option[a:option]	= escaped
endfunction    " ----------  end of function BASH_SaveOption  ----------
"
"------------------------------------------------------------------------------
"  BASH_RestoreOption    {{{1
"------------------------------------------------------------------------------
function! BASH_RestoreOption ( option )
	exe ':setlocal '.a:option.'='.s:BASH_saved_option[a:option]
endfunction    " ----------  end of function BASH_RestoreOption  ----------
"
"================================================================================
"  show / hide the menus   {{{1
"  define key mappings (gVim only)
"
"================================================================================
"
call BASH_ToolMenu()
"
if s:BASH_LoadMenus == 'yes' && s:BASH_CreateMenusDelayed == 'no'
	call BASH_CreateGuiMenus()
endif
"
nmap    <silent>  <Leader>lbs             :call BASH_CreateGuiMenus()<CR>
nmap    <silent>  <Leader>ubs             :call BASH_RemoveGuiMenus()<CR>
"
"
"------------------------------------------------------------------------------
"  Automated header insertion   {{{1
"------------------------------------------------------------------------------
"
if has("autocmd")
	"
	if	s:MSWIN
		" needed to turn off CYGWIN error messages :
		"
		exe "autocmd BufNewFile,BufRead           *.sh set fileformat=".s:BASH_FileFormat
	endif
	"
	autocmd BufNewFile,BufRead           *.sh call BASH_CreateMenusDelayed()
	"
	" Bash-script : insert header, write file, make it executable
	"
	if !exists( 'g:BASH_AlsoBash' )
		"
		autocmd BufNewFile,BufRead           *.sh set filetype=sh
		" style is taken from s:BASH_Style
		autocmd BufNewFile                   *.sh call BASH_InsertTemplate("comment.file-description")
		autocmd BufRead                      *.sh call BASH_HighlightJumpTargets()
		"
	else
		"
		" g:BASH_AlsoBash is a list of filename patterns
		"
		if type( g:BASH_AlsoBash ) == 3
			for pattern in g:BASH_AlsoBash
				exe "autocmd BufNewFile,BufRead          ".pattern." set filetype=sh"
				" style is taken from s:BASH_Style
				exe "autocmd BufNewFile                  ".pattern." call BASH_InsertTemplate('comment.file-description')"
				exe 'autocmd BufRead                     ".pattern." call BASH_HighlightJumpTargets()'
			endfor
		endif
		"
		" g:BASH_AlsoBash is a dictionary ( "file pattern" : "template style" )
		"
		if type( g:BASH_AlsoBash ) == 4
			for [ pattern, stl ] in items( g:BASH_AlsoBash )
				exe "autocmd BufNewFile,BufRead          ".pattern." set filetype=sh"
				" style is defined by the file extensions
				exe "autocmd BufNewFile,BufRead,BufEnter ".pattern." call BASH_Style( '".stl."' )"
				exe "autocmd BufNewFile                  ".pattern." call BASH_InsertTemplate('comment.file-description')"
				exe 'autocmd BufRead                     ".pattern." call BASH_HighlightJumpTargets()'
			endfor
		endif
		"
	endif
endif " has("autocmd")
"
"------------------------------------------------------------------------------
" vim: tabstop=2 shiftwidth=2 foldmethod=marker
