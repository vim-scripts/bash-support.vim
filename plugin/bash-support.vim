"#########################################################################################
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
"        License:  Copyright (c) 2001-2008, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"       Revision:  $Id: bash-support.vim,v 1.20 2008/08/02 16:20:40 mehner Exp $
"
"------------------------------------------------------------------------------
"
" Prevent duplicate loading:
"
if exists("g:BASH_Version") || &cp
 finish
endif
let g:BASH_Version= "2.7"  						" version number of this script; do not change
"
if v:version < 700
  echohl WarningMsg | echo 'plugin bash-support.vim needs Vim version >= 7'| echohl None
endif
"
"#########################################################################################
"
"  Global variables (with default values) which can be overridden.
"
"  Key word completion is enabled by the filetype plugin 'sh.vim'
"  g:BASH_Dictionary_File  must be global
" ==========  Linux/Unix  ======================================================
"
" user / system wide installation
"
if match( expand("<sfile>"), $VIM ) >= 0
	"
	" system wide installation
	let s:plugin_dir  = $VIM.'/vimfiles/'
else
	"
	" user installation assumed
	let s:plugin_dir  = $HOME.'/.vim/'
end
"
"------------------------------------------------------------------------------
"
if !exists("g:BASH_Dictionary_File")
	let g:BASH_Dictionary_File     = s:plugin_dir.'bash-support/wordlists/bash.list'
