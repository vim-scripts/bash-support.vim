"#########################################################################################
"
"       Filename:  bash-support.vim
"  
"    Description:  BASH support     (VIM Version 6.0)
"  
"                  Write BASH-scripts by inserting comments, statements, tests, 
"                  variables and builtins.
"  
"  Configuration:  There are some personal details which should be configured 
"                    (see the files README.bashsupport and bashsupport.txt).
"                    
"   Dependencies:  The environmnent variables $HOME und $SHELL are used.
"  
"   GVIM Version:  6.0+
"  
"         Author:  Dr.-Ing. Fritz Mehner, FH Südwestfalen, 58644 Iserlohn, Germany
"          Email:  mehner@fh-swf.de
"          
"        Version:  see variable  g:BASH_Version  below 
"       Revision:  01.08.2006
"        Created:  26.02.2001
"        License:  Copyright (c) 2001-2006, Fritz Mehner
"                  This program is free software; you can redistribute it and/or
"                  modify it under the terms of the GNU General Public License as
"                  published by the Free Software Foundation, version 2 of the
"                  License.
"                  This program is distributed in the hope that it will be
"                  useful, but WITHOUT ANY WARRANTY; without even the implied
"                  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
"                  PURPOSE.
"                  See the GNU General Public License version 2 for more details.
"  
"------------------------------------------------------------------------------
" 
" Prevent duplicate loading: 
" 
if exists("g:BASH_Version") || &cp
 finish
endif
let g:BASH_Version= "1.14"  						" version number of this script; do not change
"
"#########################################################################################
"
"  Global variables (with default values) which can be overridden.
"
"  Key word completion is enabled by the filetype plugin 'sh.vim'
"  g:BASH_Dictionary_File  must be global
"          
let s:root_dir	  = $HOME.'/.vim/'
"
if !exists("g:BASH_Dictionary_File")
	let g:BASH_Dictionary_File     = s:root_dir.'wordlists/bash.list'
endif
"
"  Modul global variables (with default values) which can be overridden.
"
let s:BASH_AuthorName              = ""
let s:BASH_AuthorRef               = ""
let s:BASH_Company                 = ""
let s:BASH_CopyrightHolder         = ""
let s:BASH_Email                   = ""
let s:BASH_Project                 = ""
"
let s:BASH_CodeSnippets            = s:root_dir."codesnippets-bash/"
let s:BASH_Debugger                = 'term'
let s:BASH_LineEndCommColDefault   = 49
let s:BASH_LoadMenus               = "yes"
let s:BASH_MenuHeader              = "yes"
let s:BASH_OutputGvim              = "vim"
let s:BASH_Root                    = 'B&ash.'         " the name of the root menu of this plugin
let s:BASH_SyntaxCheckOptionsGlob  = ""
let s:BASH_Template_Directory      = s:root_dir."plugin/templates/"
let s:BASH_Template_File           = "bash-file-header"
let s:BASH_Template_Frame          = "bash-frame"
let s:BASH_Template_Function       = "bash-function-description"
let s:BASH_XtermDefaults           = "-fa courier -fs 12 -geometry 80x24"
let s:BASH_Printheader             = "%<%f%h%m%<  %=%{strftime('%x %X')}     Page %N"
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
" Bash 3.0 shopt options (GNU Bash-3.0, manual: 2004 June 26) 
"
let s:BASH_ShoptAllowed =                     "cdable_vars:cdspell:checkhash:checkwinsize:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."cmdhist:dotglob:execfail:expand_aliases:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."extdebug:extglob:extquote:failglob:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."force_fignore:gnu_errfmt:histappend:histreedit:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."histverify:hostcomplete:huponexit:interactive_comments:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."lithist:login_shell:mailwarn:no_empty_cmd_completion:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."nocaseglob:nullglob:progcomp:promptvars:"
let s:BASH_ShoptAllowed = s:BASH_ShoptAllowed."restricted_shell:shift_verbose:sourcepath:xpg_echo:"
"
"------------------------------------------------------------------------------
"  Look for global variables (if any), to override the defaults.
"------------------------------------------------------------------------------
function! BASH_CheckGlobal ( name )
  if exists('g:'.a:name)
    exe 'let s:'.a:name.'  = g:'.a:name
  endif
endfunction   " ---------- end of function  BASH_CheckGlobal  ----------
"
call BASH_CheckGlobal("BASH_AuthorName             ")
call BASH_CheckGlobal("BASH_AuthorRef              ")
call BASH_CheckGlobal("BASH_CodeSnippets           ")
call BASH_CheckGlobal("BASH_Company                ")
call BASH_CheckGlobal("BASH_CopyrightHolder        ")
call BASH_CheckGlobal("BASH_Debugger               ")
call BASH_CheckGlobal("BASH_Email                  ")
call BASH_CheckGlobal("BASH_LineEndCommColDefault  ")
call BASH_CheckGlobal("BASH_LoadMenus              ")
call BASH_CheckGlobal("BASH_MenuHeader             ")
call BASH_CheckGlobal("BASH_OutputGvim             ")
call BASH_CheckGlobal("BASH_Printheader            ")
call BASH_CheckGlobal("BASH_Project                ")
call BASH_CheckGlobal("BASH_Root                   ")
call BASH_CheckGlobal("BASH_SyntaxCheckOptionsGlob ")
call BASH_CheckGlobal("BASH_Template_Directory     ")
call BASH_CheckGlobal("BASH_Template_File          ")
call BASH_CheckGlobal("BASH_Template_Frame         ")
call BASH_CheckGlobal("BASH_Template_Function      ")
call BASH_CheckGlobal("BASH_XtermDefaults          ")
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
"  BASH Menu Initialization
"------------------------------------------------------------------------------
function!	BASH_InitMenu ()
	"
	if has("gui_running")
		"===============================================================================================
		"----- Menu : root menu  ---------------------------------------------------------------------
		"===============================================================================================
		if s:BASH_Root != ""
			if s:BASH_MenuHeader == "yes"
				exe "amenu   ".s:BASH_Root.'Bash          <Esc>'
				exe "amenu   ".s:BASH_Root.'-Sep0-        :'
			endif
		endif
		"
		"-------------------------------------------------------------------------------
		" menu Comments
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu   ".s:BASH_Root.'&Comments.Comments<Tab>Bash           <Esc>'
			exe "amenu   ".s:BASH_Root.'&Comments.-Sep0-              :'
		endif
		exe "amenu           ".s:BASH_Root.'&Comments.&Line\ End\ Comm\.        <Esc><Esc>:call BASH_LineEndComment()<CR>A'
		exe "vmenu <silent>  ".s:BASH_Root.'&Comments.&Line\ End\ Comm\.        <Esc><Esc>:call BASH_MultiLineEndComments()<CR>A'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.&Set\ End\ Comm\.\ Col\.  <Esc><Esc>:call BASH_GetLineEndCommCol()<CR>'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.&Frame\ Comment          <Esc><Esc>:call BASH_CommentTemplates("frame")<CR>'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.F&unction\ Description   <Esc><Esc>:call BASH_CommentTemplates("function")<CR>'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.File\ &Header            <Esc><Esc>:call BASH_CommentTemplates("header")<CR>'
		exe "amenu ".s:BASH_Root.'&Comments.-Sep1-                    :'
		exe "amenu ".s:BASH_Root."&Comments.&code->comment            <Esc><Esc>:s/^/\#/<CR><Esc>:nohlsearch<CR>"
		exe "vmenu ".s:BASH_Root."&Comments.&code->comment            <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>"
		exe "amenu ".s:BASH_Root."&Comments.c&omment->code            <Esc><Esc>:s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>"
		exe "vmenu ".s:BASH_Root."&Comments.c&omment->code            <Esc><Esc>:'<,'>s/^\\(\\s*\\)#/\\1/<CR><Esc>:nohlsearch<CR>"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP2-                    :'
		exe " menu ".s:BASH_Root.'&Comments.&Date                     i<C-R>=strftime("%x")<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.&Date                      <C-R>=strftime("%x")<CR>'
		exe " menu ".s:BASH_Root.'&Comments.Date\ &Time               i<C-R>=strftime("%x %X %Z")<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.Date\ &Time                <C-R>=strftime("%x %X %Z")<CR>'
		"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP3-                    :'
		"
		exe "amenu ".s:BASH_Root.'&Comments.&echo\ "<line>"	  				<Esc><Esc>^iecho<Space>"<Esc>$a"<Esc>j'
		exe "amenu ".s:BASH_Root.'&Comments.&remove\ echo           	<Esc><Esc>0:s/^\s*echo\s\+\"// \| s/\s*\"\s*$// \| :normal ==<CR><Esc>j'
		"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP4-                    :'
		"
		"----- Submenu : BASH-Comments : Keywords  ----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.Comments-1<Tab>Bash       <Esc>'
			exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.-Sep1-          :'
		endif
		exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&BUG              <Esc><Esc>$<Esc>:call BASH_CommentClassified("BUG")     <CR>kgJA'
		exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&TODO             <Esc><Esc>$<Esc>:call BASH_CommentClassified("TODO")    <CR>kgJA'
		exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.T&RICKY           <Esc><Esc>$<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kgJA'
		exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&WARNING          <Esc><Esc>$<Esc>:call BASH_CommentClassified("WARNING") <CR>kgJA'
		exe "amenu ".s:BASH_Root.'&Comments.\#\ \:&KEYWORD\:.&new\ keyword     <Esc><Esc>$<Esc>:call BASH_CommentClassified("")        <CR>kgJf:a'
		"
		"----- Submenu : BASH-Comments : Tags  ----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).Comments-2<Tab>Bash       <Esc>'
			exe "amenu ".s:BASH_Root.'&Comments.ta&gs\ (plugin).-Sep1-          :'
		endif
		"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           a'.s:BASH_AuthorName."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        a'.s:BASH_AuthorRef."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY          a'.s:BASH_Company."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  a'.s:BASH_CopyrightHolder."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL            a'.s:BASH_Email."<Esc>"
		exe "amenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT          a'.s:BASH_Project."<Esc>"

		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&AUTHOR           <Esc>a'.s:BASH_AuthorName
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).AUTHOR&REF        <Esc>a'.s:BASH_AuthorRef
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&COMPANY          <Esc>a'.s:BASH_Company
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).C&OPYRIGHTHOLDER  <Esc>a'.s:BASH_CopyrightHolder
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&EMAIL            <Esc>a'.s:BASH_Email
		exe "imenu  ".s:BASH_Root.'&Comments.ta&gs\ (plugin).&PROJECT          <Esc>a'.s:BASH_Project
		"
		exe "amenu ".s:BASH_Root.'&Comments.&vim\ modeline          <Esc><Esc>:call BASH_CommentVimModeline()<CR>'
		"
		"-------------------------------------------------------------------------------
		" menu Statements
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'St&atements.Statements<Tab>Bash          <Esc>'
			exe "amenu ".s:BASH_Root.'St&atements.-Sep0-             :'
		endif

		exe "amenu ".s:BASH_Root.'St&atements.&case								<Esc><Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a'
		exe "amenu ".s:BASH_Root.'St&atements.&for								<Esc><Esc>ofor  in <CR>do<CR>done<Esc>2k^f<Space>a'
		exe "amenu ".s:BASH_Root.'St&atements.e&lif								<Esc><Esc>oelif <CR>then<Esc>1kA'
		exe "amenu ".s:BASH_Root.'St&atements.&if									<Esc><Esc>oif <CR>then<CR>fi<Esc>2k^A'
		exe "amenu ".s:BASH_Root.'St&atements.if-&else						<Esc><Esc>oif <CR>then<CR>else<CR>fi<Esc>3kA'
		exe "amenu ".s:BASH_Root.'St&atements.&select							<Esc><Esc>oselect  in <CR>do<CR>done<Esc>2kf<Space>a'
		exe "amenu ".s:BASH_Root.'St&atements.un&til							<Esc><Esc>ountil <CR>do<CR>done<Esc>2kA'
		exe "amenu ".s:BASH_Root.'St&atements.&while							<Esc><Esc>owhile <CR>do<CR>done<Esc>2kA'

		exe "vmenu ".s:BASH_Root."St&atements.&for								DOfor  in <CR>do<CR>done<Esc>P2k^<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f<Space>a"
		exe "vmenu ".s:BASH_Root."St&atements.&if									DOif <CR>then<CR>fi<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>A"
		exe "vmenu ".s:BASH_Root."St&atements.if-&else						DOif <CR>then<CR>else<CR>fi<Esc>kP<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>2kA"
		exe "vmenu ".s:BASH_Root."St&atements.&select							DOselect  in <CR>do<CR>done<Esc>P2k^<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f<Space>a"
		exe "vmenu ".s:BASH_Root."St&atements.un&til							DOuntil <CR>do<CR>done<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>A"
		exe "vmenu ".s:BASH_Root."St&atements.&while							DOwhile <CR>do<CR>done<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>A"
		"
		exe "amenu ".s:BASH_Root.'St&atements.-SEP3-              :'

		exe "amenu ".s:BASH_Root.'St&atements.&break							<Esc><Esc>obreak '
		exe "amenu ".s:BASH_Root.'St&atements.co&ntinue						<Esc><Esc>ocontinue '
		exe "amenu ".s:BASH_Root.'St&atements.e&xit								<Esc><Esc>oexit '
		exe "amenu ".s:BASH_Root.'St&atements.f&unction						<Esc><Esc>o<Esc>:call BASH_CodeFunction()<CR>2jA'
		exe "amenu ".s:BASH_Root.'St&atements.&return							<Esc><Esc>oreturn '
		exe "amenu ".s:BASH_Root.'St&atements.s&hift							<Esc><Esc>oshift '
		exe "amenu ".s:BASH_Root.'St&atements.tra&p								<Esc><Esc>otrap '
		"
		exe "amenu ".s:BASH_Root.'St&atements.-SEP1-              :'
		"
		exe " menu ".s:BASH_Root.'St&atements.$&((\.\.\.))				<Esc>a$))))<Esc>3hr(lr(a'
		exe "vmenu ".s:BASH_Root.'St&atements.$&((\.\.\.))				s$))))<Esc>3hr(lr(p'
		exe "imenu ".s:BASH_Root.'St&atements.$&((\.\.\.))				$))))<Esc>3hr(lr(a'
		exe " menu ".s:BASH_Root.'St&atements.$&[[\.\.\.]]				<Esc>a$]]]]<Esc>3hr[lr[a'
		exe "vmenu ".s:BASH_Root.'St&atements.$&[[\.\.\.]]				s$]]]]<Esc>3hr[lr[p'
		exe "imenu ".s:BASH_Root.'St&atements.$&[[\.\.\.]]				$]]]]<Esc>3hr[lr[a'
		"
		exe "amenu ".s:BASH_Root.'St&atements.-SEP4-              :'
		"
		exe "amenu ".s:BASH_Root."St&atements.&'\\.\\.\\.'				<Esc>a''<Esc>i"
		exe "amenu ".s:BASH_Root.'St&atements.&"\.\.\."						<Esc>a""<Esc>i'
		exe "amenu ".s:BASH_Root.'St&atements.&`\.\.\.`						<Esc>a``<Esc>i'
		exe "amenu ".s:BASH_Root.'St&atements.&$(\.\.\.)					<Esc>a$))<Esc>hr(a'
		exe "amenu ".s:BASH_Root.'St&atements.$&{\.\.\.}					<Esc>a$}}<Esc>hr{a'

		exe "imenu ".s:BASH_Root."St&atements.&'\\.\\.\\.'				''<Esc>i"
		exe "imenu ".s:BASH_Root.'St&atements.&"\.\.\."						""<Esc>i'
		exe "imenu ".s:BASH_Root.'St&atements.&`\.\.\.`						``<Esc>i'
		exe "imenu ".s:BASH_Root.'St&atements.&$(\.\.\.)					$))<Esc>hr(a'
		exe "imenu ".s:BASH_Root.'St&atements.$&{\.\.\.}					$}}<Esc>hr{a'

		exe "vmenu ".s:BASH_Root."St&atements.&'\\.\\.\\.'				s''<Esc>Pla"
		exe "vmenu ".s:BASH_Root.'St&atements.&"\.\.\."						s""<Esc>Pla'
		exe "vmenu ".s:BASH_Root.'St&atements.&`\.\.\.`						s``<Esc>Pla'
		exe "vmenu ".s:BASH_Root.'St&atements.&$(\.\.\.)					s$))<Esc>hr(p'
		exe "vmenu ".s:BASH_Root.'St&atements.$&{\.\.\.}					s$}}<Esc>hr{p'
		"
		exe "amenu ".s:BASH_Root.'St&atements.ech&o\ -e\ "\\n"		<Esc><Esc>oecho<Space>-e<Space>"\n"<Esc>2hi'
		exe "imenu ".s:BASH_Root.'St&atements.ech&o\ -e\ "\\n"		echo<Space>-e<Space>"\n"<Esc>2hi'
		exe "vmenu ".s:BASH_Root.'St&atements.ech&o\ -e\ "\\n" 		secho<Space>-e<Space>"\n"<Esc>2hP'
		"
		if s:BASH_CodeSnippets != ""
			exe "amenu  ".s:BASH_Root.'St&atements.-SEP5-                    		  :'
			exe "amenu  <silent> ".s:BASH_Root.'St&atements.read\ code\ snippet   <C-C>:call BASH_CodeSnippets("r")<CR>'
			exe "amenu  <silent> ".s:BASH_Root.'St&atements.write\ code\ snippet  <C-C>:call BASH_CodeSnippets("w")<CR>'
			exe "vmenu  <silent> ".s:BASH_Root.'St&atements.write\ code\ snippet  <C-C>:call BASH_CodeSnippets("wv")<CR>'
			exe "amenu  <silent> ".s:BASH_Root.'St&atements.edit\ code\ snippet   <C-C>:call BASH_CodeSnippets("e")<CR>'
		endif
		"
		"-------------------------------------------------------------------------------
		" menu Tests
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.Tests-0<Tab>Bash          <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.-Sep0-             :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e															    					<Esc>a] -e  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		<Esc>a] -s  ]<Esc>F]r[f]hi'
		" 
		exe "imenu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e																						] -e  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		] -s  ]<Esc>F]r[f]hi'
		" 
		exe "imenu ".s:BASH_Root.'&Tests.-Sep1-                         :'
		"
		"---------- submenu arithmetic tests -----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.Tests-1<Tab>Bash       <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.-Sep0-          :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq										<Esc>a]  -eq  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne										<Esc>a]  -ne  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt												<Esc>a]  -lt  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le				<Esc>a]  -le  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt										<Esc>a]  -gt  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge			<Esc>a]  -ge  ]<Esc>F]r[la'
		"
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq										]  -eq  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne										]  -ne  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt												]  -lt  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le				]  -le  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt										]  -gt  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge			]  -ge  ]<Esc>F]r[la'
		"
		"---------- submenu file exists and has permission ---------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.Tests-2<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r									<Esc>a] -r  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w									<Esc>a] -w  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x								<Esc>a] -x  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u				<Esc>a] -u  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g				<Esc>a] -g  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k	<Esc>a] -k  ]<Esc>F]r[f]hi'
		"
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and											<Esc>'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r									] -r  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w									] -w  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x								] -x  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u				] -u  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g				] -g  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k	] -k  ]<Esc>F]r[f]hi'
		"
		"---------- submenu file exists and has type ----------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.Tests-3<Tab>Bash                                    <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.-Sep0-                         :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a						<Esc>'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			<Esc>a] -b  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	<Esc>a] -c  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								<Esc>a] -d  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>-p			<Esc>a] -p  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						<Esc>a] -f  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										<Esc>a] -S  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						<Esc>a] -L  ]<Esc>F]r[f]hi'
		"
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a			<Esc>'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			] -b  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	] -c  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d								] -d  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>p-			] -p  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f						] -f  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										] -S  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						] -L  ]<Esc>F]r[f]hi'
		"
		"---------- submenu string comparison ------------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.Tests-4<Tab>Bash                                    <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.-Sep0-                         :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z									  	 <Esc>a] -z  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n									 <Esc>a] -n  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal<Tab>==															<Esc>a]  ==  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=													<Esc>a]  !=  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><		 <Esc>a]  <  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>			 <Esc>a]  >  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												<Esc>a]]  =~  ]]<Esc>3F]r[lr[la'
		"                                         
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z											 ] -z  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n									 ] -n  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal<Tab>==															]  ==  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=													]  !=  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><		 ]  <  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>			 ]  >  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.string\ matches\ &regexp<Tab>=~												]]  =~  ]]<Esc>3F]r[lr[la'
		"
		exe "	menu ".s:BASH_Root.'&Tests.-Sep2-                         :'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O								<Esc>a] -O  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G								<Esc>a] -G  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N		<Esc>a] -N  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t					<Esc>a] -t  ]<Esc>F]r[f]hi'
		exe "	menu ".s:BASH_Root.'&Tests.-Sep3-                         :'
		exe "	menu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt									<Esc>a]  -nt  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																				<Esc>a]  -ot  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef			<Esc>a]  -ef  ]<Esc>F]r[la'
		exe "	menu ".s:BASH_Root.'&Tests.-Sep4-                         :'
		exe "	menu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																	<Esc>a] -o  ]<Esc>F]r[f]hi'
		"
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O                ] -O  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G								] -G  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N		] -N  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t					] -t  ]<Esc>F]r[f]hi'
		exe "imenu ".s:BASH_Root.'&Tests.-Sep3-                         :'
		exe "imenu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt									]  -nt  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																				]  -ot  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef			]  -ef  ]<Esc>F]r[la'
		exe "imenu ".s:BASH_Root.'&Tests.-Sep4-                         :'
		exe "imenu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																	] -o  ]<Esc>F]r[f]hi'
		"
		"-------------------------------------------------------------------------------
		" menu Parameter Substitution
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&ParmSub.ParmSub<Tab>Bash        <Esc>'
			exe "amenu ".s:BASH_Root.'&ParmSub.-Sep0-           :'
		endif

    exe "vmenu ".s:BASH_Root.'&ParmSub.S&ubstitution\ <Tab>${}                                 s$}}<Esc>hr{p'

    exe " menu ".s:BASH_Root.'&ParmSub.S&ubstitution\ <Tab>${}                                 <Esc>a$}}<ESC>hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.Use\ &Default\ Value<Tab>${:-}                          <Esc>a$}:-}<ESC>3hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.&Assign\ Default\ Value<Tab>${:=}                       <Esc>a$}:=}<ESC>3hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.Display\ &Error\ if\ Null\ or\ Unset<Tab>${:?}          <Esc>a$}:?}<ESC>3hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.Use\ Alternate\ &Value<Tab>${:+}                        <Esc>a$}:+}<ESC>3hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.&substring\ expansion<Tab>${::}                         <Esc>a$}::}<ESC>3hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.List\ of\ variables\ &beginning\ with\ prefix<Tab>${!*} <Esc>a$}!*}<ESC>3hr{la'
    exe " menu ".s:BASH_Root.'&ParmSub.List\ of\ array\ &indices\ assigned<Tab>${![*]}         <Esc>a$}!]*]}<ESC>2F]r[F}r{la'
    exe " menu ".s:BASH_Root.'&ParmSub.&parameter\ length\ in\ characters<Tab>${#}             <Esc>a$}#}<ESC>2hr{la'
    exe " menu ".s:BASH_Root.'&ParmSub.match\ beginning;\ delete\ &shortest\ part<Tab>${#}     <Esc>a$}#}<ESC>2hr{a'
    exe " menu ".s:BASH_Root.'&ParmSub.match\ beginning;\ delete\ &longest\ part<Tab>${##}     <Esc>a$}##}<ESC>F}r{a'
    exe " menu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ s&hortest\ part<Tab>${%}           <Esc>a$}%}<ESC>F}r{a'
    exe " menu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ l&ongest\ part<Tab>${%%}           <Esc>a$}%%}<ESC>F}r{a'
    exe " menu ".s:BASH_Root.'&ParmSub.&replace\ first\ match<Tab>${/\ /\ }                    <Esc>a$}/ / }<ESC>F}r{a'
    exe " menu ".s:BASH_Root.'&ParmSub.replace\ all\ &matches<Tab>${//\ /\ }                   <Esc>a$}// / }<ESC>F}r{a'
    "
    exe "imenu ".s:BASH_Root.'&ParmSub.S&ubstitution\ <Tab>${}                                 $}}<ESC>hr{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.Use\ &Default\ Value<Tab>${:-}                          $}:-}<ESC>3hr{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.&Assign\ Default\ Value<Tab>${:=}                       $}:=}<ESC>3hr{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.Display\ &Error\ if\ Null\ or\ Unset<Tab>${:?}          $}:?}<ESC>3hr{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.Use\ Alternate\ &Value<Tab>${:+}                        $}:+}<ESC>3hr{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.&substring\ expansion<Tab>${::}                         $}::}<ESC>3hr{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.List\ of\ variables\ &beginning\ with\ prefix<Tab>${!*} $}!*}<ESC>3hr{la'
    exe "imenu ".s:BASH_Root.'&ParmSub.List\ of\ array\ &indices\ assigned<Tab>${![*]}         $}!]*]}<ESC>2F]r[F}r{la'
    exe "imenu ".s:BASH_Root.'&ParmSub.&parameter\ length\ in\ characters<Tab>${#}             $}#}<ESC>2hr{la'
    exe "imenu ".s:BASH_Root.'&ParmSub.match\ beginning;\ delete\ &shortest\ part<Tab>${#}     $}#}<ESC>F}r{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.match\ beginning;\ delete\ &longest\ part<Tab>${##}     $}##}<ESC>F}r{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ s&hortest\ part<Tab>${%}           $}%}<ESC>F}r{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.match\ end;\ delete\ l&ongest\ part<Tab>${%%}           $}%%}<ESC>F}r{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.&replace\ first\ match<Tab>${/\ /\ }                    $}/ / }<ESC>F}r{a'
    exe "imenu ".s:BASH_Root.'&ParmSub.replace\ all\ &matches<Tab>${//\ /\ }                   $}// / }<ESC>F}r{a'
		"
		"-------------------------------------------------------------------------------
		" menu Special Variables
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Spec&Vars.SpecVars<Tab>Bash       <Esc>'
			exe "amenu ".s:BASH_Root.'Spec&Vars.-Sep0-          :'
		endif

		exe "	menu ".s:BASH_Root.'Spec&Vars.&Number\ of\ posit\.\ param\.<Tab>${#}								<Esc>a$}#}<Esc>2hr{2l'
		exe "	menu ".s:BASH_Root.'Spec&Vars.&All\ posit\.\ param\.\ (quoted\ spaces)<Tab>${*}			<Esc>a$}*}<Esc>2hr{2l'
		exe "	menu ".s:BASH_Root.'Spec&Vars.All\ posit\.\ param\.\ (&unquoted\ spaces)<Tab>${@}		<Esc>a$}@}<Esc>2hr{2l'
		exe "	menu ".s:BASH_Root.'Spec&Vars.&Flags\ set<Tab>${-}																	<Esc>a$}-}<Esc>2hr{2l'
		exe "	menu ".s:BASH_Root.'Spec&Vars.&Return\ code\ of\ last\ command<Tab>${?}							<Esc>a$}?}<Esc>2hr{2l'
		exe "	menu ".s:BASH_Root.'Spec&Vars.&PID\ of\ this\ shell<Tab>${$}												<Esc>a$}$}<Esc>2hr{2l'
		exe "	menu ".s:BASH_Root.'Spec&Vars.PID\ of\ last\ &background\ command<Tab>${!}					<Esc>a$}!}<Esc>2hr{2l'
		"
		exe "imenu ".s:BASH_Root.'Spec&Vars.&Number\ of\ posit\.\ param\.<Tab>${#}								$}#}<Esc>2hr{2la'
		exe "imenu ".s:BASH_Root.'Spec&Vars.&All\ posit\.\ param\.\ (quoted\ spaces)<Tab>${*}			$}*}<Esc>2hr{2la'
		exe "imenu ".s:BASH_Root.'Spec&Vars.All\ posit\.\ param\.\ (&unquoted\ spaces)<Tab>${@}		$}@}<Esc>2hr{2la'
		exe "imenu ".s:BASH_Root.'Spec&Vars.&Flags\ set<Tab>${-}																	$}-}<Esc>2hr{2la'
		exe "imenu ".s:BASH_Root.'Spec&Vars.&Return\ code\ of\ last\ command<Tab>${?}							$}?}<Esc>2hr{2la'
		exe "imenu ".s:BASH_Root.'Spec&Vars.&PID\ of\ this\ shell<Tab>${$}												$}$}<Esc>2hr{2la'
		exe "imenu ".s:BASH_Root.'Spec&Vars.PID\ of\ last\ &background\ command<Tab>${!}					$}!}<Esc>2hr{2la'
		"
		"-------------------------------------------------------------------------------
		" menu Environment Variables
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.Environ<Tab>Bash     <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.-Sep0-        :'
		endif
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.Environ-1<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.&BASH            <Esc>a$}BASH}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&C       <Esc>a$}BASH_ARGC}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&V       <Esc>a$}BASH_ARGV}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_C&OMMAND    <Esc>a$}BASH_COMMAND}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&ENV        <Esc>a$}BASH_ENV}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_E&XE\.STR\. <Esc>a$}BASH_EXECUTION_STRING}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&LINENO     <Esc>a$}BASH_LINENO}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&REMATCH    <Esc>a$}BASH_REMATCH}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&SOURCE     <Esc>a$}BASH_SOURCE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_S&UBSHELL   <Esc>a$}BASH_SUBSHELL}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERS&INFO   <Esc>a$}BASH_VERSINFO}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERSIO&N    <Esc>a$}BASH_VERSION}<Esc>F}r{f}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.Environ-2<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&CDPATH          <Esc>a$}CDPATH}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.C&OLUMNS         <Esc>a$}COLUMNS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.CO&MPREPLY       <Esc>a$}COMPREPLY}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COM&P_CWORD      <Esc>a$}COMP_CWORD}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&LINE       <Esc>a$}COMP_LINE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_POI&NT      <Esc>a$}COMP_POINT}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_WORD&BREAKS <Esc>a$}COMP_WORDBREAKS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&WORDS      <Esc>a$}COMP_WORDS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&DIRSTACK        <Esc>a$}DIRSTACK}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EMAC&S          <Esc>a$}EMACS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EUID            <Esc>a$}EUID}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&FCEDIT          <Esc>a$}FCEDIT}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&IGNORE         <Esc>a$}FIGNORE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&UNCNAME        <Esc>a$}FUNCNAME}<Esc>F}r{f}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.Environ-3<Tab>Bash                                    <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.-Sep0-                         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE     <Esc>a$}GLOBIGNORE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS         <Esc>a$}GROUPS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD        <Esc>a$}HISTCMD}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL    <Esc>a$}HISTCONTROL}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE       <Esc>a$}HISTFILE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE   <Esc>a$}HISTFILESIZE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE     <Esc>a$}HISTIGNORE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE       <Esc>a$}HISTSIZE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTTI&MEFORMAT <Esc>a$}HISTTIMEFORMAT}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME           <Esc>a$}HOME}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E       <Esc>a$}HOSTFILE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME       <Esc>a$}HOSTNAME}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE       <Esc>a$}HOSTTYPE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS            <Esc>a$}IFS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF      <Esc>a$}IGNOREEOF}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C        <Esc>a$}INPUTRC}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG           <Esc>a$}LANG}<Esc>F}r{f}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.Environ-4<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          <Esc>a$}LC_ALL}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      <Esc>a$}LC_COLLATE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        <Esc>a$}LC_CTYPE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     <Esc>a$}LC_MESSAGES}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      <Esc>a$}LC_NUMERIC}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          <Esc>a$}LINENO}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           <Esc>a$}LINES}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        <Esc>a$}MACHTYPE}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            <Esc>a$}MAIL}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       <Esc>a$}MAILCHECK}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        <Esc>a$}MAILPATH}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          <Esc>a$}OLDPWD}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          <Esc>a$}OPTARG}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          <Esc>a$}OPTERR}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          <Esc>a$}OPTIND}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          <Esc>a$}OSTYPE}<Esc>F}r{f}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.Environ-5<Tab>Bash           <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.-Sep0-              :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&PATH                 <Esc>a$}PATH}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           <Esc>a$}PIPESTATUS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      <Esc>a$}POSIXLY_CORRECT}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 <Esc>a$}PPID}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       <Esc>a$}PROMPT_COMMAND}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&1                  <Esc>a$}PS1}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&2                  <Esc>a$}PS2}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&3                  <Esc>a$}PS3}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&4                  <Esc>a$}PS4}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&WD                  <Esc>a$}PWD}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               <Esc>a$}RANDOM}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                <Esc>a$}REPLY}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              <Esc>a$}SECONDS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.S&HELL                <Esc>a$}SHELL}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&ELLOPTS            <Esc>a$}SHELLOPTS}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                <Esc>a$}SHLVL}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           <Esc>a$}TIMEFORMAT}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                <Esc>a$}TMOUT}<Esc>F}r{f}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&UID                  <Esc>a$}UID}<Esc>F}r{f}'

		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.&BASH            $}BASH}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&C       $}BASH_ARGC}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_ARG&V       $}BASH_ARGV}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_C&OMMAND    $}BASH_COMMAND}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&ENV        $}BASH_ENV}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_E&XE\.STR\. $}BASH_EXECUTION_STRING}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&LINENO     $}BASH_LINENO}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&REMATCH    $}BASH_REMATCH}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_&SOURCE     $}BASH_SOURCE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_S&UBSHELL   $}BASH_SUBSHELL}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERS&INFO   $}BASH_VERSINFO}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ BASH_VERSION.BASH_VERSIO&N    $}BASH_VERSION}<Esc>F}r{f}a'

		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&CDPATH          $}CDPATH}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.C&OLUMNS         $}COLUMNS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.CO&MPREPLY       $}COMPREPLY}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COM&P_CWORD      $}COMP_CWORD}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&LINE       $}COMP_LINE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_POI&NT      $}COMP_POINT}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_WORD&BREAKS $}COMP_WORDBREAKS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.COMP_&WORDS      $}COMP_WORDS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&DIRSTACK        $}DIRSTACK}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EMAC&S          $}EMACS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&EUID            $}EUID}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.&FCEDIT          $}FCEDIT}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&IGNORE         $}FIGNORE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&CDPATH\ \.\.\.\ FUNCNAME.F&UNCNAME        $}FUNCNAME}<Esc>F}r{f}a'
		"
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE     $}GLOBIGNORE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS         $}GROUPS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD        $}HISTCMD}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL    $}HISTCONTROL}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE       $}HISTFILE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE   $}HISTFILESIZE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE     $}HISTIGNORE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE       $}HISTSIZE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTTI&MEFORMAT $}HISTTIMEFORMAT}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME           $}HOME}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E       $}HOSTFILE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME       $}HOSTNAME}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE       $}HOSTTYPE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS            $}IFS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF      $}IGNOREEOF}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C        $}INPUTRC}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG           $}LANG}<Esc>F}r{f}a'
		"
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          $}LC_ALL}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      $}LC_COLLATE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        $}LC_CTYPE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     $}LC_MESSAGES}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      $}LC_NUMERIC}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          $}LINENO}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           $}LINES}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        $}MACHTYPE}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            $}MAIL}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       $}MAILCHECK}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        $}MAILPATH}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          $}OLDPWD}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          $}OPTARG}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          $}OPTERR}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          $}OPTIND}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          $}OSTYPE}<Esc>F}r{f}a'
		"
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&PATH                 $}PATH}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           $}PIPESTATUS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      $}POSIXLY_CORRECT}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 $}PPID}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       $}PROMPT_COMMAND}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&1                  $}PS1}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&2                  $}PS2}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&3                  $}PS3}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&4                  $}PS4}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&WD                  $}PWD}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               $}RANDOM}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                $}REPLY}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              $}SECONDS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.S&HELL                $}SHELL}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&ELLOPTS            $}SHELLOPTS}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                $}SHLVL}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           $}TIMEFORMAT}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                $}TMOUT}<Esc>F}r{f}a'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&UID                  $}UID}<Esc>F}r{f}a'
		"
		"-------------------------------------------------------------------------------
		" menu Builtins  a-l
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'B&uiltins\ \ a-l.Builtins\ 1<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'B&uiltins\ \ a-l.-Sep0-         :'
		endif
		"
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&alias      <Esc>aalias<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.b&ind       <Esc>abind<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&builtin    <Esc>abuiltin<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&cd         <Esc>acd<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.c&ommand    <Esc>acommand<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.co&mpgen    <Esc>acompgen<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.com&plete   <Esc>acomplete<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&declare    <Esc>adeclare<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.dir&s       <Esc>adirs<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&echo       <Esc>aecho<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.e&nable     <Esc>aenable<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.e&val       <Esc>aeval<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.e&xec       <Esc>aexec<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.expo&rt     <Esc>aexport<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&getopts    <Esc>agetopts<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&hash       <Esc>ahash<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&kill       <Esc>akill<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.&let        <Esc>alet<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ a-l.local\ (&1) <Esc>alocal<Space>'
		"
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&alias      alias<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.b&ind       bind<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&builtin    builtin<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&cd         cd<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.c&ommand    command<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.co&mpgen    compgen<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.com&plete   complete<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&declare    declare<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.dir&s       dirs<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&echo       echo<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.e&nable     enable<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.e&val       eval<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.e&xec       exec<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.expo&rt     export<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&getopts    getopts<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&hash       hash<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&kill       kill<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.&let        let<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ a-l.local\ (&1) local<Space>'
		"
		"-------------------------------------------------------------------------------
		" menu Builtins  n-w
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'B&uiltins\ \ n-w.Builtins\ 2<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'B&uiltins\ \ n-w.-Sep0-         :'
		endif
		"
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&newgrp     <Esc>anewgrp<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&popd       <Esc>apopd<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.print&f     <Esc>aprintf<Space>"" '
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.push&d      <Esc>apushd<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.pw&d        <Esc>apwd<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&readonly   <Esc>areadonly<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.r&ead       <Esc>aread<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.retur&n     <Esc>areturn<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&source     <Esc>asource<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&times      <Esc>atimes<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.t&ype       <Esc>atype<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&ulimit     <Esc>aulimit<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.u&mask      <Esc>aumask<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.un&alias    <Esc>aunalias<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.unset\ (&1) <Esc>aunset<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins\ \ n-w.&wait       <Esc>await<Space>'
		"
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&newgrp     newgrp<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&popd       popd<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.print&f     printf<Space>"" '
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.push&d      pushd<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.pw&d        pwd<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&readonly   readonly<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.r&ead       read<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.retur&n     return<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&source     source<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&times      times<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.t&ype       type<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&ulimit     ulimit<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.u&mask      umask<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.un&alias    unalias<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.unset\ (&1) unset<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins\ \ n-w.&wait       wait<Space>'
		"
		"-------------------------------------------------------------------------------
		" menu set
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'s&et.set<Tab>Bash   <Esc>'
			exe "amenu ".s:BASH_Root.'s&et.-Sep0-       	:'
		endif
		"
    exe "amenu ".s:BASH_Root.'s&et.&allexport<Tab>-a       <Esc><Esc>oset -o allexport  '
    exe "amenu ".s:BASH_Root.'s&et.&braceexpand<Tab>-B     <Esc><Esc>oset -o braceexpand'
    exe "amenu ".s:BASH_Root.'s&et.emac&s                  <Esc><Esc>oset -o emacs      '
    exe "amenu ".s:BASH_Root.'s&et.&errexit<Tab>-e         <Esc><Esc>oset -o errexit    '
    exe "amenu ".s:BASH_Root.'s&et.e&rrtrace<Tab>-E        <Esc><Esc>oset -o errtrace   '
    exe "amenu ".s:BASH_Root.'s&et.func&trace<Tab>-T       <Esc><Esc>oset -o functrace  '
    exe "amenu ".s:BASH_Root.'s&et.&hashall<Tab>-h         <Esc><Esc>oset -o hashall    '
    exe "amenu ".s:BASH_Root.'s&et.histexpand\ (&1)<Tab>-H <Esc><Esc>oset -o histexpand '
    exe "amenu ".s:BASH_Root.'s&et.hist&ory                <Esc><Esc>oset -o history    '
    exe "amenu ".s:BASH_Root.'s&et.i&gnoreeof              <Esc><Esc>oset -o ignoreeof  '
    exe "amenu ".s:BASH_Root.'s&et.&keyword<Tab>-k         <Esc><Esc>oset -o keyword    '
    exe "amenu ".s:BASH_Root.'s&et.&monitor<Tab>-m         <Esc><Esc>oset -o monitor    '
    exe "amenu ".s:BASH_Root.'s&et.no&clobber<Tab>-C       <Esc><Esc>oset -o noclobber  '
    exe "amenu ".s:BASH_Root.'s&et.&noexec<Tab>-n          <Esc><Esc>oset -o noexec     '
    exe "amenu ".s:BASH_Root.'s&et.nog&lob<Tab>-f          <Esc><Esc>oset -o noglob     '
    exe "amenu ".s:BASH_Root.'s&et.notif&y<Tab>-b          <Esc><Esc>oset -o notify     '
    exe "amenu ".s:BASH_Root.'s&et.no&unset<Tab>-u         <Esc><Esc>oset -o nounset    '
    exe "amenu ".s:BASH_Root.'s&et.onecm&d<Tab>-t          <Esc><Esc>oset -o onecmd     '
    exe "amenu ".s:BASH_Root.'s&et.physical\ (&2)<Tab>-P   <Esc><Esc>oset -o physical   '
    exe "amenu ".s:BASH_Root.'s&et.pipe&fail               <Esc><Esc>oset -o pipefail   '
    exe "amenu ".s:BASH_Root.'s&et.posix\ (&3)             <Esc><Esc>oset -o posix      '
    exe "amenu ".s:BASH_Root.'s&et.&privileged<Tab>-p      <Esc><Esc>oset -o privileged '
    exe "amenu ".s:BASH_Root.'s&et.&verbose<Tab>-v         <Esc><Esc>oset -o verbose    '
    exe "amenu ".s:BASH_Root.'s&et.v&i                     <Esc><Esc>oset -o vi         '
    exe "amenu ".s:BASH_Root.'s&et.&xtrace<Tab>-x          <Esc><Esc>oset -o xtrace     '
    "
    exe "vmenu ".s:BASH_Root.'s&et.&allexport<Tab>-a       D<Esc>:call BASH_set("allexport  ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&braceexpand<Tab>-B     D<Esc>:call BASH_set("braceexpand")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.emac&s                  D<Esc>:call BASH_set("emacs      ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&errexit<Tab>-e         D<Esc>:call BASH_set("errexit    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.e&rrtrace<Tab>-E        D<Esc>:call BASH_set("errtrace   ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.func&trace<Tab>-T       D<Esc>:call BASH_set("functrace  ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&hashall<Tab>-h         D<Esc>:call BASH_set("hashall    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.histexpand\ (&1)<Tab>-H D<Esc>:call BASH_set("histexpand ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.hist&ory                D<Esc>:call BASH_set("history    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.i&gnoreeof              D<Esc>:call BASH_set("ignoreeof  ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&keyword<Tab>-k         D<Esc>:call BASH_set("keyword    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&monitor<Tab>-m         D<Esc>:call BASH_set("monitor    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.no&clobber<Tab>-C       D<Esc>:call BASH_set("noclobber  ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&noexec<Tab>-n          D<Esc>:call BASH_set("noexec     ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.nog&lob<Tab>-f          D<Esc>:call BASH_set("noglob     ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.notif&y<Tab>-b          D<Esc>:call BASH_set("notify     ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.no&unset<Tab>-u         D<Esc>:call BASH_set("nounset    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.onecm&d<Tab>-t          D<Esc>:call BASH_set("onecmd     ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.physical\ (&2)<Tab>-P   D<Esc>:call BASH_set("physical   ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.pipe&fail               D<Esc>:call BASH_set("pipefail   ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.posix\ (&3)             D<Esc>:call BASH_set("posix      ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&privileged<Tab>-p      D<Esc>:call BASH_set("privileged ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&verbose<Tab>-v         D<Esc>:call BASH_set("verbose    ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.v&i                     D<Esc>:call BASH_set("vi         ")<CR>'
    exe "vmenu ".s:BASH_Root.'s&et.&xtrace<Tab>-x          D<Esc>:call BASH_set("xtrace     ")<CR>'
		"
		"-------------------------------------------------------------------------------
		" menu shopt
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'sh&opt.shopt<Tab>Bash   <Esc>'
			exe "amenu ".s:BASH_Root.'sh&opt.-Sep0-    				    :'
		endif
		"
    exe "amenu ".s:BASH_Root.'sh&opt.cdable_vars                <Esc><Esc>oshopt -s cdable_vars'
    exe "amenu ".s:BASH_Root.'sh&opt.cdspell                    <Esc><Esc>oshopt -s cdspell'
    exe "amenu ".s:BASH_Root.'sh&opt.checkhash                  <Esc><Esc>oshopt -s checkhash'
    exe "amenu ".s:BASH_Root.'sh&opt.checkwinsize               <Esc><Esc>oshopt -s checkwinsize'
    exe "amenu ".s:BASH_Root.'sh&opt.cmdhist                    <Esc><Esc>oshopt -s cmdhist'
    exe "amenu ".s:BASH_Root.'sh&opt.dotglob                    <Esc><Esc>oshopt -s dotglob'
    exe "amenu ".s:BASH_Root.'sh&opt.execfail                   <Esc><Esc>oshopt -s execfail'
    exe "amenu ".s:BASH_Root.'sh&opt.expand_aliases             <Esc><Esc>oshopt -s expand_aliases'
    exe "amenu ".s:BASH_Root.'sh&opt.extdebug                   <Esc><Esc>oshopt -s extdebug'
    exe "amenu ".s:BASH_Root.'sh&opt.extglob                    <Esc><Esc>oshopt -s extglob'
    exe "amenu ".s:BASH_Root.'sh&opt.extquote                   <Esc><Esc>oshopt -s extquote'
    exe "amenu ".s:BASH_Root.'sh&opt.failglob                   <Esc><Esc>oshopt -s failglob'
    exe "amenu ".s:BASH_Root.'sh&opt.force_fignore              <Esc><Esc>oshopt -s force_fignore'
    exe "amenu ".s:BASH_Root.'sh&opt.gnu_errfmt                 <Esc><Esc>oshopt -s gnu_errfmt'
    exe "amenu ".s:BASH_Root.'sh&opt.histappend                 <Esc><Esc>oshopt -s histappend'
    exe "amenu ".s:BASH_Root.'sh&opt.histreedit                 <Esc><Esc>oshopt -s histreedit'
    exe "amenu ".s:BASH_Root.'sh&opt.histverify                 <Esc><Esc>oshopt -s histverify'
    exe "amenu ".s:BASH_Root.'sh&opt.hostcomplete               <Esc><Esc>oshopt -s hostcomplete'
    exe "amenu ".s:BASH_Root.'sh&opt.huponexit                  <Esc><Esc>oshopt -s huponexit'
    exe "amenu ".s:BASH_Root.'sh&opt.interactive_comments       <Esc><Esc>oshopt -s interactive_comments'
    exe "amenu ".s:BASH_Root.'sh&opt.lithist                    <Esc><Esc>oshopt -s lithist'
    exe "amenu ".s:BASH_Root.'sh&opt.login_shell                <Esc><Esc>oshopt -s login_shell'
    exe "amenu ".s:BASH_Root.'sh&opt.mailwarn                   <Esc><Esc>oshopt -s mailwarn'
    exe "amenu ".s:BASH_Root.'sh&opt.no_empty_cmd_completion    <Esc><Esc>oshopt -s no_empty_cmd_completion'
    exe "amenu ".s:BASH_Root.'sh&opt.nocaseglob                 <Esc><Esc>oshopt -s nocaseglob'
    exe "amenu ".s:BASH_Root.'sh&opt.nullglob                   <Esc><Esc>oshopt -s nullglob'
    exe "amenu ".s:BASH_Root.'sh&opt.progcomp                   <Esc><Esc>oshopt -s progcomp'
    exe "amenu ".s:BASH_Root.'sh&opt.promptvars                 <Esc><Esc>oshopt -s promptvars'
    exe "amenu ".s:BASH_Root.'sh&opt.restricted_shell           <Esc><Esc>oshopt -s restricted_shell'
    exe "amenu ".s:BASH_Root.'sh&opt.shift_verbose              <Esc><Esc>oshopt -s shift_verbose'
    exe "amenu ".s:BASH_Root.'sh&opt.sourcepath                 <Esc><Esc>oshopt -s sourcepath'
    exe "amenu ".s:BASH_Root.'sh&opt.xpg_echo                   <Esc><Esc>oshopt -s xpg_echo'
		"
    exe "vmenu ".s:BASH_Root.'sh&opt.cdable_vars               D<Esc>:call BASH_shopt("cdable_vars")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.cdspell                   D<Esc>:call BASH_shopt("cdspell")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.checkhash                 D<Esc>:call BASH_shopt("checkhash")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.checkwinsize              D<Esc>:call BASH_shopt("checkwinsize")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.cmdhist                   D<Esc>:call BASH_shopt("cmdhist")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.dotglob                   D<Esc>:call BASH_shopt("dotglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.execfail                  D<Esc>:call BASH_shopt("execfail")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.expand_aliases            D<Esc>:call BASH_shopt("expand_aliases")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.extdebug                  D<Esc>:call BASH_shopt("extdebug")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.extglob                   D<Esc>:call BASH_shopt("extglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.extquote                  D<Esc>:call BASH_shopt("extquote")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.failglob                  D<Esc>:call BASH_shopt("failglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.force_fignore             D<Esc>:call BASH_shopt("force_fignore")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.gnu_errfmt                D<Esc>:call BASH_shopt("gnu_errfmt")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.histappend                D<Esc>:call BASH_shopt("histappend")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.histreedit                D<Esc>:call BASH_shopt("histreedit")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.histverify                D<Esc>:call BASH_shopt("histverify")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.hostcomplete              D<Esc>:call BASH_shopt("hostcomplete")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.huponexit                 D<Esc>:call BASH_shopt("huponexit")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.interactive_comments      D<Esc>:call BASH_shopt("interactive_comments")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.lithist                   D<Esc>:call BASH_shopt("lithist")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.login_shell               D<Esc>:call BASH_shopt("login_shell")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.mailwarn                  D<Esc>:call BASH_shopt("mailwarn")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.no_empty_cmd_completion   D<Esc>:call BASH_shopt("no_empty_cmd_completion")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.nocaseglob                D<Esc>:call BASH_shopt("nocaseglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.nullglob                  D<Esc>:call BASH_shopt("nullglob")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.progcomp                  D<Esc>:call BASH_shopt("progcomp")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.promptvars                D<Esc>:call BASH_shopt("promptvars")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.restricted_shell          D<Esc>:call BASH_shopt("restricted_shell")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.shift_verbose             D<Esc>:call BASH_shopt("shift_verbose")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.sourcepath                D<Esc>:call BASH_shopt("sourcepath")<CR>'
    exe "vmenu ".s:BASH_Root.'sh&opt.xpg_echo                  D<Esc>:call BASH_shopt("xpg_echo")<CR>'

		"
		"---------- submenu : POSIX character classes --------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Rege&x.Regex<Tab>bash   <Esc>'
			exe "amenu ".s:BASH_Root.'Rege&x.-Sep0-      :'
		endif
		"
		exe "amenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )              	<Esc><Esc>a*)\|)<Esc>2hr(a'
		exe "amenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )              <Esc><Esc>a+)\|)<Esc>2hr(a'
		exe "amenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )            <Esc><Esc>a?)\|)<Esc>2hr(a'
		exe "amenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				   	<Esc><Esc>a@)\|)<Esc>2hr(a'
		exe "amenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )            	<Esc><Esc>a!)\|)<Esc>2hr(a'
		"
		exe "vmenu ".s:BASH_Root.'Rege&x.zero\ or\ more\ \ \ &*(\ \|\ )              	s*)\|)<Esc>2hr(pla'
		exe "vmenu ".s:BASH_Root.'Rege&x.one\ or\ more\ \ \ \ &+(\ \|\ )              s+)\|)<Esc>2hr(pla'
		exe "vmenu ".s:BASH_Root.'Rege&x.zero\ or\ one\ \ \ \ \ &?(\ \|\ )            s?)\|)<Esc>2hr(pla'
		exe "vmenu ".s:BASH_Root.'Rege&x.exactly\ one\ \ \ \ \ &@(\ \|\ )  				   	s@)\|)<Esc>2hr(pla'
		exe "vmenu ".s:BASH_Root.'Rege&x.anyth\.\ except\ \ \ &!(\ \|\ )            	s!)\|)<Esc>2hr(pla'
		"
		exe "amenu ".s:BASH_Root.'Rege&x.-Sep1-      :'
		"
		exe " menu ".s:BASH_Root.'Rege&x.[:&alnum:]		<Esc>a]:alnum:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:alp&ha:]		<Esc>a]:alpha:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:asc&ii:]		<Esc>a]:ascii:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&cntrl:]		<Esc>a]:cntrl:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&digit:]		<Esc>a]:digit:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&graph:]		<Esc>a]:graph:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&lower:]		<Esc>a]:lower:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&print:]		<Esc>a]:print:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:pu&nct:]		<Esc>a]:punct:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&space:]		<Esc>a]:space:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&upper:]		<Esc>a]:upper:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&word:]		<Esc>a]:word:]<Esc>F]r[f]a'
		exe " menu ".s:BASH_Root.'Rege&x.[:&xdigit:]	<Esc>a]:xdigit:]<Esc>F]r[f]a'
		"
		exe "imenu ".s:BASH_Root.'Rege&x.[:&alnum:]		]:alnum:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:alp&ha:]		]:alpha:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:asc&ii:]		]:ascii:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&cntrl:]		]:cntrl:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&digit:]		]:digit:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&graph:]		]:graph:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&lower:]		]:lower:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&print:]		]:print:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:pu&nct:]		]:punct:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&space:]		]:space:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&upper:]		]:upper:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&word:]	 	]:word:]<Esc>F]r[f]a'
		exe "imenu ".s:BASH_Root.'Rege&x.[:&xdigit:]	]:xdigit:]<Esc>F]r[f]a'
		"
		exe " menu ".s:BASH_Root.'Rege&x.&[\ \ \ ]    <Esc>a]]<Esc>hr[a'
		exe "imenu ".s:BASH_Root.'Rege&x.&[\ \ \ ]    <Esc>a]]<Esc>hr[a'
		exe "vmenu ".s:BASH_Root.'Rege&x.&[\ \ \ ]    s]]<Esc>hr[pF[l'
		"
		exe "amenu ".s:BASH_Root.'Rege&x.-Sep2-      :'
		"
		exe "amenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&0]}       			<Esc><Esc>a$}BASH_REMATCH]0]}<Esc>2F]r[F}r{f}a'
		exe "amenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&1]}       			<Esc><Esc>a$}BASH_REMATCH]1]}<Esc>2F]r[F}r{f}a'
		exe "amenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&2]}       			<Esc><Esc>a$}BASH_REMATCH]2]}<Esc>2F]r[F}r{f}a'
		exe "amenu ".s:BASH_Root.'Rege&x.${BASH_REMATCH[&3]}       			<Esc><Esc>a$}BASH_REMATCH]3]}<Esc>2F]r[F}r{f}a'
		"
		"
		"-------------------------------------------------------------------------------
		" menu I/O redirection
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&I/O-Redir.I/O-Redir<Tab>Bash   <Esc>'
			exe "amenu ".s:BASH_Root.'&I/O-Redir.-Sep0-    				    :'
		endif

		exe "	menu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file												<Esc>a<Space><<Space><ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file												<Esc>a<Space>><Space><ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append							<Esc>a<Space>>><Space><ESC>a'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ to\ file								<Esc>a<Space>><Space><ESC>2hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descr\.\ to\ file;\ append	  		<Esc>a<Space>>><Space><ESC>2hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.take\ file\ descr\.\ from\ file								<Esc>a<Space><<Space><ESC>2hi'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descr\.					<Esc>a<Space><& <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descr\.						<Esc>a<Space>>& <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file					<Esc>a<Space>&> <ESC>a'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ STDIN																		<Esc>a<Space><&- <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ STDOUT																	<Esc>a<Space>>&- <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ input\ from\ file\ descr\.\ n						<Esc>a<Space><&- <ESC>3hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ output\ from\ file\ descr\.\ n					<Esc>a<Space>>&- <ESC>3hi'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.here-document			<Esc>a<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
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
		exe "imenu ".s:BASH_Root.'&I/O-Redir.here-document			<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
		"
		"------------------------------------------------------------------------------
		"  menu Run 
		"------------------------------------------------------------------------------
		"   run the script from the local directory 
		"   ( the one in the current buffer ; other versions may exist elsewhere ! )
		" 
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Run.Run<Tab>Bash  <Esc>'
			exe "amenu ".s:BASH_Root.'&Run.-Sep0-        :'
		endif

		exe "amenu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab><C-F9>       <C-C>:call BASH_Run("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab><C-F9>       <C-C>:call BASH_Run("v")<CR>'
		"
		"   set execution right only for the user ( may be user root ! )
		"
		exe "amenu <silent> ".s:BASH_Root.'&Run.cmd\.\ line\ &arg\.<Tab><S-F9>         <C-C>:call BASH_CmdLineArguments()<CR>'
		exe "amenu <silent> ".s:BASH_Root.'&Run.start\ &debugger<Tab><F9>              <C-C>:call BASH_Debugger()<CR>'
		exe "amenu <silent> ".s:BASH_Root.'&Run.make\ script\ &executable              <C-C>:call BASH_MakeScriptExecutable()<CR>'
		exe "amenu <silent> ".s:BASH_Root.'&Run.save\ +\ &check\ syntax<Tab><A-F9>     <C-C>:call BASH_SyntaxCheck()<CR>'
		exe "amenu <silent> ".s:BASH_Root.'&Run.syntax\ check\ o&ptions                <C-C>:call BASH_SyntaxCheckOptionsLocal()<CR>'
		"
		exe "amenu          ".s:BASH_Root.'&Run.-Sep1-                                 :'
		"
		exe "amenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps            <C-C>:call BASH_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ to\ FILENAME\.ps            <C-C>:call BASH_Hardcopy("v")<CR>'
		exe "imenu          ".s:BASH_Root.'&Run.-SEP2-                                 :'
		exe "amenu <silent> ".s:BASH_Root.'&Run.plugin\ &settings                      <C-C>:call BASH_Settings()<CR>'
		"
		exe "imenu          ".s:BASH_Root.'&Run.-SEP3-                                 :'
		"
		exe "amenu  <silent>  ".s:BASH_Root.'&Run.x&term\ size                         <C-C>:call BASH_XtermSize()<CR>'
		if s:BASH_OutputGvim == "vim" 
			exe "amenu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm       <C-C>:call BASH_Toggle_Gvim_Xterm()<CR><CR>'
		else
			if s:BASH_OutputGvim == "buffer" 
				exe "amenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR><CR>'
			else
				exe "amenu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer     <C-C>:call BASH_Toggle_Gvim_Xterm()<CR><CR>'
			endif
		endif
		"
		"===============================================================================================
		"----- Menu : help  ----------------------------------------------------------------------------
		"===============================================================================================
		"
		if s:BASH_Root != ""
			exe "menu  <silent>  ".s:BASH_Root.'&help\ \(plugin\)        <C-C><C-C>:call BASH_HelpBASHsupport()<CR>'
		endif
		"
	endif

endfunction		" ---------- end of function  BASH_InitMenu  ----------
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt
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
"  Comments : get line-end comment position
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
"  Comments : single line-end comment
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
"  Comments : multi line-end comments
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
	" ----- back to the beginof the marked block -----
	normal '<
endfunction		" ---------- end of function  BASH_MultiLineEndComments  ----------
"
"------------------------------------------------------------------------------
"  Substitute tags
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
"  Bash-Comments : Insert Template Files
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
		call  BASH_SubstituteTag( pos1, pos2, '|FILENAME|',        expand("%:t")        )
		call  BASH_SubstituteTag( pos1, pos2, '|DATE|',            strftime("%x %X %Z") )
		call  BASH_SubstituteTag( pos1, pos2, '|TIME|',            strftime("%X")       )
		call  BASH_SubstituteTag( pos1, pos2, '|YEAR|',            strftime("%Y")       )
		call  BASH_SubstituteTag( pos1, pos2, '|AUTHOR|',          s:BASH_AuthorName       )
		call  BASH_SubstituteTag( pos1, pos2, '|EMAIL|',           s:BASH_Email            )
		call  BASH_SubstituteTag( pos1, pos2, '|AUTHORREF|',       s:BASH_AuthorRef        )
		call  BASH_SubstituteTag( pos1, pos2, '|PROJECT|',         s:BASH_Project          )
		call  BASH_SubstituteTag( pos1, pos2, '|COMPANY|',         s:BASH_Company          )
		call  BASH_SubstituteTag( pos1, pos2, '|COPYRIGHTHOLDER|', s:BASH_CopyrightHolder  )
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
"  Comments : classified comments
"------------------------------------------------------------------------------
function! BASH_CommentClassified (class)
  	put = '			# :'.a:class.':'.strftime(\"%x\").':'.s:BASH_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  Comments : vim modeline
"------------------------------------------------------------------------------
function! BASH_CommentVimModeline ()
  	put = '# vim: set tabstop='.&tabstop.' shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function BASH_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  Stmts : function
"------------------------------------------------------------------------------
function! BASH_CodeFunction ()
	let	identifier=BASH_Input("function name : ", "" )
	if identifier != ""
		let zz=    "function ".identifier." ()\n{\n\t\n}"
		let zz= zz."    # ----------  end of function ".identifier."  ----------"
		put =zz
	endif
endfunction		" ---------- end of function  BASH_CodeFunction  ----------
"
"------------------------------------------------------------------------------
"  BASH_help : lookup word under the cursor or ask
"------------------------------------------------------------------------------
"
let s:BASH_DocBufferName       = "BASH_HELP"
let s:BASH_DocHelpBufferNumber = -1
let s:BASH_DocSearchWord       = ""
"
function! BASH_help()

	let	item=expand("<cword>")				" word under the cursor 
	if  item == ""
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
"  run : Syntax Check, check if local options does exist
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
"  run : Syntax Check, local options
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
"  run : syntax check
"------------------------------------------------------------------------------
function! BASH_SyntaxCheck ()
	exe	":cclose"
	let	l:currentbuffer=bufname("%")
	exe	":update"
	exe	"set makeprg=$SHELL"
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
	exe "make -n ".options." -- ./% "
	exe	":botright cwindow"								
	exe	':setlocal errorformat='
	exe	"set makeprg=make"
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
"  run : debugger
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
			silent exe "!xterm ".s:BASH_XtermDefaults.' -e bash --debugger ./'.Sou.l:arguments.' &'
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
		silent exe '!bash --debugger ./'.Sou.l:arguments
	endif
endfunction		" ---------- end of function  BASH_Debugger  ----------
"
"----------------------------------------------------------------------
"  run : toggle output destination
"----------------------------------------------------------------------
function! BASH_Toggle_Gvim_Xterm ()
	
	if has("gui_running")
		if s:BASH_OutputGvim == "vim"
			exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm'
			exe "amenu    <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim              <C-C>:call BASH_Toggle_Gvim_Xterm()<CR><CR>'
			let	s:BASH_OutputGvim	= "buffer"
		else
			if s:BASH_OutputGvim == "buffer"
				exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ BUFFER->xterm->vim'
				exe "amenu    <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer             <C-C>:call BASH_Toggle_Gvim_Xterm()<CR><CR>'
				let	s:BASH_OutputGvim	= "xterm"
			else
				" ---------- output : xterm -> gvim
				exe "aunmenu  <silent>  ".s:BASH_Root.'&Run.&output:\ XTERM->vim->buffer'
				exe "amenu    <silent>  ".s:BASH_Root.'&Run.&output:\ VIM->buffer->xterm            <C-C>:call BASH_Toggle_Gvim_Xterm()<CR><CR>'
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
"  run : make script executable
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
"  run : run
"------------------------------------------------------------------------------
"
let s:BASH_OutputBufferName   = "Bash-Output"
let s:BASH_OutputBufferNumber = -1
"
function! BASH_Run ( mode )
	"
	let l:currentdir			= getcwd()
	let	l:arguments				= exists("b:BASH_CmdLineArgs") ? " ".b:BASH_CmdLineArgs : ""
	let	l:currentbuffer   = bufname("%")
	let l:fullname				= l:currentdir."/".l:currentbuffer
	" escape whitespaces
	let l:fullname				= escape( l:fullname, s:escfilename )
	" 
	silent exe ":update"
	"
	if a:mode=="v"
		let tmpfile	= tempname()
		let pos1		= line("'<")
		let pos2		= line("'>")
		silent exe ":'<,'>write ".tmpfile 
	endif
	"
	if a:mode=="n" && !executable(l:fullname) 
		call BASH_MakeScriptExecutable ()
	endif
	"
	"------------------------------------------------------------------------------
	"  run : run from the vim command line
	"------------------------------------------------------------------------------
	if s:BASH_OutputGvim == "vim"
		"
		if a:mode=="n"
			exe "!".l:fullname.l:arguments
		endif
		
		if a:mode=="v"
			exe "!bash < ".tmpfile." -s ".l:arguments
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
				setlocal buftype=nofile
				setlocal noswapfile
				setlocal syntax=none
				setlocal bufhidden=delete
			endif
			"
			" run script 
			"
			setlocal	modifiable
			if a:mode=="n"
				silent exe ":%!".l:fullname.l:arguments
			endif
			"
			if a:mode=="v"
				silent exe ":%!bash < ".tmpfile." -s ".l:arguments
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
			silent exe "!xterm -title ".l:fullname." ".s:BASH_XtermDefaults.' -e '.s:root_dir.'plugin/wrapper.sh '.l:fullname.l:arguments
		endif
		"
		if a:mode=="v"
			silent exe ":!chmod u+x ".tmpfile
			silent exe ":!echo 'read dummy' >> ".tmpfile
			silent exe ":!xterm -title ".l:fullname."\\ lines\\ ".pos1."-".pos2." ".s:BASH_XtermDefaults." -e ".tmpfile.l:arguments
		endif
		"
	endif
	"
endfunction    " ----------  end of function BASH_Run  ----------
"
"------------------------------------------------------------------------------
"  run : xterm geometry
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
"  set : option
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
	let zz=   "set -o ".a:arg."       # ".s:BASH_Set_Txt.s:BASH_SetCounter."\n"
	let zz=zz."set +o ".a:arg."       # ".s:BASH_Set_Txt.s:BASH_SetCounter
	let	s:BASH_SetCounter	= s:BASH_SetCounter+1
	if line(".")!=line("$")
		put! =zz
	else
		put =zz
	endif
	normal p
endfunction		" ---------- end of function  BASH_set  ----------
"
"
"------------------------------------------------------------------------------
"  shopt : option
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
	let zz=   "shopt -s ".a:arg."       # ".s:BASH_Shopt_Txt.s:BASH_SetCounter."\n"
	let zz=zz."shopt -u ".a:arg."       # ".s:BASH_Shopt_Txt.s:BASH_SetCounter
	let	s:BASH_SetCounter	= s:BASH_SetCounter+1
	if line(".")!=line("$")
		put! =zz
	else
		put =zz
	endif
	normal p
endfunction		" ---------- end of function  BASH_shopt  ----------
"
"------------------------------------------------------------------------------
"  run : Command line arguments
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
"  Bash-Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! BASH_CodeSnippets(arg1)
	if isdirectory(s:BASH_CodeSnippets)
		"
		" read snippet file, put content below current line
		"
		if a:arg1 == "r"
			let	l:snippetfile=browse(0,"read a code snippet",s:BASH_CodeSnippets,"")
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
			let	l:snippetfile=browse(0,"edit a code snippet",s:BASH_CodeSnippets,"")
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer into snippet file 
		" 
		if a:arg1 == "w"
			let	l:snippetfile=browse(0,"write a code snippet",s:BASH_CodeSnippets,"")
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:BASH_CodeSnippets,"")
			if l:snippetfile != ""
				if filereadable(l:snippetfile)
					if confirm("File exists ! Overwrite ? ", "&Cancel\n&No\n&Yes") != 3
						return
					endif
				endif
				:execute ":*write! ".l:snippetfile
			endif
		endif

	else
		echo "code snippet directory ".s:BASH_CodeSnippets." does not exist (please create it)"
	endif
endfunction		" ---------- end of function  BASH_CodeSnippets  ----------
"
"------------------------------------------------------------------------------
"  run : hardcopy
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
"  Run : settings
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
"  run : help bashsupport 
"------------------------------------------------------------------------------
function! BASH_HelpBASHsupport ()
	try
		:help bashsupport
	catch
		exe ':helptags '.s:plugin_dir.'doc'
		:help bashsupport
	endtry
endfunction    " ----------  end of function BASH_HelpBASHsupport ----------
"
"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
function! BASH_CreateUnLoadMenuEntries ()
	"
	" Bash is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:BASH_Active == 1
		:aunmenu &Tools.Load\ Bash\ Support
		exe 'amenu  <silent> 40.1021  &Tools.Unload\ Bash\ Support  	<C-C>:call BASH_Handle()<CR>'
	else
		" Bash is now inactive and was former active or in initial state -1 
		if s:BASH_Active == 0
			" Remove Tools.Unload if Bash was former inactive
			:aunmenu &Tools.Unload\ Bash\ Support
		else
			" Set initial state BASH_Active=-1 to inactive state BASH_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:BASH_Active = 0
			" Insert Tools.Load
		endif
		exe 'amenu <silent> 40.1000 &Tools.-SEP100- : '
		exe 'amenu <silent> 40.1021 &Tools.Load\ Bash\ Support <C-C>:call BASH_Handle()<CR>'
	endif
	"
endfunction		" ---------- end of function  BASH_CreateUnLoadMenuEntries  ----------
"
"------------------------------------------------------------------------------
"  Loads or unloads Bash extensions menus
"------------------------------------------------------------------------------
function! BASH_Handle ()
	if s:BASH_Active == 0
		:call BASH_InitMenu()
		let s:BASH_Active = 1
	else
		if has("gui_running")
			if s:BASH_Root == ""
				aunmenu Comments
				aunmenu Statements
				aunmenu Tests
				aunmenu ParmSub
				aunmenu SpecVars
				aunmenu Environ
				aunmenu Builtins
				aunmenu set
				aunmenu shopt
				aunmenu I/O-Redir
				aunmenu Run
			else
				exe "aunmenu ".s:BASH_Root
			endif
		endif

		let s:BASH_Active = 0
	endif

	call BASH_CreateUnLoadMenuEntries ()
endfunction		" ---------- end of function  BASH_Handle  ----------
"
"------------------------------------------------------------------------------
" 
call BASH_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
if s:BASH_LoadMenus == "yes"
	call BASH_Handle()											" load the menus
endif
"
"------------------------------------------------------------------------------
"  Automated header insertion
"------------------------------------------------------------------------------
"
if has("autocmd")
	" 
	" Bash-script : insert header, write file, make it executable
	" 
	autocmd BufNewFile  *.sh    call BASH_CommentTemplates('header') |
 									\						:w! |
 									\						call BASH_MakeScriptExecutable()
	"
endif " has("autocmd")
"
"------------------------------------------------------------------------------
"  Key mappings : show / hide the bash-support menus
"------------------------------------------------------------------------------
"
nmap    <silent>  <Leader>lbs             :call BASH_Handle()<CR>
nmap    <silent>  <Leader>ubs             :call BASH_Handle()<CR>
"
"------------------------------------------------------------------------------
"  Avoid a wrong syntax highlighting for $(..) and $((..))
"------------------------------------------------------------------------------
"
let is_bash	            = 1
"
"------------------------------------------------------------------------------
"  vim: set tabstop=2: set shiftwidth=2: 