endif
"
"  Modul global variables    {{{1
"
let s:BASH_AuthorName              = ""
let s:BASH_AuthorRef               = ""
let s:BASH_Company                 = ""
let s:BASH_CopyrightHolder         = ""
let s:BASH_Email                   = ""
let s:BASH_Project                 = ""
"
let s:BASH_CodeSnippets            = $HOME."/.vim/bash-support/codesnippets/"
let s:BASH_Debugger                = 'term'
let s:BASH_DoOnNewLine             = 'no'
let s:BASH_LineEndCommColDefault   = 49
let s:BASH_LoadMenus               = "yes"
let s:BASH_MenuHeader              = "yes"
let s:BASH_OutputGvim              = "vim"
let s:BASH_Root                    = 'B&ash.'         " the name of the root menu of this plugin
let s:BASH_SyntaxCheckOptionsGlob  = ""
let s:BASH_Template_Directory      = s:plugin_dir."bash-support/templates/"
let s:BASH_Template_File           = "bash-file-header"
let s:BASH_Template_Frame          = "bash-frame"
let s:BASH_Template_Function       = "bash-function-description"
let s:BASH_XtermDefaults           = "-fa courier -fs 12 -geometry 80x24"
let s:BASH_Printheader             = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
let s:BASH_Wrapper                 = s:plugin_dir.'bash-support/scripts/wrapper.sh'
"
let s:BASH_FormatDate						= '%x'
let s:BASH_FormatTime						= '%X %Z'
let s:BASH_FormatYear						= '%Y'
"
"
"------------------------------------------------------------------------------
"  Some variables for internal use only
"------------------------------------------------------------------------------
let s:BASH_Active         = -1                    " state variable controlling the Bash-menus
let s:BASH_Errorformat    = '%f:\ line\ %l:\ %m'
let s:BASH_SetCounter     = 0                     "
let s:BASH_Set_Txt        = "SetOptionNumber_"
let s:BASH_Shopt_Txt      = "ShoptOptionNumber_"
let s:escfilename         = ' \%#[]'
"
" Bash shopt options (GNU Bash-3.2, manual: 2006 September 28)
"
let s:BASH_ShoptAllowed =                     "cdable_vars:cdspell:checkhash:checkwinsize:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."cmdhist:dotglob:execfail:expand_aliases:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."extdebug:extglob:extquote:failglob:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."force_fignore:gnu_errfmt:histappend:histreedit:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."histverify:hostcomplete:huponexit:interactive_comments:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."lithist:login_shell:mailwarn:no_empty_cmd_completion:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."nocaseglob:nocasematch:nocasematch:nullglob:progcomp:promptvars:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."restricted_shell:shift_verbose:sourcepath:xpg_echo:"
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
call BASH_CheckGlobal("BASH_AuthorName            ")
call BASH_CheckGlobal("BASH_AuthorRef             ")
call BASH_CheckGlobal("BASH_CodeSnippets          ")
call BASH_CheckGlobal("BASH_Company               ")
call BASH_CheckGlobal("BASH_CopyrightHolder       ")
call BASH_CheckGlobal("BASH_Debugger              ")
call BASH_CheckGlobal("BASH_DoOnNewLine           ")
call BASH_CheckGlobal("BASH_Email                 ")
call BASH_CheckGlobal("BASH_FormatDate            ")
call BASH_CheckGlobal("BASH_FormatTime            ")
call BASH_CheckGlobal("BASH_FormatYear            ")
call BASH_CheckGlobal("BASH_LineEndCommColDefault ")
call BASH_CheckGlobal("BASH_LoadMenus             ")
call BASH_CheckGlobal("BASH_MenuHeader            ")
call BASH_CheckGlobal("BASH_OutputGvim            ")
call BASH_CheckGlobal("BASH_Printheader           ")
call BASH_CheckGlobal("BASH_Project               ")
call BASH_CheckGlobal("BASH_Root                  ")
call BASH_CheckGlobal("BASH_SyntaxCheckOptionsGlob")
call BASH_CheckGlobal("BASH_Template_Directory    ")
call BASH_CheckGlobal("BASH_Template_File         ")
call BASH_CheckGlobal("BASH_Template_Frame        ")
call BASH_CheckGlobal("BASH_Template_Function     ")
call BASH_CheckGlobal("BASH_XtermDefaults         ")
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
"  BASH Menu Initialization      {{{1
"------------------------------------------------------------------------------
function!	BASH_InitMenu ()
	"
	"===============================================================================================
	"----- Menu : C main menu entry -------------------------------------------   {{{2
	"===============================================================================================
	"
	if has("gui_running")
		"===============================================================================================
		"----- Menu : root menu  ---------------------------------------------------------------------
		"===============================================================================================
		if s:BASH_Root != ""
			if s:BASH_MenuHeader == "yes"
				exe "amenu   ".s:BASH_Root.'Bash          <Nop>'
				exe "amenu   ".s:BASH_Root.'-Sep0-        :'
			endif
		endif
		"
		"-------------------------------------------------------------------------------
		" menu Comments   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu   ".s:BASH_Root.'&Comments.Comments<Tab>Bash   <Nop>'
			exe "amenu   ".s:BASH_Root.'&Comments.-Sep0-              :'
		endif
		exe " menu           ".s:BASH_Root.'&Comments.end-of-&line\ comment                    :call BASH_LineEndComment()<CR>A'
		exe "imenu           ".s:BASH_Root.'&Comments.end-of-&line\ comment               <Esc>:call BASH_LineEndComment()<CR>A'
		exe "vmenu <silent>  ".s:BASH_Root.'&Comments.end-of-&line\ comment               <Esc>:call BASH_MultiLineEndComments()<CR>A'

		exe " menu <silent>  ".s:BASH_Root.'&Comments.ad&just\ end-of-line\ com\.              :call BASH_AdjustLineEndComm("a")<CR>'
		exe "imenu <silent>  ".s:BASH_Root.'&Comments.ad&just\ end-of-line\ com\.         <Esc>:call BASH_AdjustLineEndComm("a")<CR>'
		exe "vmenu <silent>  ".s:BASH_Root.'&Comments.ad&just\ end-of-line\ com\.         <Esc>:call BASH_AdjustLineEndComm("v")<CR>'

		exe " menu <silent>  ".s:BASH_Root.'&Comments.&set\ end-of-line\ com\.\ col\.          :call BASH_GetLineEndCommCol()<CR>'
		exe "imenu <silent>  ".s:BASH_Root.'&Comments.&set\ end-of-line\ com\.\ col\.     <Esc>:call BASH_GetLineEndCommCol()<CR>'

		exe " menu <silent>  ".s:BASH_Root.'&Comments.&frame\ comment                          :call BASH_CommentTemplates("frame")<CR>'
		exe " menu <silent>  ".s:BASH_Root.'&Comments.f&unction\ description                   :call BASH_CommentTemplates("function")<CR>'
		exe " menu <silent>  ".s:BASH_Root.'&Comments.file\ &header                            :call BASH_CommentTemplates("header")<CR>'

		exe "imenu <silent>  ".s:BASH_Root.'&Comments.&frame\ comment                     <Esc>:call BASH_CommentTemplates("frame")<CR>'
		exe "imenu <silent>  ".s:BASH_Root.'&Comments.f&unction\ description              <Esc>:call BASH_CommentTemplates("function")<CR>'
		exe "imenu <silent>  ".s:BASH_Root.'&Comments.file\ &header                       <Esc>:call BASH_CommentTemplates("header")<CR>'

		exe "amenu ".s:BASH_Root.'&Comments.-Sep1-                    :'
    exe " menu <silent>  ".s:BASH_Root."&Comments.toggle\\ &comment         :call BASH_CommentToggle()<CR>j"
    exe "imenu <silent>  ".s:BASH_Root."&Comments.toggle\\ &comment    <Esc>:call BASH_CommentToggle()<CR>j"
    exe "vmenu <silent>  ".s:BASH_Root."&Comments.toggle\\ &comment    <Esc>:'<,'>call BASH_CommentToggle()<CR>j"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP2-                    :'
		exe " menu ".s:BASH_Root.'&Comments.&date                     a<C-R>=BASH_InsertDateAndTime("d")<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.&date                      <C-R>=BASH_InsertDateAndTime("d")<CR>'
		exe " menu ".s:BASH_Root.'&Comments.date\ &time               a<C-R>=BASH_InsertDateAndTime("dt")<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.date\ &time                <C-R>=BASH_InsertDateAndTime("dt")<CR>'
		"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP3-                    :'
		"
		exe " noremenu ".s:BASH_Root.'&Comments.&echo\ "<line>"	  			 ^iecho<Space>"<End>"<Esc>j'
		exe " noremenu ".s:BASH_Root.'&Comments.&remove\ echo            0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR>j'
		exe "inoremenu ".s:BASH_Root.'&Comments.&echo\ "<line>"	  	<C-C>^iecho<Space>"<End>"<Esc>j'
		exe "inoremenu ".s:BASH_Root.'&Comments.&remove\ echo       <C-C>0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR>j'
		"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP4-                    :'
		"
		"----- Submenu : BASH-Comments : Keywords  ----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.Comments-1<Tab>Bash   <Nop>'
			exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.-Sep1-                :'
		endif
		exe " menu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&BUG                   $:call BASH_CommentClassified("BUG")     <CR>kgJA'
		exe " menu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&TODO                  $:call BASH_CommentClassified("TODO")    <CR>kgJA'
		exe " menu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.T&RICKY                $:call BASH_CommentClassified("TRICKY")  <CR>kgJA'
		exe " menu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&WARNING               $:call BASH_CommentClassified("WARNING") <CR>kgJA'
		exe " menu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&new\ keyword          $:call BASH_CommentClassified("")        <CR>kgJf:a'
		"
		exe "imenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&BUG              <C-C>$:call BASH_CommentClassified("BUG")     <CR>kgJA'
		exe "imenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&TODO             <C-C>$:call BASH_CommentClassified("TODO")    <CR>kgJA'
		exe "imenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.T&RICKY           <C-C>$:call BASH_CommentClassified("TRICKY")  <CR>kgJA'
		exe "imenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&WARNING          <C-C>$:call BASH_CommentClassified("WARNING") <CR>kgJA'
		exe "imenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&new\ keyword     <C-C>$:call BASH_CommentClassified("")        <CR>kgJf:a'
		"
		"----- Submenu : BASH-Comments : Tags  ----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).Comments-2<Tab>Bash  <Nop>'
			exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).-Sep1-               :'
		endif
		"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR                a'.s:BASH_AuthorName."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF             a'.s:BASH_AuthorRef."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY               a'.s:BASH_Company."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER       a'.s:BASH_CopyrightHolder."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL                 a'.s:BASH_Email."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT               a'.s:BASH_Project."<Esc>"

		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:BASH_AuthorName
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:BASH_AuthorRef
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>a'.s:BASH_Company
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:BASH_CopyrightHolder
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>a'.s:BASH_Email
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>a'.s:BASH_Project
		"
		exe " menu ".s:BASH_Root.'&Comments.&vim\ modeline               :call BASH_CommentVimModeline()<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.&vim\ modeline          <Esc>:call BASH_CommentVimModeline()<CR>'
		"
		"-------------------------------------------------------------------------------
		" menu Statements   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Statements.Statements<Tab>Bash  <Nop>'
			exe "amenu ".s:BASH_Root.'&Statements.-Sep0-               :'
		endif

		exe "anoremenu ".s:BASH_Root.'&Statements.&case			     ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a'
		exe "anoremenu ".s:BASH_Root.'&Statements.e&lif			     oelif <CR>then<Esc>1kA'
		exe "anoremenu ".s:BASH_Root.'&Statements.&for			     :call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i'
		exe "anoremenu ".s:BASH_Root.'&Statements.&if				     :call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i'
		exe "anoremenu ".s:BASH_Root.'&Statements.if-&else	     :call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i'
		exe "anoremenu ".s:BASH_Root.'&Statements.&select		     :call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i'
		exe "anoremenu ".s:BASH_Root.'&Statements.un&til		     :call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i'
		exe "anoremenu ".s:BASH_Root.'&Statements.&while		     :call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i'

		exe "inoremenu ".s:BASH_Root.'&Statements.&for			<Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "a" )<CR>i'
		exe "inoremenu ".s:BASH_Root.'&Statements.&if				<Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "a" )<CR>i'
		exe "inoremenu ".s:BASH_Root.'&Statements.if-&else	<Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "a" )<CR>i'
		exe "inoremenu ".s:BASH_Root.'&Statements.&select		<Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "a" )<CR>i'
		exe "inoremenu ".s:BASH_Root.'&Statements.un&til		<Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "a" )<CR>i'
		exe "inoremenu ".s:BASH_Root.'&Statements.&while		<Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "a" )<CR>i'

		exe "vnoremenu ".s:BASH_Root.'&Statements.&for			<Esc>:call BASH_FlowControl( "for _ in ",    "do",   "done",     "v" )<CR>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.&if				<Esc>:call BASH_FlowControl( "if _ ",        "then", "fi",       "v" )<CR>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.if-&else	<Esc>:call BASH_FlowControl( "if _ ",        "then", "else\nfi", "v" )<CR>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.&select		<Esc>:call BASH_FlowControl( "select _ in ", "do",   "done",     "v" )<CR>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.un&til		<Esc>:call BASH_FlowControl( "until _ ",     "do",   "done",     "v" )<CR>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.&while		<Esc>:call BASH_FlowControl( "while _ ",     "do",   "done",     "v" )<CR>'
		"
		exe "anoremenu ".s:BASH_Root.'&Statements.-SEP3-          :'

		exe "anoremenu ".s:BASH_Root.'&Statements.&break					     obreak '
		exe "anoremenu ".s:BASH_Root.'&Statements.co&ntinue				     ocontinue '
		exe "anoremenu ".s:BASH_Root.'&Statements.e&xit						     oexit '
		exe "anoremenu ".s:BASH_Root.'&Statements.f&unction				     :call BASH_CodeFunction("a")<CR>O'
		exe "anoremenu ".s:BASH_Root.'&Statements.&return					     oreturn '
		exe "anoremenu ".s:BASH_Root.'&Statements.s&hift					     oshift '
		exe "anoremenu ".s:BASH_Root.'&Statements.tra&p						     otrap '
		"
		exe "inoremenu ".s:BASH_Root.'&Statements.&break					<Esc>obreak '
		exe "inoremenu ".s:BASH_Root.'&Statements.co&ntinue				<Esc>ocontinue '
		exe "inoremenu ".s:BASH_Root.'&Statements.e&xit						<Esc>oexit '
		exe "inoremenu ".s:BASH_Root.'&Statements.f&unction				<Esc>:call BASH_CodeFunction("a")<CR>O'
		exe "inoremenu ".s:BASH_Root.'&Statements.&return					<Esc>oreturn '
		exe "inoremenu ".s:BASH_Root.'&Statements.s&hift					<Esc>oshift '
		exe "inoremenu ".s:BASH_Root.'&Statements.tra&p						<Esc>otrap '
		"
		exe "vnoremenu ".s:BASH_Root.'&Statements.f&unction				<Esc>:call BASH_CodeFunction("v")<CR>'
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

		exe " noremenu ".s:BASH_Root.'&Statements.$&[[\.\.\.]]		a$[[]]<Esc>hi'
		exe "inoremenu ".s:BASH_Root.'&Statements.$&[[\.\.\.]]		 $[[]]<Left><Left>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.$&[[\.\.\.]]		s$[[]]<Esc>hP'
		"
		exe "anoremenu ".s:BASH_Root.'&Statements.ech&o\ -e\ "\\n"		oecho<Space>-e<Space>"\n"<Esc>2hi'
		exe "inoremenu ".s:BASH_Root.'&Statements.ech&o\ -e\ "\\n"		 echo<Space>-e<Space>"\n"<Esc>2hi'
		exe "vnoremenu ".s:BASH_Root.'&Statements.ech&o\ -e\ "\\n" 		secho<Space>-e<Space>"\n"<Esc>2hP'
		"
		exe "amenu  ".s:BASH_Root.'&Statements.-SEP5-                                 :'
		exe "anoremenu ".s:BASH_Root.'&Statements.&array\ elem\.<Tab>${\ [@]}      		a${[@]}<Left><Left><Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&Statements.&array\ elem\.<Tab>${\ [@]}      		 ${[@]}<Left><Left><Left><Left>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.&array\ elem\.<Tab>${\ [@]}      		s${[@]}<Left><Left><Left><Esc>P'

		exe "anoremenu ".s:BASH_Root.'&Statements.arra&y\ (1\ word)<Tab>${\ [*]}			a${[*]}<Left><Left><Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&Statements.arra&y\ (1\ word)<Tab>${\ [*]}			 ${[*]}<Left><Left><Left><Left>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.arra&y\ (1\ word)<Tab>${\ [*]}			s${[*]}<Left><Left><Left><Esc>P'

		exe "anoremenu ".s:BASH_Root.'&Statements.no\.\ of\ ele&m\.<Tab>${#\ [@]}			a${#[*]}<Left><Left><Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&Statements.no\.\ of\ ele&m\.<Tab>${#\ [@]}			 ${#[*]}<Left><Left><Left><Left>'
		exe "vnoremenu ".s:BASH_Root.'&Statements.no\.\ of\ ele&m\.<Tab>${#\ [@]}			s${#[*]}<Left><Left><Left><Esc>P'

    exe "anoremenu ".s:BASH_Root.'&Statements.list\ of\ in&dices<tab>${!\ [*]}   	a${![*]}<Left><Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&Statements.list\ of\ in&dices<tab>${!\ [*]}   	 ${![*]}<Left><Left><Left><Left>'
    exe "vnoremenu ".s:BASH_Root.'&Statements.list\ of\ in&dices<tab>${!\ [*]}   	s${![*]}<Left><Left><Left><Esc>P'
		"
		if s:BASH_CodeSnippets != ""
			exe "amenu  ".s:BASH_Root.'&Statements.-SEP6-                    		  :'
			exe " menu  <silent> ".s:BASH_Root.'&Statements.read\ code\ snippet        :call BASH_CodeSnippets("r")<CR>'
			exe " menu  <silent> ".s:BASH_Root.'&Statements.write\ code\ snippet       :call BASH_CodeSnippets("w")<CR>'
			exe " menu  <silent> ".s:BASH_Root.'&Statements.edit\ code\ snippet        :call BASH_CodeSnippets("e")<CR>'
			exe "imenu  <silent> ".s:BASH_Root.'&Statements.read\ code\ snippet   <C-C>:call BASH_CodeSnippets("r")<CR>'
			exe "imenu  <silent> ".s:BASH_Root.'&Statements.write\ code\ snippet  <C-C>:call BASH_CodeSnippets("w")<CR>'
			exe "imenu  <silent> ".s:BASH_Root.'&Statements.edit\ code\ snippet   <C-C>:call BASH_CodeSnippets("e")<CR>'
			exe "vmenu  <silent> ".s:BASH_Root.'&Statements.write\ code\ snippet  <C-C>:call BASH_CodeSnippets("wv")<CR>'
		endif
		"
		"-------------------------------------------------------------------------------
		" menu Tests   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.Tests-0<Tab>Bash   <Nop>'
			exe "amenu ".s:BASH_Root.'&Tests.-Sep0-             :'
		endif
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e															    					a[ -e  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		a[ -s  ]<Left><Left>'
		"
		exe "inoremenu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e																						[ -e  ]<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		[ -s  ]<Left><Left>'
		"
		exe "imenu ".s:BASH_Root.'&Tests.-Sep1-                         :'
		"
		"---------- submenu arithmetic tests -----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.Tests-1<Tab>Bash   <Nop>'
			exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.-Sep0-          :'
		endif
		exe "	noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq									 a[  -eq  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne									 a[  -ne  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt											 a[  -lt  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le			 a[  -le  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt									 a[  -gt  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge		 a[  -ge  ]<Esc>F-hi'
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
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.Tests-2<Tab>Bash      <Nop>'
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.-Sep0-         :'
		endif
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r								 a[ -r  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w								 a[ -w  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x							 a[ -x  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u			 a[ -u  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g			 a[ -g  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k a[ -k  ]<Left><Left>'
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
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.Tests-3<Tab>Bash               <Nop>'
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.-Sep0-                         :'
		endif
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a						<Esc>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			a[ -b  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	a[ -c  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								a[ -d  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>-p			a[ -p  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						a[ -f  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										a[ -S  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						a[ -L  ]<Left><Left>'
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
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.Tests-4<Tab>Bash               <Nop>'
			exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.-Sep0-                         :'
		endif
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z									  	  a[ -z  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n									  a[ -n  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal<Tab>==															 a[  ==  ]<Esc>bhi'
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=													 a[  !=  ]<Esc>bhi'
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><		  a[  <  ]<Esc>bhi'
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>			  a[  >  ]<Esc>bhi'
		exe "	noremenu ".s:BASH_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												 a[[  =~  ]]<Esc>2bhi'
		"
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z											  [ -z  ]<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n									  [ -n  ]<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal<Tab>==															 [  ==  ]<Esc>bhi'
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=													 [  !=  ]<Esc>bhi'
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><		  [  <  ]<Esc>bhi'
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>			  [  >  ]<Esc>bhi'
		exe "inoremenu ".s:BASH_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												 [[  =~  ]]<Esc>2bhi'
		"
		exe "	noremenu ".s:BASH_Root.'&Tests.-Sep2-                         :'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O							 a[ -O  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G							 a[ -G  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N	 a[ -N  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t				 a[ -t  ]<Left><Left>'
		exe "	noremenu ".s:BASH_Root.'&Tests.-Sep3-                         :'
		exe "	noremenu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt								 a[  -nt  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																			 a[  -ot  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef		 a[  -ef  ]<Esc>F-hi'
		exe "	noremenu ".s:BASH_Root.'&Tests.-Sep4-                         :'
		exe "	noremenu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																 a[ -o  ]<Left><Left>'
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
		" menu Parameter Substitution   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&ParmSub.ParmSub<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'&ParmSub.-Sep0-           :'
		endif

    exe " noremenu ".s:BASH_Root.'&ParmSub.s&ubstitution\ <tab>${\ }                               a${}<Left>'
    exe " noremenu ".s:BASH_Root.'&ParmSub.use\ &default\ value<tab>${\ :-\ }                      a${:-}<ESC>3ha'
    exe " noremenu ".s:BASH_Root.'&ParmSub.&assign\ default\ value<tab>${\ :=\ }                   a${:=}<ESC>3ha'
    exe " noremenu ".s:BASH_Root.'&ParmSub.display\ &error\ if\ null\ or\ unset<tab>${\ :?\ }      a${:?}<ESC>3ha'
    exe " noremenu ".s:BASH_Root.'&ParmSub.use\ alternate\ &value<tab>${\ :+\ }                    a${:+}<ESC>3ha'
    exe " noremenu ".s:BASH_Root.'&ParmSub.&substring\ expansion<tab>${\ :\ :\ }                   a${::}<ESC>3ha'
    exe " noremenu ".s:BASH_Root.'&ParmSub.list\ of\ var\.s\ &beginning\ with\ prefix<tab>${!\ *}  a${!*}<ESC>2ha'
		exe " noremenu ".s:BASH_Root.'&ParmSub.-Sep1-           :'
    exe " noremenu ".s:BASH_Root.'&ParmSub.&parameter\ length\ in\ characters<Tab>${#\ }           a${#}<Left>'
    exe " noremenu ".s:BASH_Root.'&ParmSub.match\ beginning;\ del\.\ &shortest\ part<Tab>${\ #\ }  a${#}<Left><Left>'
    exe " noremenu ".s:BASH_Root.'&ParmSub.match\ beginning;\ del\.\ &longest\ part<Tab>${\ ##\ }  a${##}<Left><Left><Left>'
    exe " noremenu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ s&hortest\ part<Tab>${\ %\ }       a${%}<Left><Left>'
    exe " noremenu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ l&ongest\ part<Tab>${\ %%\ }       a${%%}<Left><Left><Left>'
    exe " noremenu ".s:BASH_Root.'&ParmSub.&replace\ first\ match<Tab>${\ /\ /\ }                  a${/ / }<ESC>F{a'
    exe " noremenu ".s:BASH_Root.'&ParmSub.replace\ all\ &matches<Tab>${\ //\ /\ }                 a${// / }<ESC>F{a'

    exe "vnoremenu ".s:BASH_Root.'&ParmSub.s&ubstitution\ <tab>${\ }                               s${}<Esc>Pl'
    "
    exe "inoremenu ".s:BASH_Root.'&ParmSub.s&ubstitution\ <tab>${\ }                                ${}<Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.use\ &default\ value<tab>${\ :-\ }                       ${:-}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.&assign\ default\ value<tab>${\ :=\ }                    ${:=}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.display\ &error\ if\ null\ or\ unset<tab>${\ :?\ }       ${:?}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.use\ alternate\ &value<tab>${\ :+\ }                     ${:+}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.&substring\ expansion<tab>${\ :\ :\ }                    ${::}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.list\ of\ var\.s\ &beginning\ with\ prefix<Tab>${!\ *} 	${!*}<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'&ParmSub.-Sep1-           :'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.&parameter\ length\ in\ characters<tab>${#\ }            ${#}<Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.match\ beginning;\ del\.\ &shortest\ part<Tab>${\ #\ }   ${#}<Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.match\ beginning;\ del\.\ &longest\ part<Tab>${\ ##\ }   ${##}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ s&hortest\ part<Tab>${\ %\ }        ${%}<Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ l&ongest\ part<Tab>${\ %%\ }        ${%%}<Left><Left><Left>'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.&replace\ first\ match<Tab>${\ /\ /\ }                   ${/ / }<Esc>F{a'
    exe "inoremenu ".s:BASH_Root.'&ParmSub.replace\ all\ &matches<Tab>${\ //\ /\ }                  ${// / }<Esc>F{a'
		"
		"-------------------------------------------------------------------------------
		" menu Special Variables   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Spec&Vars.SpecVars<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'Spec&Vars.-Sep0-          :'
		endif

		exe "	noremenu ".s:BASH_Root.'Spec&Vars.&number\ of\ posit\.\ param\.<tab>${#}							 a${#}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.&all\ posit\.\ param\.\ (quoted\ spaces)<tab>${*}		 a${*}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.all\ posit\.\ param\.\ (&unquoted\ spaces)<tab>${@}	 a${@}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.n&umber\ of\ posit\.\ parameters<tab>${#@}	         a${#@}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.&return\ code\ of\ last\ command<tab>${?}						 a${?}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.&PID\ of\ this\ shell<tab>${$}											 a${$}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.&flags\ set<tab>${-}																 a${-}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.&last\ argument\ of\ prev\.\ command<tab>${_}				 a${_}'
		exe "	noremenu ".s:BASH_Root.'Spec&Vars.PID\ of\ last\ &background\ command<tab>${!}				 a${!}'
		"
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.&number\ of\ posit\.\ param\.<tab>${#}								${#}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.&all\ posit\.\ param\.\ (quoted\ spaces)<tab>${*}			${*}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.all\ posit\.\ param\.\ (&unquoted\ spaces)<tab>${@}		${@}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.n&umber\ of\ posit\.\ parameters<tab>${#@}	        	a${#@}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.&return\ code\ of\ last\ command<tab>${?}							${?}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.&PID\ of\ this\ shell<tab>${$}												${$}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.&flags\ set<tab>${-}																	${-}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.&last\ argument\ of\ prev\.\ command<tab>${_}					a${_}'
		exe "inoremenu ".s:BASH_Root.'Spec&Vars.PID\ of\ last\ &background\ command<tab>${!}					${!}'
		"
		"-------------------------------------------------------------------------------
		" menu Environment Variables   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.Environ<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'E&nviron.-Sep0-        :'
		endif
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.Environ-1<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.-Sep0-         :'
		endif
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.&BASH            <Esc>a${BASH}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&C       <Esc>a${BASH_ARGC}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&V       <Esc>a${BASH_ARGV}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_C&OMMAND    <Esc>a${BASH_COMMAND}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&ENV        <Esc>a${BASH_ENV}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_E&XE\.STR\. <Esc>a${BASH_EXECUTION_STRING}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&LINENO     <Esc>a${BASH_LINENO}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&REMATCH    <Esc>a${BASH_REMATCH}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&SOURCE     <Esc>a${BASH_SOURCE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_S&UBSHELL   <Esc>a${BASH_SUBSHELL}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERS&INFO   <Esc>a${BASH_VERSINFO}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERSIO&N    <Esc>a${BASH_VERSION}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.Environ-2<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.-Sep0-         :'
		endif
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&CDPATH          <Esc>a${CDPATH}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.C&OLUMNS         <Esc>a${COLUMNS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.CO&MPREPLY       <Esc>a${COMPREPLY}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COM&P_CWORD      <Esc>a${COMP_CWORD}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&LINE       <Esc>a${COMP_LINE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_POI&NT      <Esc>a${COMP_POINT}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_WORD&BREAKS <Esc>a${COMP_WORDBREAKS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&WORDS      <Esc>a${COMP_WORDS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&DIRSTACK        <Esc>a${DIRSTACK}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EMAC&S          <Esc>a${EMACS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EUID            <Esc>a${EUID}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&FCEDIT          <Esc>a${FCEDIT}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&IGNORE         <Esc>a${FIGNORE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&UNCNAME        <Esc>a${FUNCNAME}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.Environ-3<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.-Sep0-                         :'
		endif
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE     a${GLOBIGNORE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS         a${GROUPS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD        a${HISTCMD}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL    a${HISTCONTROL}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE       a${HISTFILE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE   a${HISTFILESIZE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE     a${HISTIGNORE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE       a${HISTSIZE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTTI&MEFORMAT a${HISTTIMEFORMAT}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME           a${HOME}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E       a${HOSTFILE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME       a${HOSTNAME}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE       a${HOSTTYPE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS            a${IFS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF      a${IGNOREEOF}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C        a${INPUTRC}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG           a${LANG}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.Environ-4<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.-Sep0-         :'
		endif
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          a${LC_ALL}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      a${LC_COLLATE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        a${LC_CTYPE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     a${LC_MESSAGES}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      a${LC_NUMERIC}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          a${LINENO}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           a${LINES}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        a${MACHTYPE}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            a${MAIL}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       a${MAILCHECK}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        a${MAILPATH}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          a${OLDPWD}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          a${OPTARG}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          a${OPTERR}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          a${OPTIND}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          a${OSTYPE}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.Environ-5<Tab>Bash  <Nop>'
			exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.-Sep0-              :'
		endif
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&PATH                 a${PATH}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           a${PIPESTATUS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      a${POSIXLY_CORRECT}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 a${PPID}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       a${PROMPT_COMMAND}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&1                  a${PS1}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&2                  a${PS2}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&3                  a${PS3}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&4                  a${PS4}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&WD                  a${PWD}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               a${RANDOM}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                a${REPLY}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              a${SECONDS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.S&HELL                a${SHELL}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&ELLOPTS            a${SHELLOPTS}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                a${SHLVL}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           a${TIMEFORMAT}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                a${TMOUT}'
		exe "	noremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&UID                  a${UID}'

		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.&BASH            ${BASH}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&C       ${BASH_ARGC}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&V       ${BASH_ARGV}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_C&OMMAND    ${BASH_COMMAND}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&ENV        ${BASH_ENV}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_E&XE\.STR\. ${BASH_EXECUTION_STRING}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&LINENO     ${BASH_LINENO}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&REMATCH    ${BASH_REMATCH}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&SOURCE     ${BASH_SOURCE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_S&UBSHELL   ${BASH_SUBSHELL}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERS&INFO   ${BASH_VERSINFO}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERSIO&N    ${BASH_VERSION}'

		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&CDPATH          ${CDPATH}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.C&OLUMNS         ${COLUMNS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.CO&MPREPLY       ${COMPREPLY}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COM&P_CWORD      ${COMP_CWORD}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&LINE       ${COMP_LINE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_POI&NT      ${COMP_POINT}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_WORD&BREAKS ${COMP_WORDBREAKS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&WORDS      ${COMP_WORDS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&DIRSTACK        ${DIRSTACK}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EMAC&S          ${EMACS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EUID            ${EUID}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&FCEDIT          ${FCEDIT}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&IGNORE         ${FIGNORE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&UNCNAME        ${FUNCNAME}'
		"
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE     ${GLOBIGNORE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS         ${GROUPS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD        ${HISTCMD}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL    ${HISTCONTROL}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE       ${HISTFILE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE   ${HISTFILESIZE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE     ${HISTIGNORE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE       ${HISTSIZE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTTI&MEFORMAT ${HISTTIMEFORMAT}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME           ${HOME}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E       ${HOSTFILE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME       ${HOSTNAME}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE       ${HOSTTYPE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS            ${IFS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF      ${IGNOREEOF}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C        ${INPUTRC}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG           ${LANG}'
		"
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          ${LC_ALL}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      ${LC_COLLATE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        ${LC_CTYPE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     ${LC_MESSAGES}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      ${LC_NUMERIC}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          ${LINENO}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           ${LINES}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        ${MACHTYPE}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            ${MAIL}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       ${MAILCHECK}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        ${MAILPATH}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          ${OLDPWD}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          ${OPTARG}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          ${OPTERR}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          ${OPTIND}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          ${OSTYPE}'
		"
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&PATH                 ${PATH}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           ${PIPESTATUS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      ${POSIXLY_CORRECT}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 ${PPID}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       ${PROMPT_COMMAND}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&1                  ${PS1}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&2                  ${PS2}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&3                  ${PS3}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&4                  ${PS4}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&WD                  ${PWD}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               ${RANDOM}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                ${REPLY}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              ${SECONDS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.S&HELL                ${SHELL}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&ELLOPTS            ${SHELLOPTS}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                ${SHLVL}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           ${TIMEFORMAT}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                ${TMOUT}'
		exe "inoremenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&UID                  ${UID}'
		"
		"-------------------------------------------------------------------------------
		" menu Builtins  a-l   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Builtins\ \ &a-l.Builtins\ 1<Tab>Bash  <Nop>'
			exe "amenu ".s:BASH_Root.'Builtins\ \ &a-l.-Sep0-         :'
		endif
		"
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.&alias     aalias<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.&bind      abind<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.b&uiltin   abuiltin<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.&caller    acaller<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.c&d        acd<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.c&ommand   acommand<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.co&mpgen   acompgen<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.com&plete  acomplete<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.d&eclare   adeclare<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.di&rs      adirs<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.ec&ho      aecho<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.e&nable    aenable<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.e&val      aeval<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.e&xec      aexec<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.expor&t    aexport<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.&getopts   agetopts<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.ha&sh      ahash<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.&kill      akill<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.&let       alet<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &a-l.l&ocal     alocal<Space>'
		"
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.&alias      alias<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.&bind       bind<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.b&uiltin    builtin<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.&caller     caller<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.c&d         cd<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.c&ommand    command<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.co&mpgen    compgen<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.com&plete   complete<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.d&eclare    declare<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.di&rs       dirs<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.ec&ho       echo<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.e&nable     enable<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.e&val       eval<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.e&xec       exec<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.expor&t     export<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.&getopts    getopts<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.ha&sh       hash<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.&kill       kill<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.&let        let<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &a-l.l&ocal      local<Space>'
		"
		"-------------------------------------------------------------------------------
		" menu Builtins  n-w   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Builtins\ \ &n-w.Builtins\ 2<Tab>Bash <Nop>'
			exe "amenu ".s:BASH_Root.'Builtins\ \ &n-w.-Sep0-         :'
		endif
		"
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.&popd         apopd<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.print&f       aprintf<Space>"" '
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.pus&hd        apushd<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.pw&d          apwd<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.&readonly     areadonly<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.r&ead         aread<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.retur&n       areturn<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.&source       asource<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.&test         atest<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.t&imes        atimes<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.t&ype         atype<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.typeset\ (&1) atypeset<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.&ulimit       aulimit<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.u&mask        aumask<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.un&alias      aunalias<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.unset\ (&2)   aunset<Space>'
		exe "	menu ".s:BASH_Root.'Builtins\ \ &n-w.&wait         await<Space>'
		"
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.&popd          popd<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.print&f        printf<Space>"" '
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.pus&hd         pushd<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.pw&d           pwd<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.&readonly      readonly<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.r&ead          read<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.retur&n        return<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.&source        source<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.&test          test<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.t&imes         times<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.t&ype          type<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.typeset\ (&1)  typeset<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.&ulimit        ulimit<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.u&mask         umask<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.un&alias       unalias<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.unset\ (&2)    unset<Space>'
		exe "imenu ".s:BASH_Root.'Builtins\ \ &n-w.&wait          wait<Space>'
		"
		"-------------------------------------------------------------------------------
		" menu set   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'s&et.set<Tab>Bash   <Nop>'
			exe "amenu ".s:BASH_Root.'s&et.-Sep0-       	:'
		endif
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
		" menu shopt   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'sh&opt.shopt<Tab>Bash   <Nop>'
			exe "amenu ".s:BASH_Root.'sh&opt.-Sep0-    				    :'
		endif
		"
    exe "amenu ".s:BASH_Root.'sh&opt.cdable_vars                oshopt -s cdable_vars'
    exe "amenu ".s:BASH_Root.'sh&opt.cdspell                    oshopt -s cdspell'
    exe "amenu ".s:BASH_Root.'sh&opt.checkhash                  oshopt -s checkhash'
    exe "amenu ".s:BASH_Root.'sh&opt.checkwinsize               oshopt -s checkwinsize'
    exe "amenu ".s:BASH_Root.'sh&opt.cmdhist                    oshopt -s cmdhist'
    exe "amenu ".s:BASH_Root.'sh&opt.dotglob                    oshopt -s dotglob'
    exe "amenu ".s:BASH_Root.'sh&opt.execfail                   oshopt -s execfail'
    exe "amenu ".s:BASH_Root.'sh&opt.expand_aliases             oshopt -s expand_aliases'
    exe "amenu ".s:BASH_Root.'sh&opt.extdebug                   oshopt -s extdebug'
    exe "amenu ".s:BASH_Root.'sh&opt.extglob                    oshopt -s extglob'
    exe "amenu ".s:BASH_Root.'sh&opt.extquote                   oshopt -s extquote'
    exe "amenu ".s:BASH_Root.'sh&opt.failglob                   oshopt -s failglob'
    exe "amenu ".s:BASH_Root.'sh&opt.force_fignore              oshopt -s force_fignore'
    exe "amenu ".s:BASH_Root.'sh&opt.gnu_errfmt                 oshopt -s gnu_errfmt'
    exe "amenu ".s:BASH_Root.'sh&opt.histappend                 oshopt -s histappend'
    exe "amenu ".s:BASH_Root.'sh&opt.histreedit                 oshopt -s histreedit'
    exe "amenu ".s:BASH_Root.'sh&opt.histverify                 oshopt -s histverify'
    exe "amenu ".s:BASH_Root.'sh&opt.hostcomplete               oshopt -s hostcomplete'
    exe "amenu ".s:BASH_Root.'sh&opt.huponexit                  oshopt -s huponexit'
    exe "amenu ".s:BASH_Root.'sh&opt.interactive_comments       oshopt -s interactive_comments'
    exe "amenu ".s:BASH_Root.'sh&opt.lithist                    oshopt -s lithist'
    exe "amenu ".s:BASH_Root.'sh&opt.login_shell                oshopt -s login_shell'
    exe "amenu ".s:BASH_Root.'sh&opt.mailwarn                   oshopt -s mailwarn'
    exe "amenu ".s:BASH_Root.'sh&opt.no_empty_cmd_completion    oshopt -s no_empty_cmd_completion'
    exe "amenu ".s:BASH_Root.'sh&opt.nocaseglob                 oshopt -s nocaseglob'
    exe "amenu ".s:BASH_Root.'sh&opt.nocasematch                oshopt -s nocasematch'
    exe "amenu ".s:BASH_Root.'sh&opt.nullglob                   oshopt -s nullglob'
    exe "amenu ".s:BASH_Root.'sh&opt.progcomp                   oshopt -s progcomp'
    exe "amenu ".s:BASH_Root.'sh&opt.promptvars                 oshopt -s promptvars'
    exe "amenu ".s:BASH_Root.'sh&opt.restricted_shell           oshopt -s restricted_shell'
    exe "amenu ".s:BASH_Root.'sh&opt.shift_verbose              oshopt -s shift_verbose'
    exe "amenu ".s:BASH_Root.'sh&opt.sourcepath                 oshopt -s sourcepath'
    exe "amenu ".s:BASH_Root.'sh&opt.xpg_echo                   oshopt -s xpg_echo'
		"
    exe "vmenu ".s:BASH_Root.'sh&opt.cdable_vars               <Esc>:call BASH_shopt("cdable_vars")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.cdspell                   <Esc>:call BASH_shopt("cdspell")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.checkhash                 <Esc>:call BASH_shopt("checkhash")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.checkwinsize              <Esc>:call BASH_shopt("checkwinsize")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.cmdhist                   <Esc>:call BASH_shopt("cmdhist")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.dotglob                   <Esc>:call BASH_shopt("dotglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.execfail                  <Esc>:call BASH_shopt("execfail")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.expand_aliases            <Esc>:call BASH_shopt("expand_aliases")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.extdebug                  <Esc>:call BASH_shopt("extdebug")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.extglob                   <Esc>:call BASH_shopt("extglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.extquote                  <Esc>:call BASH_shopt("extquote")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.failglob                  <Esc>:call BASH_shopt("failglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.force_fignore             <Esc>:call BASH_shopt("force_fignore")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.gnu_errfmt                <Esc>:call BASH_shopt("gnu_errfmt")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.histappend                <Esc>:call BASH_shopt("histappend")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.histreedit                <Esc>:call BASH_shopt("histreedit")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.histverify                <Esc>:call BASH_shopt("histverify")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.hostcomplete              <Esc>:call BASH_shopt("hostcomplete")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.huponexit                 <Esc>:call BASH_shopt("huponexit")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.interactive_comments      <Esc>:call BASH_shopt("interactive_comments")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.lithist                   <Esc>:call BASH_shopt("lithist")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.login_shell               <Esc>:call BASH_shopt("login_shell")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.mailwarn                  <Esc>:call BASH_shopt("mailwarn")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.no_empty_cmd_completion   <Esc>:call BASH_shopt("no_empty_cmd_completion")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.nocaseglob                <Esc>:call BASH_shopt("nocaseglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.nocasematch               <Esc>:call BASH_shopt("nocasematch")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.nullglob                  <Esc>:call BASH_shopt("nullglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.progcomp                  <Esc>:call BASH_shopt("progcomp")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.promptvars                <Esc>:call BASH_shopt("promptvars")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.restricted_shell          <Esc>:call BASH_shopt("restricted_shell")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.shift_verbose             <Esc>:call BASH_shopt("shift_verbose")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.sourcepath                <Esc>:call BASH_shopt("sourcepath")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.xpg_echo                  <Esc>:call BASH_shopt("xpg_echo")<CR>'
		"
		"------------------------------------------------------------------------------
		"  menu Regex    {{{2
		"------------------------------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Rege&x.Regex<Tab>bash   <Nop>'
			exe "amenu ".s:BASH_Root.'Rege&x.-Sep0-      :'
		endif
		"
		exe "anoremenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )              a*(\|)<Left><Left>'
		exe "anoremenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )             a+(\|)<Left><Left>'
		exe "anoremenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )           a?(\|)<Left><Left>'
		exe "anoremenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				   a@(\|)<Left><Left>'
		exe "anoremenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )             a!(\|)<Left><Left>'
		"
		exe "inoremenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )               *(\|)<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )              +(\|)<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )            ?(\|)<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				    @(\|)<Left><Left>'
		exe "inoremenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )              !(\|)<Left><Left>'
		"
		exe "vnoremenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )              s*(\|)<Esc>hPla'
		exe "vnoremenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )             s+(\|)<Esc>hPla'
		exe "vnoremenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )           s?(\|)<Esc>hPla'
		exe "vnoremenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				   s@(\|)<Esc>hPla'
		exe "vnoremenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )             s!(\|)<Esc>hPla'
		"
		exe "amenu ".s:BASH_Root.'Rege&x.-Sep1-      :'
		"
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&alnum:]	 a[:alnum:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:alp&ha:]	 a[:alpha:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:asc&ii:]	 a[:ascii:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&cntrl:]	 a[:cntrl:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&digit:]	 a[:digit:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&graph:]	 a[:graph:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&lower:]	 a[:lower:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&print:]	 a[:print:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:pu&nct:]	 a[:punct:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&space:]	 a[:space:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&upper:]	 a[:upper:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&word:]	 a[:word:]'
		exe " noremenu ".s:BASH_Root.'Rege&x.[:&xdigit:] a[:xdigit:]'
		"
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&alnum:]		[:alnum:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:alp&ha:]		[:alpha:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:asc&ii:]		[:ascii:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&cntrl:]		[:cntrl:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&digit:]		[:digit:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&graph:]		[:graph:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&lower:]		[:lower:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&print:]		[:print:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:pu&nct:]		[:punct:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&space:]		[:space:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&upper:]		[:upper:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&word:]	 	[:word:]'
		exe "inoremenu ".s:BASH_Root.'Rege&x.[:&xdigit:]	[:xdigit:]'
		"
		exe " noremenu ".s:BASH_Root.'Rege&x.&[\ \ \ ]   a[]<Left>'
		exe "inoremenu ".s:BASH_Root.'Rege&x.&[\ \ \ ]    []<Left>'
		exe "vnoremenu ".s:BASH_Root.'Rege&x.&[\ \ \ ]   s[]<Esc>P'
		"
		exe "amenu ".s:BASH_Root.'Rege&x.-Sep2-      :'
		"
		exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&0]}    	     a${BASH_REMATCH[0]}'
		exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&1]}    	     a${BASH_REMATCH[1]}'
		exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&2]}    	     a${BASH_REMATCH[2]}'
		exe "anoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&3]}    	     a${BASH_REMATCH[3]}'
		"
		exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&0]}    	<Esc>a${BASH_REMATCH[0]}'
		exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&1]}    	<Esc>a${BASH_REMATCH[1]}'
		exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&2]}    	<Esc>a${BASH_REMATCH[2]}'
		exe "inoremenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&3]}    	<Esc>a${BASH_REMATCH[3]}'
		"
		"
		"-------------------------------------------------------------------------------
		" menu I/O redirection   {{{2
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&I/O-Redir.I/O-Redir<Tab>Bash   <Nop>'
			exe "amenu ".s:BASH_Root.'&I/O-Redir.-Sep0-    				    :'
		endif

		exe "	menu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file												a<Space><<Space><ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file												a<Space>><Space><ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append							a<Space>>><Space><ESC>a'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ to\ file								a<Space>><Space><ESC>2hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ to\ file;\ append	  		a<Space>>><Space><ESC>2hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.take\ file\ descr\.\ from\ file								a<Space><<Space><ESC>2hi'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.					a<Space><& <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.						a<Space>>& <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file					a<Space>&> <ESC>a'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ STDIN																		a<Space><&- <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ STDOUT																	a<Space>>&- <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n						a<Space><&- <ESC>3hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n					a<Space>>&- <ESC>3hi'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.here-document																	a<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file												<Space><<Space><ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file												<Space>><Space><ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append							<Space>>><Space><ESC>a'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ to\ file								<Space>><Space><ESC>2hi'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ to\ file;\ append				<Space>>><Space><ESC>2hi'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.take\ file\ descr\.\ from\ file								<Space><<Space><ESC>2hi'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.					<Space><& <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.						<Space>>& <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file					<Space>&> <ESC>a'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ STDIN																		<Space><&- <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ STDOUT																	<Space>>&- <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n						<Space><&- <ESC>3hi'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n					<Space>>&- <ESC>3hi'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.here-document																	<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
		"
		"------------------------------------------------------------------------------
		"  menu Run    {{{2
		"------------------------------------------------------------------------------
		"   run the script from the local directory
		"   ( the one in the current buffer ; other versions may exist elsewhere ! )
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Run.Run<Tab>Bash  <Nop>'
			exe "amenu ".s:BASH_Root.'&Run.-Sep0-        :'
		endif

		exe " menu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab><C-F9>            :call BASH_Run("n")<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab><C-F9>       <C-C>:call BASH_Run("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab><C-F9>       <C-C>:call BASH_Run("v")<CR>'
		"
		"   set execution right only for the user ( may be user root ! )
		"
		exe " menu <silent> ".s:BASH_Root.'&Run.cmd\.\ line\ &arg\.<Tab><S-F9>              :call BASH_CmdLineArguments()<CR>'
		exe " menu <silent> ".s:BASH_Root.'&Run.start\ &debugger<Tab><F9>                   :call BASH_Debugger()<CR>'
		exe " menu <silent> ".s:BASH_Root.'&Run.make\ script\ &executable                   :call BASH_MakeScriptExecutable()<CR>'
		exe " menu <silent> ".s:BASH_Root.'&Run.save\ +\ &check\ syntax<Tab><A-F9>          :call BASH_SyntaxCheck()<CR>'
		exe " menu <silent> ".s:BASH_Root.'&Run.syntax\ check\ o&ptions                     :call BASH_SyntaxCheckOptionsLocal()<CR>'
		"
		exe "imenu <silent> ".s:BASH_Root.'&Run.cmd\.\ line\ &arg\.<Tab><S-F9>         <C-C>:call BASH_CmdLineArguments()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.start\ &debugger<Tab><F9>              <C-C>:call BASH_Debugger()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.make\ script\ &executable              <C-C>:call BASH_MakeScriptExecutable()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.save\ +\ &check\ syntax<Tab><A-F9>     <C-C>:call BASH_SyntaxCheck()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.syntax\ check\ o&ptions                <C-C>:call BASH_SyntaxCheckOptionsLocal()<CR>'
		"
		exe "amenu          ".s:BASH_Root.'&Run.-Sep1-                                 :'
		"
		exe " menu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps                 :call BASH_Hardcopy("n")<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps            <C-C>:call BASH_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps            <C-C>:call BASH_Hardcopy("v")<CR>'
		exe " menu          ".s:BASH_Root.'&Run.-SEP2-                                 :'
		exe " menu <silent> ".s:BASH_Root.'&Run.plugin\ &settings                           :call BASH_Settings()<CR>'
		exe "imenu <silent> ".s:BASH_Root.'&Run.plugin\ &settings                      <C-C>:call BASH_Settings()<CR>'
		"
		exe "imenu          ".s:BASH_Root.'&Run.-SEP3-                                 :'
		"
		exe " menu  <silent>  ".s:BASH_Root.'&Run.x&term\ size                              :call BASH_XtermSize()<CR>'
		exe "imenu  <silent>  ".s:BASH_Root.'&Run.x&term\ size                         <C-C>:call BASH_XtermSize()<CR>'
		if s:BASH_OutputGvim == "vim"
			exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm            :call BASH_Toggle_Gvim_Xterm()<CR>'
			exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm       <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
		else
			if s:BASH_OutputGvim == "buffer"
				exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim          :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			else
				exe " menu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer          :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			endif
		endif
		"
		"===============================================================================================
		"----- Menu : help     {{{2
		"===============================================================================================
		"
		if s:BASH_Root != ""
			exe " menu  <silent>  ".s:BASH_Root.'&help\ \(plugin\)             :call BASH_HelpBASHsupport()<CR>'
			exe "imenu  <silent>  ".s:BASH_Root.'&help\ \(plugin\)        <C-C>:call BASH_HelpBASHsupport()<CR>'
		endif
		"
	endif

endfunction		" ---------- end of function  BASH_InitMenu  ----------
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt    {{{1
"------------------------------------------------------------------------------
function! BASH_Input ( prompt, text )
	echohl Search												" highlight prompt
	call inputsave()										" preserve typeahead
	let	retval=input( a:prompt, a:text )	" read input
	call inputrestore()									" restore typeahead
	echohl None													" reset highlighting
	return retval
endfunction		" ---------- end of function  BASH_Input  ----------
"
"------------------------------------------------------------------------------
"  BASH_AdjustLineEndComm: adjust line-end comments      {{{1
"------------------------------------------------------------------------------
function! BASH_AdjustLineEndComm ( mode ) range
	"
	if !exists("b:BASH_LineEndCommentColumn")
		let	b:BASH_LineEndCommentColumn	= s:BASH_LineEndCommColDefault
	endif

	let save_cursor = getpos(".")

	let	save_expandtab	= &expandtab
	exe	":set expandtab"

	if a:mode == 'v'
		let pos0	= line("'<")
		let pos1	= line("'>")
	else
		let pos0	= line(".")
		let pos1	= pos0
	end

	let	linenumber	= pos0
	exe ":".pos0

	while linenumber <= pos1
		let	line= getline(".")
		" look for a Bash comment, don't match '$#' and '${#..'
		let idx1	= 1 + match( line, '\s*\(\${\?\)\@<!#.*$' )
		let idx2	= 1 + match( line,    '\(\${\?\)\@<!#.*$' )

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
		let	b:BASH_LineEndCommentColumn	= BASH_Input( 'start line-end comment at virtual column : ', actcol )
	else
		let	b:BASH_LineEndCommentColumn	= virtcol(".")
	endif
  echomsg "line end comments will start at column  ".b:BASH_LineEndCommentColumn
endfunction		" ---------- end of function  BASH_GetLineEndCommCol  ----------
"
"------------------------------------------------------------------------------
"  Comments : single line-end comment    {{{1
"------------------------------------------------------------------------------
function! BASH_LineEndComment ()
	if !exists("b:BASH_LineEndCommentColumn")
		let	b:BASH_LineEndCommentColumn	= s:BASH_LineEndCommColDefault
	endif
	" ----- trim whitespaces -----
	exe "s/\s\*$//"
	let linelength= virtcol("$") - 1
	if linelength < b:BASH_LineEndCommentColumn
		let diff	= b:BASH_LineEndCommentColumn -1 -linelength
		exe "normal	".diff."A "
	endif
	" append at least one blank
	if linelength >= b:BASH_LineEndCommentColumn
		exe "normal A "
	endif
	exe "normal A# "
endfunction		" ---------- end of function  BASH_LineEndComment  ----------
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments    {{{1
"------------------------------------------------------------------------------
function! BASH_MultiLineEndComments ()
  if !exists("b:BASH_LineEndCommentColumn")
		let	b:BASH_LineEndCommentColumn	= s:BASH_LineEndCommColDefault
  endif
	"
	let pos0	= line("'<")
	let pos1	= line("'>")
	" ----- trim whitespaces -----
	exe "'<,'>s/\s\*$//"
	" ----- find the longest line -----
	let	maxlength		= 0
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if  getline(".") !~ "^\\s*$"  && maxlength<virtcol("$")
			let maxlength= virtcol("$")
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	"
	if maxlength < b:BASH_LineEndCommentColumn
	  let maxlength = b:BASH_LineEndCommentColumn
	else
	  let maxlength = maxlength+1		" at least 1 blank
	endif
	"
	" ----- fill lines with blanks -----
	let	linenumber	= pos0
	normal '<
	while linenumber <= pos1
		if getline(".") !~ "^\\s*$"
			let diff	= maxlength - virtcol("$")
			exe "normal	".diff."A "
			exe "normal	$A# "
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	" ----- back to the begin of the marked block -----
	normal '<
endfunction		" ---------- end of function  BASH_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  toggle comments    {{{1
"------------------------------------------------------------------------------
function! BASH_CommentToggle ()
  if match( getline("."), '^\s*#' ) != -1
		" remove comment sign, keep leading whitespaces
		exe ":s/^\\(\\s*\\)#/\\1/"
	else
		" add comment leader
		exe ":s/^/#/"
	endif
endfunction    " ----------  end of function BASH_CommentToggle  ----------
"
"------------------------------------------------------------------------------
"  Substitute tags    {{{1
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
"  Bash-Comments : Insert Template Files    {{{1
"------------------------------------------------------------------------------
function! BASH_CommentTemplates (arg)

	"----------------------------------------------------------------------
	"  BASH templates
	"----------------------------------------------------------------------
	if a:arg=='frame'
		let templatefile=s:BASH_Template_Directory.s:BASH_Template_Frame
	endif

	if a:arg=='function'
		let templatefile=s:BASH_Template_Directory.s:BASH_Template_Function
	endif

	if a:arg=='header'
		let templatefile=s:BASH_Template_Directory.s:BASH_Template_File
	endif


	if filereadable(templatefile)
		let	length= line("$")
		let	pos1  = line(".")+1
		let l:old_cpoptions	= &cpoptions " Prevent the alternate buffer from being set to this files
		setlocal cpoptions-=a
		if  a:arg=='header'
			:goto 1
			let	pos1  = 1
			exe '0read '.templatefile
		else
			exe 'read '.templatefile
		endif
		let &cpoptions	= l:old_cpoptions		" restore previous options
		let	length= line("$")-length
		let	pos2  = pos1+length-1
		"----------------------------------------------------------------------
		"  frame blocks will be indented
		"----------------------------------------------------------------------
		if a:arg=='frame'
			let	length	= length-1
			silent exe "normal =".length."+"
			let	length	= length+1
		endif
		"----------------------------------------------------------------------
		"  substitute keywords
		"----------------------------------------------------------------------
		"
		call  BASH_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")               )
		call  BASH_SubstituteTag( pos1, pos2, '|DATE|',            BASH_InsertDateAndTime('d') )
		call  BASH_SubstituteTag( pos1, pos2, '|DATETIME|',        BASH_InsertDateAndTime('dt'))
		call  BASH_SubstituteTag( pos1, pos2, '|TIME|',            BASH_InsertDateAndTime('t') )
		call  BASH_SubstituteTag( pos1, pos2, '|YEAR|',            BASH_InsertDateAndTime('y') )
		call  BASH_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:BASH_AuthorName     )
		call  BASH_SubstituteTag( pos1, pos2, '|EMAIL|',           s:BASH_Email          )
		call  BASH_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:BASH_AuthorRef      )
		call  BASH_SubstituteTag( pos1, pos2, '|PROJECT|',         s:BASH_Project        )
		call  BASH_SubstituteTag( pos1, pos2, '|COMPANY|',         s:BASH_Company        )
		call  BASH_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:BASH_CopyrightHolder)
		"
		" now the cursor
		"
		exe ':'.pos1
		normal 0
		let linenumber=search('|CURSOR|')
		if linenumber >=pos1 && linenumber<=pos2
			let pos1=match( getline(linenumber) ,"|CURSOR|")
			if  matchend( getline(linenumber) ,"|CURSOR|") == match( getline(linenumber) ,"$" )
				silent! s/|CURSOR|//
				" this is an append like A
				:startinsert!
			else
				silent  s/|CURSOR|//
				call cursor(linenumber,pos1+1)
				" this is an insert like i
				:startinsert
			endif
		endif

	else
		echohl WarningMsg | echo 'template file '.templatefile.' does not exist or is not readable'| echohl None
	endif
	return
endfunction    " ----------  end of function  BASH_CommentTemplates  ----------
"
"------------------------------------------------------------------------------
"  Comments : classified comments    {{{1
"------------------------------------------------------------------------------
function! BASH_CommentClassified (class)
  	put = '# :'.a:class.':'.BASH_InsertDateAndTime('d').':'.s:BASH_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  Comments : vim modeline    {{{1
"------------------------------------------------------------------------------
function! BASH_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function BASH_CommentVimModeline  ----------
"
"------------------------------------    {{{1-------------------------------------------
"   Statements : flow control
"-------------------------------------------------------------------------------
function! BASH_FlowControl ( part1, part2, part3, mode )

	if s:BASH_DoOnNewLine=='yes'
		let	splt = "\n"
	else
		let	splt = "; "
	end
	let	startposition	= line(".")+1
	"-------------------------------------------------------------------------------
	"   normal mode, insert mode
	"-------------------------------------------------------------------------------
	if a:mode=='a'
		let	zz = a:part1.splt.a:part2."\n".a:part3
		put =zz
		let	lines = line(".")-startposition+1
		exe ":".startposition
	end
	"-------------------------------------------------------------------------------
	"   visual mode
	"-------------------------------------------------------------------------------
	if a:mode=='v'
		let	lines = line("'>")-line("'<")+1
		let	zz = a:part1.splt.a:part2
		normal '<
		put! =zz
		let	zz = a:part3
		normal '>
		put  =zz
		if a:part3 =~ 'else'
			let	lines = lines+1
		end
		if s:BASH_DoOnNewLine=='yes'
			let	lines = lines+3
			:'<-2
		else
			let	lines = lines+2
			:'<-1
		end
	end
	exe "normal ".lines."=="
	normal f_x
endfunction    " ----------  end of function BASH_FlowControl  ----------
"
"------------------------------------------------------------------------------
"  Stmts : function    {{{1
"------------------------------------------------------------------------------
function! BASH_CodeFunction ( mode )
	let	identifier=BASH_Input("function name : ", "" )
	if identifier != ""
		"
		if a:mode == "a"
			let zz=    "function ".identifier." ()\n{\n}"
			let zz= zz."    # ----------  end of function ".identifier."  ----------"
			put =zz
		endif
		"
		if a:mode == "v"
			let zz= "function ".identifier." ()\n{\n"
			normal '<
			put! =zz
			let zz= "}    # ----------  end of function ".identifier."  ----------"
			normal '>
			put =zz
			normal gv=
		endif
		"
	endif
endfunction		" ---------- end of function  BASH_CodeFunction  ----------
"
"------------------------------------------------------------------------------
"  BASH_help : lookup word under the cursor or ask    {{{1
"------------------------------------------------------------------------------
"
let s:BASH_DocBufferName       = "BASH_HELP"
let s:BASH_DocHelpBufferNumber = -1
let s:BASH_DocSearchWord       = ""
"
function! BASH_help()

	if !( has("gui_running") || &term == "xterm" )
		return
	end

	let cuc		= getline(".")[col(".") - 1]	" character under the cursor
	let	item=expand("<cword>")							" word under the cursor
	if item == "" || match( item, cuc ) == -1
		let	item=BASH_Input("name of a bash builtin command : ", "")
	endif

	"------------------------------------------------------------------------------
	"  replace buffer content with bash help text
	"------------------------------------------------------------------------------
	if item != ""
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
		"
		" read help
		"
		setlocal	modifiable
		let command=":%!help  ".item."  2>/dev/null"
		silent exe command

		if v:shell_error != 0
			redraw!
			let zz=   "No help found for '".item."'\n"
			silent put!	=zz
		endif

		setlocal nomodifiable
		redraw!
	endif
endfunction		" ---------- end of function  BASH_help  ----------
"
"------------------------------------------------------------------------------
"  run : Syntax Check, check if local options does exist    {{{1
"------------------------------------------------------------------------------
"
function! BASH_SyntaxCheckOptions( options )
	let startpos=0
	while startpos < strlen( a:options )
		" match option switch ' -O ' or ' +O '
		let startpos		=  matchend  ( a:options, '\s*[+-]O\s\+', startpos )
		" match option name
		let optionname	=  matchstr  ( a:options, '\h\w*\s*', startpos )
		" remove trailing whitespaces
		let optionname  =  substitute( optionname, '\s\+$', "", "" )
		" check name
		let found				=  match     ( s:BASH_ShoptAllowed, optionname.':' )
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
"  run : Syntax Check, local options    {{{1
"------------------------------------------------------------------------------
"
function! BASH_SyntaxCheckOptionsLocal ()
	let filename = expand("%")
  if filename == ""
		redraw
		echohl WarningMsg | echo " no file name or not a shell file " | echohl None
		return
  endif
	let	prompt	= 'syntax check options for "'.filename.'" : '

	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let	b:BASH_SyntaxCheckOptionsLocal= BASH_Input( prompt, b:BASH_SyntaxCheckOptionsLocal )
	else
		let	b:BASH_SyntaxCheckOptionsLocal= BASH_Input( prompt , "" )
	endif

	if BASH_SyntaxCheckOptions( b:BASH_SyntaxCheckOptionsLocal ) != 0
		let b:BASH_SyntaxCheckOptionsLocal	= ""
	endif
endfunction		" ---------- end of function  BASH_SyntaxCheckOptionsLocal  ----------
"
"------------------------------------------------------------------------------
"  run : syntax check    {{{1
"------------------------------------------------------------------------------
function! BASH_SyntaxCheck ()
	exe	":cclose"
	let	l:currentbuffer=bufname("%")
	exe	":update"
	let	makeprg_saved	= &makeprg
	exe	":setlocal makeprg=$SHELL"
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
	exe ":make -n ".options." -- ./% "
	exe	":botright cwindow"
	exe	':setlocal errorformat='
	exe ":setlocal makeprg=".makeprg_saved
	"
	" message in case of success
	"
	if l:currentbuffer ==  bufname("%")
		redraw
		echohl Search | echo l:currentbuffer." : Syntax is OK" | echohl None
		nohlsearch						" delete unwanted highlighting (Vim bug?)
	endif
endfunction		" ---------- end of function  BASH_SyntaxCheck  ----------
"
"------------------------------------------------------------------------------
"  run : debugger    {{{1
"------------------------------------------------------------------------------
function! BASH_Debugger ()
	if !executable("bashdb")
		echohl Search
		echo   ' bashdb  is not executable or not installed! '
		echohl None
		return
	endif
	"
	silent exe	":update"
	let	l:arguments	= exists("b:BASH_CmdLineArgs") ? " ".b:BASH_CmdLineArgs : ""
	let	Sou					= escape( expand("%"), s:escfilename )
	"
	"
	if has("gui_running") || &term == "xterm"
		"
		" debugger is ' bash --debugger ...'
		"
		if s:BASH_Debugger == "term"
			silent exe "!xterm ".s:BASH_XtermDefaults.' -e ${SHELL} --debugger ./'.Sou.l:arguments.' &'
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
				silent exe '!ddd ./'.Sou.l:arguments.' &'
			endif
		endif
	else
		silent exe '!${SHELL} --debugger ./'.Sou.l:arguments
	endif
endfunction		" ---------- end of function  BASH_Debugger  ----------
"
"----------------------------------------------------------------------
"  run : toggle output destination    {{{1
"----------------------------------------------------------------------
function! BASH_Toggle_Gvim_Xterm ()

	if has("gui_running")
		if s:BASH_OutputGvim == "vim"
			exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm'
			exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim                   :call BASH_Toggle_Gvim_Xterm()<CR>'
			exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim              <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
			let	s:BASH_OutputGvim	= "buffer"
		else
			if s:BASH_OutputGvim == "buffer"
				exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim'
				exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer                 :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer            <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
				let	s:BASH_OutputGvim	= "xterm"
			else
				" ---------- output : xterm -> gvim
				exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer'
				exe " menu    <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm                 :call BASH_Toggle_Gvim_Xterm()<CR>'
				exe "imenu    <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm            <C-C>:call BASH_Toggle_Gvim_Xterm()<CR>'
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

endfunction    " ----------  end of function BASH_Toggle_Gvim_Xterm ----------
"
"------------------------------------------------------------------------------
"  run : make script executable    {{{1
"------------------------------------------------------------------------------
function! BASH_MakeScriptExecutable ()
	let	filename	= escape( expand("%"), s:escfilename )
	silent exe "!chmod u+x ".filename
	redraw
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
"  run : run    {{{1
"------------------------------------------------------------------------------
"
let s:BASH_OutputBufferName   = "Bash-Output"
let s:BASH_OutputBufferNumber = -1
"
function! BASH_Run ( mode )
	silent exe ':cclose'
	"
	let l:currentdir			= getcwd()
	let	l:arguments				= exists("b:BASH_CmdLineArgs") ? " ".b:BASH_CmdLineArgs : ""
	let	l:currentbuffer   = bufname("%")
	let l:fullname				= l:currentdir."/".l:currentbuffer
	let l:fullname				= escape( l:fullname, s:escfilename )
	"
	silent exe ":update"
	"
	if a:mode=="v"
		let tmpfile	= tempname()
		silent exe ":'<,'>write ".tmpfile
	endif
	"
	"------------------------------------------------------------------------------
	"  run : run from the vim command line
	"------------------------------------------------------------------------------
	"
	if s:BASH_OutputGvim == "vim"
		"
		" ----- visual mode ----------
		"
		if a:mode=="v"
			exe ":!${SHELL}< ".tmpfile." -s ".l:arguments
			call delete(tmpfile)
			return
		endif
		"
		" ----- normal mode ----------
		"
		let	makeprg_saved	= &makeprg
		exe	":setlocal makeprg=$SHELL"
		exe	':setlocal errorformat='.s:BASH_Errorformat
		"
		if a:mode=="n"
			exe ":make "l:fullname.l:arguments
		endif
		"
		exe ":setlocal makeprg=".makeprg_saved
		exe	':setlocal errorformat='
		exe	":botright cwindow"

		if l:currentbuffer != bufname("%") && a:mode=="n"
			let	tmpfile_error	= tempname()
			let	pattern	= '^||.*\n\?'
			setlocal modifiable
			" remove the regular script output (appears as comment)
			if search(pattern) != 0
				silent exe ':%s/'.pattern.'//'
			endif
			" read the buffer back to have it parsed and used as the new error list
			silent exe ':write!   '.tmpfile_error
			silent exe ':cgetfile '.tmpfile_error
			setlocal nomodifiable
			silent exe	':cc'
			call delete(tmpfile_error)
		endif
		"
	endif
	"
	"------------------------------------------------------------------------------
	"  run : redirect output to an output buffer
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == "buffer"

		let	l:currentbuffernr = bufnr("%")
		let l:currentdir      = getcwd()

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
				silent exe ":%!${SHELL} ".l:fullname.l:arguments
			endif
			"
			if a:mode=="v"
				silent exe ":%!${SHELL} < ".tmpfile." -s ".l:arguments
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
	"  run : run in a detached xterm
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == "xterm"
		"
		if a:mode=="n"
			silent exe "!xterm -title ".l:fullname." ".s:BASH_XtermDefaults
						\			.' -e '.s:BASH_Wrapper.' '.l:fullname.l:arguments
		endif
		"
		if a:mode=="v"
			let titlestring	= l:fullname.'\ lines\ \ '.line("'<").'\ -\ '.line("'>")
			silent exe ":!xterm -title ".titlestring." ".s:BASH_XtermDefaults
						\			." -e ".s:BASH_Wrapper.' '.tmpfile.l:arguments
		endif
		"
	endif
	"
	if a:mode=="v"
		call delete(tmpfile)
	endif
	"
endfunction    " ----------  end of function BASH_Run  ----------
"
"------------------------------------------------------------------------------
"  run : xterm geometry    {{{1
"------------------------------------------------------------------------------
function! BASH_XtermSize ()
	let regex	= '-geometry\s\+\d\+x\d\+'
	let geom	= matchstr( s:BASH_XtermDefaults, regex )
	let geom	= matchstr( geom, '\d\+x\d\+' )
	let geom	= substitute( geom, 'x', ' ', "" )
	let	answer= BASH_Input("   xterm size (COLUMNS LINES) : ", geom )
	while match(answer, '^\s*\d\+\s\+\d\+\s*$' ) < 0
		let	answer= BASH_Input(" + xterm size (COLUMNS LINES) : ", geom )
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
"  run : Command line arguments    {{{1
"------------------------------------------------------------------------------
function! BASH_CmdLineArguments ()
	let filename = expand("%")
  if filename == ""
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	prompt	= 'command line arguments for "'.filename.'" : '
	if exists("b:BASH_CmdLineArgs")
		let	b:BASH_CmdLineArgs= BASH_Input( prompt, b:BASH_CmdLineArgs )
	else
		let	b:BASH_CmdLineArgs= BASH_Input( prompt , "" )
	endif
endfunction		" ---------- end of function  BASH_CmdLineArguments  ----------
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
			if has("gui_running")
				let	l:snippetfile=browse(0,"read a code snippet",s:BASH_CodeSnippets,"")
			else
				let	l:snippetfile=input("read snippet ", s:BASH_CodeSnippets, "file" )
			end
			if filereadable(l:snippetfile)
				let	linesread= line("$")
				"
				" Prevent the alternate buffer from being set to this files
				let l:old_cpoptions	= &cpoptions
				setlocal cpoptions-=a
				:execute "read ".l:snippetfile
				let &cpoptions	= l:old_cpoptions		" restore previous options
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
			if has("gui_running")
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
			if has("gui_running")
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
"  run : hardcopy    {{{1
"------------------------------------------------------------------------------
function! BASH_Hardcopy (arg1)
	let	Sou		= expand("%")								" name of the file in the current buffer
  if Sou == ""
		redraw
		echohl WarningMsg | echo " no file name " | echohl None
		return
  endif
	let	old_printheader=&printheader
	exe  ':set printheader='.s:BASH_Printheader
	" ----- normal mode ----------------
	if a:arg1=="n"
		silent exe	"hardcopy > ".Sou.".ps"
		echo "file \"".Sou."\" printed to \"".Sou.".ps\""
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		silent exe	"*hardcopy > ".Sou.".ps"
		echo "file \"".Sou."\" (lines ".line("'<")."-".line("'>").") printed to \"".Sou.".ps\""
	endif
	exe  ':set printheader='.escape( old_printheader, ' %' )
endfunction		" ---------- end of function  BASH_Hardcopy  ----------
"
"------------------------------------------------------------------------------
"  Run : settings    {{{1
"------------------------------------------------------------------------------
function! BASH_Settings ()
	let	txt	=     "     Bash-Support settings\n\n"
	let txt = txt."               author name :  \"".s:BASH_AuthorName."\"\n"
	let txt = txt."                  initials :  \"".s:BASH_AuthorRef."\"\n"
	let txt = txt."              autho  email :  \"".s:BASH_Email."\"\n"
	let txt = txt."                   company :  \"".s:BASH_Company."\"\n"
	let txt = txt."                   project :  \"".s:BASH_Project."\"\n"
	let txt = txt."          copyright holder :  \"".s:BASH_CopyrightHolder."\"\n"
	let txt = txt."    code snippet directory :  ".s:BASH_CodeSnippets."\n"
	let txt = txt."        template directory :  ".s:BASH_Template_Directory."\n"
	let txt = txt."glob. syntax check options :  ".s:BASH_SyntaxCheckOptionsGlob."\n"
	if exists("b:BASH_SyntaxCheckOptionsLocal")
		let txt = txt." buf. syntax check options :  ".b:BASH_SyntaxCheckOptionsLocal."\n"
	endif
	if g:BASH_Dictionary_File != ""
		let ausgabe= substitute( g:BASH_Dictionary_File, ",", ",\n                         + ", "g" )
		let txt = txt."        dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt."      current output dest. :  ".s:BASH_OutputGvim."\n"
	let txt = txt."\n"
	let txt = txt."       Additional hot keys\n\n"
	let txt = txt."                  Shift-F1  :  help for builtin under the cursor \n"
	let txt = txt."                   Ctrl-F9  :  update file, run script           \n"
	let txt = txt."                    Alt-F9  :  update file, run syntax check     \n"
	let txt = txt."                  Shift-F9  :  edit command line arguments       \n"
	let txt = txt."                        F9  :  debug script                      \n"
	let	txt = txt."___________________________________________________________________________\n"
	let	txt = txt." Bash-Support, Version ".g:BASH_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction		" ---------- end of function  BASH_Settings  ----------
"
"------------------------------------------------------------------------------
"  run : help bashsupport     {{{1
"------------------------------------------------------------------------------
function! BASH_HelpBASHsupport ()
	try
		:help bashsupport
	catch
		exe ':helptags '.s:plugin_dir.'doc'
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
"
"------------------------------------------------------------------------------
"  BASH_CreateGuiMenus    {{{1
"------------------------------------------------------------------------------
let s:BASH_MenuVisible = 0								" state : 0 = not visible / 1 = visible
"
function! BASH_CreateGuiMenus ()
	if s:BASH_MenuVisible != 1
		aunmenu <silent> &Tools.Load\ Bash\ Support
		amenu   <silent> 40.1000 &Tools.-SEP100- :
		amenu   <silent> 40.1021 &Tools.Unload\ Bash\ Support <C-C>:call BASH_RemoveGuiMenus()<CR>
		call BASH_InitMenu()
		let s:BASH_MenuVisible = 1
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
	if s:BASH_MenuVisible == 1
		if s:BASH_Root == ""
			aunmenu <silent> Comments
			aunmenu <silent> Statements
			aunmenu <silent> Tests
			aunmenu <silent> ParmSub
			aunmenu <silent> SpecVars
			aunmenu <silent> Environ
			aunmenu <silent> Builtins
			aunmenu <silent> set
			aunmenu <silent> shopt
			aunmenu <silent> I/O-Redir
			aunmenu <silent> Run
		else
			exe "aunmenu <silent> ".s:BASH_Root
		endif
		"
		aunmenu <silent> &Tools.Unload\ Bash\ Support
		call BASH_ToolMenu()
		"
		let s:BASH_MenuVisible = 0
	endif
endfunction    " ----------  end of function BASH_RemoveGuiMenus  ----------
"
"------------------------------------------------------------------------------
"  show / hide the menus   {{{1
"  define key mappings (gVim only)
"------------------------------------------------------------------------------
"
if has("gui_running")
	"
	call BASH_ToolMenu()
	"
	if s:BASH_LoadMenus == 'yes'
		call BASH_CreateGuiMenus()
	endif
	"
	nmap    <silent>  <Leader>lbs             :call BASH_CreateGuiMenus()<CR>
	nmap    <silent>  <Leader>ubs             :call BASH_RemoveGuiMenus()<CR>
	"
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion   {{{1
"------------------------------------------------------------------------------
"
if has("autocmd")
	"
	" Bash-script : insert header, write file, make it executable
	"
	autocmd BufNewFile  *.sh    call BASH_CommentTemplates('header') 	|	:w!
	"
endif " has("autocmd")
"
"------------------------------------------------------------------------------
"  Avoid a wrong syntax highlighting for $(..) and $((..))
"------------------------------------------------------------------------------
"
let is_bash	            = 1
"
"------------------------------------------------------------------------------
"  vim: set tabstop=2: set shiftwidth=2:
