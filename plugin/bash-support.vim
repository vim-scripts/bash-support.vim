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
"         Author:  Dr.-Ing. Fritz Mehner 
"                  Fachhochschule Südwestfalen, 58644 Iserlohn, Germany
"  
"          Email:  mehner@fh-swf.de
"          
"        License:  This program is free software; you can redistribute it and/or modify
"                  it under the terms of the GNU General Public License as published by
"                  the Free Software Foundation; either version 2 of the License, or
"                  (at your option) any later version.
"
"                  This program is distributed in the hope that it will be useful,
"                  but WITHOUT ANY WARRANTY; without even the implied warranty of
"                  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"                  GNU General Public License for more details.
"
"         Credit:  Lennart Schultz, les@dmi.min.dk 
"                  The file shellmenu.vim in the macro directory of the 
"                  vim standard distribution was my starting point.
"  
let s:BASH_Version = "1.8"           " version number of this script; do not change
"     Revision:  08.07.2004
"      Created:  26.02.2001
"#########################################################################################
"
"  Global variables (with default values) which can be overridden.
"
"  Key word completion is enabled by the filetype plugin 'sh.vim'
"  g:BASH_Dictionary_File  must be global
"          
if !exists("g:BASH_Dictionary_File")
	let g:BASH_Dictionary_File       = $HOME.'/.vim/wordlists/bash.list'
endif
"
"  Modul global variables (with default values) which can be overridden.
"
let s:BASH_AuthorName            = ""
let s:BASH_AuthorRef             = ""
let s:BASH_Email                 = ""
let s:BASH_Company               = ""
let s:BASH_Project               = ""
let s:BASH_CopyrightHolder       = ""
"
let	s:BASH_Root 				         = 'B&ash.'					" the name of the root menu of this plugin
let s:BASH_LoadMenus             = "yes"
let s:BASH_CodeSnippets          = $HOME."/.vim/codesnippets-bash/"
let s:BASH_Doc_Directory         = $HOME.'/.vim/doc/'
let s:BASH_Template_Directory    = $HOME."/.vim/plugin/templates/"
let s:BASH_Template_File         = "bash-file-header"
let s:BASH_Template_Frame        = "bash-frame"
let s:BASH_Template_Function     = "bash-function-description"
let s:BASH_MenuHeader            = "yes"
"
"
"------------------------------------------------------------------------------
"  Some variables for internal use only
"------------------------------------------------------------------------------
let s:BASH_Errorformat    = '%f:\ line\ %l:\ %m'
let s:BASH_Active         = -1                    " state variable controlling the Bash-menus
let s:BASH_CmdLineArgs    = ""                    " command line arguments for Run-run; initially empty
"
"------------------------------------------------------------------------------
"  Look for global variables (if any), to override the defaults.
"------------------------------------------------------------------------------
function! BASH_CheckGlobal ( name )
	if exists('g:'.a:name)
		exe 'let s:'.a:name.'  = g:'.a:name
	endif
endfunction
"
call BASH_CheckGlobal("BASH_AuthorName        ")
call BASH_CheckGlobal("BASH_AuthorRef         ")
call BASH_CheckGlobal("BASH_CodeSnippets      ")
call BASH_CheckGlobal("BASH_Company           ")
call BASH_CheckGlobal("BASH_CopyrightHolder   ")
call BASH_CheckGlobal("BASH_Doc_Directory     ")
call BASH_CheckGlobal("BASH_Email             ")
call BASH_CheckGlobal("BASH_LoadMenus         ")
call BASH_CheckGlobal("BASH_MenuHeader        ")
call BASH_CheckGlobal("BASH_Project           ")
call BASH_CheckGlobal("BASH_Root              ")
call BASH_CheckGlobal("BASH_Template_Directory")
call BASH_CheckGlobal("BASH_Template_File     ")
call BASH_CheckGlobal("BASH_Template_Frame    ")
call BASH_CheckGlobal("BASH_Template_Function ")
"
"
"------------------------------------------------------------------------------
"  BASH Menu Initialization
"------------------------------------------------------------------------------
function!	Bash_InitMenu ()
	"
	if has("gui_running")
		"===============================================================================================
		"----- Menu : root menu  ---------------------------------------------------------------------
		"===============================================================================================
		if s:BASH_Root != ""
			if s:BASH_MenuHeader == "yes"
				exe "amenu   ".s:BASH_Root.'<Tab>Bash     <Esc>'
				exe "amenu   ".s:BASH_Root.'-Sep0-        :'
			endif
		endif
		"===============================================================================================
		"----- Menu : Comments   -----------------------------------------------------------------------
		"===============================================================================================
		if s:BASH_MenuHeader == "yes"
			exe "amenu   ".s:BASH_Root.'&Comments.Comments<Tab>Bash           <Esc>'
			exe "amenu   ".s:BASH_Root.'&Comments.-Sep0-              :'
		endif
		exe "amenu           ".s:BASH_Root.'&Comments.&Line\ End\ Comment      <Esc><Esc>A<Tab><Tab><Tab># '
		exe "vmenu <silent>  ".s:BASH_Root.'&Comments.&Line\ End\ Comment      <Esc><Esc>:call BASH_MultiLineEndComments()<CR>A'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.&Frame\ Comment          <Esc><Esc>:call BASH_CommentTemplates("frame")<CR>'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.F&unction\ Description   <Esc><Esc>:call BASH_CommentTemplates("function")<CR>'
		exe "amenu <silent>  ".s:BASH_Root.'&Comments.File\ &Header            <Esc><Esc>:call BASH_CommentTemplates("header")<CR>'
		exe "amenu ".s:BASH_Root.'&Comments.-Sep1-                    :'
		exe "vmenu ".s:BASH_Root."&Comments.&code->comment            <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>"
		exe "vmenu ".s:BASH_Root."&Comments.c&omment->code            <Esc><Esc>:'<,'>s/^\#//<CR><Esc>:nohlsearch<CR>"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP2-                    :'
		exe " menu ".s:BASH_Root.'&Comments.&Date                     i<C-R>=strftime("%x")<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.&Date                      <C-R>=strftime("%x")<CR>'
		exe " menu ".s:BASH_Root.'&Comments.Date\ &Time               i<C-R>=strftime("%x %X %Z")<CR>'
		exe "imenu ".s:BASH_Root.'&Comments.Date\ &Time                <C-R>=strftime("%x %X %Z")<CR>'
		"
		exe "amenu ".s:BASH_Root.'&Comments.-SEP3-                    :'
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
		"===============================================================================================
		"----- Menu : Statements   ---------------------------------------------------------------------
		"===============================================================================================
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'St&atements.Statements<Tab>Bash          <Esc>'
			exe "amenu ".s:BASH_Root.'St&atements.-Sep0-             :'
		endif
		exe " menu ".s:BASH_Root.'St&atements.${\.\.\.}							<Esc>a${}<Esc>i'
		exe " menu ".s:BASH_Root.'St&atements.$(\.\.\.)							<Esc>a$()<Esc>i'
		exe " menu ".s:BASH_Root.'St&atements.$((\.\.\.))						<Esc>a$(())<Esc>hi'
		exe "vmenu ".s:BASH_Root.'St&atements.${\.\.\.}							s${}<Esc>Pla'
		exe "vmenu ".s:BASH_Root.'St&atements.$(\.\.\.)							s$()<Esc>Pla'
		exe "vmenu ".s:BASH_Root.'St&atements.$((\.\.\.))						s$(())<Esc>hP2la'
		exe "imenu ".s:BASH_Root.'St&atements.${\.\.\.}							${}<Esc>i'
		exe "imenu ".s:BASH_Root.'St&atements.$(\.\.\.)							$()<Esc>i'
		exe "imenu ".s:BASH_Root.'St&atements.$((\.\.\.))						$(())<Esc>hi'
		"
		exe "amenu ".s:BASH_Root.'St&atements.-SEP1-                :'
		exe "amenu ".s:BASH_Root.'St&atements.&case									<Esc><Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a'
		exe "amenu ".s:BASH_Root.'St&atements.e&lif									<Esc><Esc>oelif <CR>then<Esc>1kA'
		exe "amenu ".s:BASH_Root.'St&atements.&for									<Esc><Esc>ofor  in <CR>do<CR>done<Esc>2k^f<Space>a'
		exe "amenu ".s:BASH_Root.'St&atements.&if										<Esc><Esc>oif <CR>then<CR>fi<Esc>2k^A'
		exe "amenu ".s:BASH_Root.'St&atements.if-&else							<Esc><Esc>oif <CR>then<CR>else<CR>fi<Esc>3kA'
		exe "amenu ".s:BASH_Root.'St&atements.&select								<Esc><Esc>oselect  in <CR>do<CR>done<Esc>2kf<Space>a'
		exe "amenu ".s:BASH_Root.'St&atements.un&til								<Esc><Esc>ountil <CR>do<CR>done<Esc>2kA'
		exe "amenu ".s:BASH_Root.'St&atements.&while								<Esc><Esc>owhile <CR>do<CR>done<Esc>2kA'

		exe "vmenu ".s:BASH_Root."St&atements.&for								  DOfor  in <CR>do<CR>done<Esc>P2k^<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f<Space>a"
		exe "vmenu ".s:BASH_Root."St&atements.&if										DOif <CR>then<CR>fi<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>A"
		exe "vmenu ".s:BASH_Root."St&atements.if-&else							DOif <CR>then<CR>else<CR>fi<Esc>kP<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>2kA"
		exe "vmenu ".s:BASH_Root."St&atements.&select								DOselect  in <CR>do<CR>done<Esc>P2k^<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>f<Space>a"
		exe "vmenu ".s:BASH_Root."St&atements.un&til								DOuntil <CR>do<CR>done<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>A"
		exe "vmenu ".s:BASH_Root."St&atements.&while								DOwhile <CR>do<CR>done<Esc>P2k<Esc>:exe \"normal =\".(line(\"'>\")-line(\".\")-1).\"+\"<CR>A"

		exe "amenu ".s:BASH_Root.'St&atements.&break								<Esc><Esc>obreak '
		exe "amenu ".s:BASH_Root.'St&atements.co&ntinue							<Esc><Esc>ocontinue '
		exe "amenu ".s:BASH_Root.'St&atements.f&unction							<Esc><Esc>o<Esc>:call BASH_CodeFunction()<CR>2jA'
		exe "amenu ".s:BASH_Root.'St&atements.&return								<Esc><Esc>oreturn '
		exe "amenu ".s:BASH_Root.'St&atements.return\ &0\ (true)		<Esc><Esc>oreturn 0'
		exe "amenu ".s:BASH_Root.'St&atements.return\ &1\ (false)		<Esc><Esc>oreturn 1'
		exe "amenu ".s:BASH_Root.'St&atements.e&xit									<Esc><Esc>oexit '
		exe "amenu ".s:BASH_Root.'St&atements.s&hift								<Esc><Esc>oshift '
		exe "amenu ".s:BASH_Root.'St&atements.tra&p									<Esc><Esc>otrap '
		"
		exe "amenu ".s:BASH_Root.'St&atements.-SEP2-                :'
		"
		exe "vmenu ".s:BASH_Root."St&atements.'\\.\\.\\.'						s''<Esc>Pla"
		exe "vmenu ".s:BASH_Root.'St&atements."\.\.\."							s""<Esc>Pla'
		exe "vmenu ".s:BASH_Root.'St&atements.`\.\.\.`							s``<Esc>Pla'
		"
		exe "amenu ".s:BASH_Root.'St&atements.ech&o\ "xxx"	  			<Esc><Esc>^iecho<Space>"<Esc>$a"<Esc>j'
		exe "imenu ".s:BASH_Root.'St&atements.ech&o\ "xxx"	  			echo<Space>""<Esc>i'
		exe "vmenu ".s:BASH_Root.'St&atements.ech&o\ "xxx"    			secho<Space>""<Esc>P'
		"
		exe "amenu <silent> ".s:BASH_Root.'St&atements.remo&ve\ echo  	<Esc><Esc>0:s/echo\s\+\"// \| s/\s*\"\s*$//<CR><Esc>j'
		"
		if s:BASH_CodeSnippets != ""
			exe "amenu  ".s:BASH_Root.'St&atements.-SEP4-                    		  :'
			exe "amenu  <silent> ".s:BASH_Root.'St&atements.read\ code\ snippet   <C-C>:call BASH_CodeSnippets("r")<CR>'
			exe "amenu  <silent> ".s:BASH_Root.'St&atements.write\ code\ snippet  <C-C>:call BASH_CodeSnippets("w")<CR>'
			exe "vmenu  <silent> ".s:BASH_Root.'St&atements.write\ code\ snippet  <C-C>:call BASH_CodeSnippets("wv")<CR>'
			exe "amenu  <silent> ".s:BASH_Root.'St&atements.edit\ code\ snippet   <C-C>:call BASH_CodeSnippets("e")<CR>'
		endif
		"
		"-------------------------------------------------------------------------------
		" file tests
		"-------------------------------------------------------------------------------
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.Tests-0<Tab>Bash          <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.-Sep0-             :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e															    					<Esc>a[ -e  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		<Esc>a[ -s  ]<Esc>hi'
		" 
		exe "imenu ".s:BASH_Root.'&Tests.file\ &exists<Tab>-e																						[ -e  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ a\ &size\ greater\ than\ zero<Tab>-s		[ -s  ]<Esc>hi'
		" 
		exe "imenu ".s:BASH_Root.'&Tests.-Sep1-                         :'
		"
		"---------- submenu arithmetic tests -----------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.Tests-1<Tab>Bash       <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.-Sep0-          :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq										<Esc>a[  -eq  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne										<Esc>a[  -ne  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt												<Esc>a[  -lt  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le				<Esc>a[  -le  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt										<Esc>a[  -gt  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge			<Esc>a[  -ge  ]<Esc>F[la'
		"
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2<Tab>-eq										[  -eq  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2<Tab>-ne										[  -ne  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2<Tab>-lt												[  -lt  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2<Tab>-le				[  -le  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2<Tab>-gt										[  -gt  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2<Tab>-ge			[  -ge  ]<Esc>F[la'
		"
		"---------- submenu file exists and has permission ---------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.Tests-2<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and									<Esc>'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r									<Esc>a[ -r  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w									<Esc>a[ -w  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x								<Esc>a[ -x  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u				<Esc>a[ -u  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g				<Esc>a[ -g  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k		<Esc>a[ -k  ]<Esc>hi'
		"
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and									<Esc>'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &readable<Tab>-r									[ -r  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ &writable<Tab>-w									[ -w  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ is\ e&xecutable<Tab>-x								[ -x  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&UID-bit\ is\ set<Tab>-u				[ -u  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ S&GID-bit\ is\ set<Tab>-g				[ -g  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ &permission.\ its\ "stic&ky"\ bit\ is\ set<Tab>-k		[ -k  ]<Esc>hi'
		"
		"---------- submenu file exists and has type ----------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.Tests-3<Tab>Bash                                    <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.-Sep0-                         :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a			<Esc>'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			<Esc>a[ -b  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	<Esc>a[ -c  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d									<Esc>a[ -d  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>-p				<Esc>a[ -p  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f							<Esc>a[ -f  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										<Esc>a[ -S  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						<Esc>a[ -L  ]<Esc>hi'
		"
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.file\ exists\ and\ is\ a			<Esc>'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &block\ special\ file<Tab>-b			[ -b  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &character\ special\ file<Tab>-c	[ -c  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &directory<Tab>-d									[ -d  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ named\ &pipe\ (FIFO)<Tab>p-				[ -p  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ regular\ &file<Tab>-f							[ -f  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ &socket<Tab>-S										[ -S  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ has\ t&ype.\ symbolic\ &link<Tab>-L						[ -L  ]<Esc>hi'
		"
		"---------- submenu string comparison ------------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.Tests-4<Tab>Bash                                    <Esc>'
			exe "amenu ".s:BASH_Root.'&Tests.string\ &comparison.-Sep0-                         :'
		endif
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z											<Esc>a[ -z  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n									<Esc>a[ -n  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal<Tab>==															<Esc>a[  ==  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=													<Esc>a[  !=  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><		<Esc>a[  <  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>			<Esc>a[  >  ]<Esc>F[la'
		"                                         
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &zero<Tab>-z											[ -z  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.length\ of\ string\ is\ &non-zero<Tab>-n									[ -n  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ &equal<Tab>==															[  ==  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.strings\ are\ n&ot\ equal<Tab>!=													[  !=  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &before\ string2\ lexicograph\.<Tab><		[  <  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.string\ &comparison.string1\ sorts\ &after\ string2\ lexicograph\.<Tab>>			[  >  ]<Esc>F[la'
		"
		exe "	menu ".s:BASH_Root.'&Tests.-Sep2-                         :'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O								<Esc>a[ -O  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G								<Esc>a[ -G  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N		<Esc>a[ -N  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t					<Esc>a[ -t  ]<Esc>hi'
		exe "	menu ".s:BASH_Root.'&Tests.-Sep3-                         :'
		exe "	menu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt									<Esc>a[  -nt  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																				<Esc>a[  -ot  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef			<Esc>a[  -ef  ]<Esc>F[la'
		exe "	menu ".s:BASH_Root.'&Tests.-Sep4-                         :'
		exe "	menu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																	<Esc>a[ -o  ]<Esc>hi'
		"
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ &owned\ by\ the\ effective\ UID<Tab>-O                [ -O  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID<Tab>-G								[ -G  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ exists\ a&nd\ has\ been\ modified\ since\ it\ was\ last\ read<Tab>-N		[ -N  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.file\ descriptor\ fd\ is\ open\ and\ refers\ to\ a\ &terminal<Tab>-t					[ -t  ]<Esc>hi'
		exe "imenu ".s:BASH_Root.'&Tests.-Sep3-                         :'
		exe "imenu ".s:BASH_Root.'&Tests.file&1\ is\ newer\ than\ file2\ (modification\ date)<Tab>-nt									[  -nt  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.file1\ is\ older\ than\ file&2<Tab>-ot																				[  -ot  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers<Tab>-ef			[  -ef  ]<Esc>F[la'
		exe "imenu ".s:BASH_Root.'&Tests.-Sep4-                         :'
		exe "imenu ".s:BASH_Root.'&Tests.&shell\ option\ optname\ is\ enabled<Tab>-o																	[ -o  ]<Esc>hi'
		"
		"-------------------------------------------------------------------------------
		" parameter substitution
		"-------------------------------------------------------------------------------
		" 
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&ParmSub.ParmSub<Tab>Bash        <Esc>'
			exe "amenu ".s:BASH_Root.'&ParmSub.-Sep0-           :'
		endif

		exe "	menu ".s:BASH_Root.'&ParmSub.Use\ Default\ Value<Tab>${:-} 															  	<Esc>a${:-}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.Assign\ Default\ Value<Tab>${:=}  														 	<Esc>a${:=}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.Display\ Error\ if\ Null\ or\ Unset<Tab>${:?} 							  	<Esc>a${:?}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.Use\ Alternate\ Value<Tab>${:+}  														 	<Esc>a${:+}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.parameter\ length\ in\ characters<Tab>${#}  								  	<Esc>a${#}<ESC>F#a'
		exe "	menu ".s:BASH_Root.'&ParmSub.match\ the\ beginning;\ delete\ shortest\ part<Tab>${#}  		  <Esc>a${#}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.match\ the\ beginning;\ delete\ longest\ part<Tab>${##} 		  	<Esc>a${##}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.match\ the\ end;\ delete\ shortest\ part<Tab>${%} 	      	   	<Esc>a${%}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.match\ the\ end;\ delete\ longest\ part<Tab>${%%} 	      	  	<Esc>a${%%}<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.replace\ first\ match<Tab>${/\ /\ }											 				<Esc>a${/ / }<ESC>F{a'
		exe "	menu ".s:BASH_Root.'&ParmSub.replace\ all\ matches<Tab>${//\ /\ }											    		<Esc>a${// / }<ESC>F{a'
		"
		exe "imenu ".s:BASH_Root.'&ParmSub.Use\ Default\ Value<Tab>${:-}  														 	${:-}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.Assign\ Default\ Value<Tab>${:=}  													 	${:=}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.Display\ Error\ if\ Null\ or\ Unset<Tab>${:?} 						  	${:?}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.Use\ Alternate\ Value<Tab>${:+} 													  	${:+}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.parameter\ length\ in\ characters<Tab>${#}   							 	${#}<ESC>F#a'
		exe "imenu ".s:BASH_Root.'&ParmSub.match\ the\ beginning;\ delete\ shortest\ part<Tab>${#}    	${#}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.match\ the\ beginning;\ delete\ longest\ part<Tab>${##} 	  	${##}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.match\ the\ end;\ delete\ shortest\ part<Tab>${%} 	         	${%}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.match\ the\ end;\ delete\ longest\ part<Tab>${%%} 	        	${%%}<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.replace\ first\ match<Tab>${/\ /\ } 										 				${/ / }<ESC>F{a'
		exe "imenu ".s:BASH_Root.'&ParmSub.replace\ all\ matches<Tab>${//\ /\ }											    	${// / }<ESC>F{a'
		"
		"-------------------------------------------------------------------------------
		" special variables
		"-------------------------------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'Spec&Vars.SpecVars<Tab>Bash       <Esc>'
			exe "amenu ".s:BASH_Root.'Spec&Vars.-Sep0-          :'
		endif

		exe "	menu ".s:BASH_Root.'Spec&Vars.Number\ of\ positional\ parameters<Tab>${#}								<Esc>a${#}'
		exe "	menu ".s:BASH_Root.'Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)<Tab>${*}		<Esc>a${*}'
		exe "	menu ".s:BASH_Root.'Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)<Tab>${@}	<Esc>a${@}'
		exe "	menu ".s:BASH_Root.'Spec&Vars.Flags\ set<Tab>${-}																				<Esc>a${-}'
		exe "	menu ".s:BASH_Root.'Spec&Vars.Return\ code\ of\ last\ command<Tab>${?}									<Esc>a${?}'
		exe "	menu ".s:BASH_Root.'Spec&Vars.Process\ number\ of\ this\ shell<Tab>${$}									<Esc>a${$}'
		exe "	menu ".s:BASH_Root.'Spec&Vars.Process\ number\ of\ last\ background\ command<Tab>${!}		<Esc>a${!}'
		"
		exe "imenu ".s:BASH_Root.'Spec&Vars.Number\ of\ positional\ parameters<Tab>${#}								${#}'
		exe "imenu ".s:BASH_Root.'Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)<Tab>${*}		${*}'
		exe "imenu ".s:BASH_Root.'Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)<Tab>${@}	${@}'
		exe "imenu ".s:BASH_Root.'Spec&Vars.Flags\ set<Tab>${-}																				${-}'
		exe "imenu ".s:BASH_Root.'Spec&Vars.Return\ code\ of\ last\ command<Tab>${?}									${?}'
		exe "imenu ".s:BASH_Root.'Spec&Vars.Process\ number\ of\ this\ shell<Tab>${$}									${$}'
		exe "imenu ".s:BASH_Root.'Spec&Vars.Process\ number\ of\ last\ background\ command<Tab>${!}		${!}'
		"
		"-------------------------------------------------------------------------------
		" Shell Variables
		"-------------------------------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.Environ<Tab>Bash     <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.-Sep0-        :'
		endif
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.Environ-1<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&BASH            <Esc>a${BASH}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.B&ASH_ENV        <Esc>a${BASH_ENV}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.BA&SH_VERSINFO   <Esc>a${BASH_VERSINFO}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.BAS&H_VERSION    <Esc>a${BASH_VERSION}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&CDPATH          <Esc>a${CDPATH}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.C&OLUMNS         <Esc>a${COLUMNS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.CO&MPREPLY       <Esc>a${COMPREPLY}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COM&P_CWORD      <Esc>a${COMP_CWORD}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&LINE       <Esc>a${COMP_LINE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_POI&NT      <Esc>a${COMP_POINT}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&WORDS      <Esc>a${COMP_WORDS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&DIRSTACK        <Esc>a${DIRSTACK}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&EUID            <Esc>a${EUID}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&FCEDIT          <Esc>a${FCEDIT}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&IGNORE         <Esc>a${FIGNORE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&UNCNAME        <Esc>a${FUNCNAME}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.Environ-2<Tab>Bash                                    <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.-Sep0-                         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE    <Esc>a${GLOBIGNORE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS        <Esc>a${GROUPS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD       <Esc>a${HISTCMD}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL   <Esc>a${HISTCONTROL}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE      <Esc>a${HISTFILE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE  <Esc>a${HISTFILESIZE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE    <Esc>a${HISTIGNORE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE      <Esc>a${HISTSIZE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME          <Esc>a${HOME}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E      <Esc>a${HOSTFILE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME      <Esc>a${HOSTNAME}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE      <Esc>a${HOSTTYPE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS           <Esc>a${IFS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF     <Esc>a${IGNOREEOF}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C       <Esc>a${INPUTRC}'
		exe "	menu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG          <Esc>a${LANG}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.Environ-3<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          <Esc>a${LC_ALL}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      <Esc>a${LC_COLLATE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        <Esc>a${LC_CTYPE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     <Esc>a${LC_MESSAGES}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      <Esc>a${LC_NUMERIC}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          <Esc>a${LINENO}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           <Esc>a${LINES}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        <Esc>a${MACHTYPE}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            <Esc>a${MAIL}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       <Esc>a${MAILCHECK}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        <Esc>a${MAILPATH}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          <Esc>a${OLDPWD}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          <Esc>a${OPTARG}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          <Esc>a${OPTERR}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          <Esc>a${OPTIND}'
		exe "	menu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          <Esc>a${OSTYPE}'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.Environ-4<Tab>Bash           <Esc>'
			exe "amenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.-Sep0-              :'
		endif
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&PATH                 <Esc>a${PATH}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           <Esc>a${PIPESTATUS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      <Esc>a${POSIXLY_CORRECT}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 <Esc>a${PPID}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       <Esc>a${PROMPT_COMMAND}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&1                  <Esc>a${PS1}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&2                  <Esc>a${PS2}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&3                  <Esc>a${PS3}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&4                  <Esc>a${PS4}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&WD                  <Esc>a${PWD}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               <Esc>a${RANDOM}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                <Esc>a${REPLY}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              <Esc>a${SECONDS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.S&HELLOPTS            <Esc>a${SHELLOPTS}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                <Esc>a${SHLVL}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           <Esc>a${TIMEFORMAT}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                <Esc>a${TMOUT}'
		exe "	menu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&UID                  <Esc>a${UID}'

		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&BASH            ${BASH}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.B&ASH_ENV        ${BASH_ENV}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.BA&SH_VERSINFO   ${BASH_VERSINFO}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.BAS&H_VERSION    ${BASH_VERSION}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&CDPATH          ${CDPATH}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.C&OLUMNS         ${COLUMNS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.CO&MPREPLY       ${COMPREPLY}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COM&P_CWORD      ${COMP_CWORD}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&LINE       ${COMP_LINE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_POI&NT      ${COMP_POINT}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&WORDS      ${COMP_WORDS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&DIRSTACK        ${DIRSTACK}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&EUID            ${EUID}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.&FCEDIT          ${FCEDIT}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&IGNORE         ${FIGNORE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&UNCNAME        ${FUNCNAME}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE    ${GLOBIGNORE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS        ${GROUPS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD       ${HISTCMD}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL   ${HISTCONTROL}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE      ${HISTFILE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE  ${HISTFILESIZE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE    ${HISTIGNORE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE      ${HISTSIZE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME          ${HOME}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E      ${HOSTFILE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME      ${HOSTNAME}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE      ${HOSTTYPE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS           ${IFS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF     ${IGNOREEOF}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C       ${INPUTRC}'
		exe "imenu ".s:BASH_Root.'E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG          ${LANG}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          ${LC_ALL}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      ${LC_COLLATE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        ${LC_CTYPE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     ${LC_MESSAGES}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      ${LC_NUMERIC}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          ${LINENO}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           ${LINES}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        ${MACHTYPE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            ${MAIL}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       ${MAILCHECK}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        ${MAILPATH}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          ${OLDPWD}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          ${OPTARG}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          ${OPTERR}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          ${OPTIND}'
		exe "imenu ".s:BASH_Root.'E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          ${OSTYPE}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&PATH                 ${PATH}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           ${PIPESTATUS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      ${POSIXLY_CORRECT}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 ${PPID}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       ${PROMPT_COMMAND}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&1                  ${PS1}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&2                  ${PS2}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&3                  ${PS3}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.PS&4                  ${PS4}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.P&WD                  ${PWD}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               ${RANDOM}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                ${REPLY}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              ${SECONDS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.S&HELLOPTS            ${SHELLOPTS}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                ${SHLVL}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           ${TIMEFORMAT}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                ${TMOUT}'
		exe "imenu ".s:BASH_Root.'E&nviron.&PATH\ \.\.\.\ UID.&UID                  ${UID}'
		"
		"-------------------------------------------------------------------------------
		" Builtins
		"-------------------------------------------------------------------------------
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'B&uiltins.Builtins<Tab>Bash      <Esc>'
			exe "amenu ".s:BASH_Root.'B&uiltins.-Sep0-         :'
		endif
		exe "	menu ".s:BASH_Root.'B&uiltins.&cd         <Esc>acd<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.&echo       <Esc>aecho<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.e&val       <Esc>aeval<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.e&xec       <Esc>aexec<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.ex&port     <Esc>aexport<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.&getopts    <Esc>agetopts<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.&hash       <Esc>ahash<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.&newgrp     <Esc>anewgrp<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.p&wd        <Esc>apwd<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.&read       <Esc>aread<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.read&only   <Esc>areadonly<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.ret&urn     <Esc>areturn<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.&times      <Esc>atimes<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.t&ype       <Esc>atype<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.u&mask      <Esc>aumask<Space>'
		exe "	menu ".s:BASH_Root.'B&uiltins.w&ait       <Esc>await<Space>'
		"
		exe "imenu ".s:BASH_Root.'B&uiltins.&cd         cd<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.&echo       echo<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.e&val       eval<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.e&xec       exec<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.ex&port     export<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.&getopts    getopts<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.&hash       hash<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.&newgrp     newgrp<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.p&wd        pwd<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.&read       read<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.read&only   readonly<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.ret&urn     return<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.&times      times<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.t&ype       type<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.u&mask      umask<Space>'
		exe "imenu ".s:BASH_Root.'B&uiltins.w&ait       wait<Space>'
		"
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'S&et.Set<Tab>Bash   <Esc>'
			exe "amenu ".s:BASH_Root.'S&et.-Sep0-       	:'
		endif
		exe "	menu ".s:BASH_Root.'S&et.set									<Esc>aset<Space>'
		exe "	menu ".s:BASH_Root.'S&et.unset 								<Esc>aunset<Space>'
		exe "	menu ".s:BASH_Root.'S&et.allexport<Tab>-a 		<Esc>aset -o allexport' 
		exe "	menu ".s:BASH_Root.'S&et.braceexpand<Tab>-B 	<Esc>aset -o braceexpand' 
		exe "	menu ".s:BASH_Root.'S&et.emacs          			<Esc>aset -o emacs' 
		exe "	menu ".s:BASH_Root.'S&et.errexit<Tab>-e   		<Esc>aset -o errexit'   
		exe "	menu ".s:BASH_Root.'S&et.hashall<Tab>-h   		<Esc>aset -o hashall'   
		exe "	menu ".s:BASH_Root.'S&et.histexpand<Tab>-H 		<Esc>aset -o histexpand'   
		exe "	menu ".s:BASH_Root.'S&et.history        	 		<Esc>aset -o history'   
		exe "	menu ".s:BASH_Root.'S&et.ignoreeof       			<Esc>aset -o ignoreeof'   
		exe "	menu ".s:BASH_Root.'S&et.keyword<Tab>-k   		<Esc>aset -o keyword'   
		exe "	menu ".s:BASH_Root.'S&et.monitor<Tab>-m   		<Esc>aset -o monitor'   
		exe "	menu ".s:BASH_Root.'S&et.noclobber<Tab>-C			<Esc>aset -o noclobber'   
		exe "	menu ".s:BASH_Root.'S&et.noexec<Tab>-n    		<Esc>aset -o noexec'    
		exe "	menu ".s:BASH_Root.'S&et.noglob<Tab>-f    		<Esc>aset -o noglob'    
		exe "	menu ".s:BASH_Root.'S&et.notify<Tab>-b    		<Esc>aset -o notify'    
		exe "	menu ".s:BASH_Root.'S&et.nounset<Tab>-u   		<Esc>aset -o nounset'   
		exe "	menu ".s:BASH_Root.'S&et.onecmd<Tab>-t    		<Esc>aset -o onecmd'    
		exe "	menu ".s:BASH_Root.'S&et.physical<Tab>-P   		<Esc>aset -o physical'    
		exe "	menu ".s:BASH_Root.'S&et.posix          			<Esc>aset -o posix'    
		exe "	menu ".s:BASH_Root.'S&et.privileged<Tab>-p		<Esc>aset -o privileged'
		exe "	menu ".s:BASH_Root.'S&et.verbose<Tab>-v   		<Esc>aset -o verbose'   
		exe "	menu ".s:BASH_Root.'S&et.vi           	   		<Esc>aset -o vi'   
		exe "	menu ".s:BASH_Root.'S&et.xtrace<Tab>-x    		<Esc>aset -o xtrace'    
		"
		exe "imenu ".s:BASH_Root.'S&et.set									set<Space>-'
		exe "imenu ".s:BASH_Root.'S&et.unset 								unset<Space>-'
		exe "imenu ".s:BASH_Root.'S&et.allexport<Tab>-a 		set -o allexport' 
		exe "imenu ".s:BASH_Root.'S&et.braceexpand<Tab>-B 	set -o braceexpand' 
		exe "imenu ".s:BASH_Root.'S&et.emacs          			set -o emacs' 
		exe "imenu ".s:BASH_Root.'S&et.errexit<Tab>-e   		set -o errexit'   
		exe "imenu ".s:BASH_Root.'S&et.hashall<Tab>-h   		set -o hashall'   
		exe "imenu ".s:BASH_Root.'S&et.histexpand<Tab>-H 		set -o histexpand'   
		exe "imenu ".s:BASH_Root.'S&et.history        	 		set -o history'   
		exe "imenu ".s:BASH_Root.'S&et.ignoreeof       			set -o ignoreeof'   
		exe "imenu ".s:BASH_Root.'S&et.keyword<Tab>-k   		set -o keyword'   
		exe "imenu ".s:BASH_Root.'S&et.monitor<Tab>-m   		set -o monitor'   
		exe "imenu ".s:BASH_Root.'S&et.noclobber<Tab>-C			set -o noclobber'   
		exe "imenu ".s:BASH_Root.'S&et.noexec<Tab>-n    		set -o noexec'    
		exe "imenu ".s:BASH_Root.'S&et.noglob<Tab>-f    		set -o noglob'    
		exe "imenu ".s:BASH_Root.'S&et.notify<Tab>-b    		set -o notify'    
		exe "imenu ".s:BASH_Root.'S&et.nounset<Tab>-u   		set -o nounset'   
		exe "imenu ".s:BASH_Root.'S&et.onecmd<Tab>-t    		set -o onecmd'    
		exe "imenu ".s:BASH_Root.'S&et.physical<Tab>-P   		set -o physical'    
		exe "imenu ".s:BASH_Root.'S&et.posix          			set -o posix'    
		exe "imenu ".s:BASH_Root.'S&et.privileged<Tab>-p		set -o privileged'
		exe "imenu ".s:BASH_Root.'S&et.verbose<Tab>-v   		set -o verbose'   
		exe "imenu ".s:BASH_Root.'S&et.vi           	   		set -o vi'   
		exe "imenu ".s:BASH_Root.'S&et.xtrace<Tab>-x    		set -o xtrace'    
		"-------------------------------------------------------------------------------
		" I/O redirection
		"-------------------------------------------------------------------------------
		" 
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&I/O-Redir.I/O-Redir<Tab>Bash   <Esc>'
			exe "amenu ".s:BASH_Root.'&I/O-Redir.-Sep0-    				    :'
		endif

		exe "	menu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file												<Esc>a<Space><<Space><ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file												<Esc>a<Space>><Space><ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append							<Esc>a<Space>>><Space><ESC>a'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descriptor\ to\ file							<Esc>a<Space>><Space><ESC>2hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descriptor\ to\ file;\ append		<Esc>a<Space>>><Space><ESC>2hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.take\ file\ descriptor\ from\ file							<Esc>a<Space><<Space><ESC>2hi'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descriptor				<Esc>a<Space><& <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descriptor				<Esc>a<Space>>& <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file					<Esc>a<Space>&> <ESC>a'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ the\ STDIN															<Esc>a<Space><&- <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ the\ STDOUT															<Esc>a<Space>>&- <ESC>a'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n		<Esc>a<Space><&- <ESC>3hi'
		exe "	menu ".s:BASH_Root.'&I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n	<Esc>a<Space>>&- <ESC>3hi'
		"
		exe "	menu ".s:BASH_Root.'&I/O-Redir.here-document			<Esc>a<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.take\ STDIN\ from\ file												<Space><<Space><ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file												<Space>><Space><ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ to\ file;\ append							<Space>>><Space><ESC>a'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descriptor\ to\ file							<Space>><Space><ESC>2hi'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ file\ descriptor\ to\ file;\ append		<Space>>><Space><ESC>2hi'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.take\ file\ descriptor\ from\ file							<Space><<Space><ESC>2hi'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDIN\ from\ file\ descriptor				<Space><& <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.duplicate\ STDOUT\ to\ file\ descriptor				<Space>>& <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.direct\ STDOUT\ and\ STDERR\ to\ file					<Space>&> <ESC>a'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ the\ STDIN															<Space><&- <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ the\ STDOUT															<Space>>&- <ESC>a'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n		<Space><&- <ESC>3hi'
		exe "imenu ".s:BASH_Root.'&I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n	<Space>>&- <ESC>3hi'
		"
		exe "imenu ".s:BASH_Root.'&I/O-Redir.here-document			<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki'
		"
		"------------------------------------------------------------------------------
		"  Run Script
		"------------------------------------------------------------------------------
		"   run the script from the local directory 
		"   ( the one in the current buffer ; other versions may exist elsewhere ! )
		" 
		if s:BASH_MenuHeader == "yes"
			exe "amenu ".s:BASH_Root.'&Run.Run<Tab>Bash  <Esc>'
			exe "amenu ".s:BASH_Root.'&Run.-Sep0-        :'
		endif

		exe "amenu ".s:BASH_Root.'&Run.save\ +\ &run\ script<Tab><Ctrl><F9>    <C-C>:call BASH_Run("r")<CR>'
		exe "amenu ".s:BASH_Root.'&Run.save\ +\ &check\ syntax<Tab><Alt><F9>   <C-C>:call BASH_Run("c")<CR>'
		"
		"   set execution right only for the user ( may be user root ! )
		"
		exe "amenu <silent> ".s:BASH_Root.'&Run.make\ script\ e&xecutable              <C-C>:!chmod -c u+x %<CR>'
		exe "amenu <silent> ".s:BASH_Root.'&Run.command\ line\ &arguments              <C-C>:call BASH_Arguments()<CR>'
		exe "amenu          ".s:BASH_Root.'&Run.-Sep1-                                 :'
		exe "amenu <silent> ".s:BASH_Root.'&Run.&hardcopy\ all\ to\ FILENAME\.ps       <C-C>:call BASH_Hardcopy("n")<CR>'
		exe "vmenu <silent> ".s:BASH_Root.'&Run.hard&copy\ part\ to\ FILENAME\.ps      <C-C>:call BASH_Hardcopy("v")<CR>'
		exe "imenu          ".s:BASH_Root.'&Run.-SEP2-                                 :'
		exe "amenu <silent> ".s:BASH_Root.'&Run.&settings                              <C-C>:call BASH_Settings()<CR>'
		"
	endif

endfunction			" function Bash_InitMenu
"
"------------------------------------------------------------------------------
"  Input after a highlighted prompt
"------------------------------------------------------------------------------
function! BASH_Input ( promp, text )
	echohl Search												" highlight prompt
	call inputsave()										" preserve typeahead
	let	retval=input( a:promp, a:text )	" read input
	call inputrestore()									" restore typeahead
	echohl None													" reset highlighting
	return retval
endfunction
"
"------------------------------------------------------------------------------
"  Comments : multi line-end comments
"------------------------------------------------------------------------------
function! BASH_MultiLineEndComments ()
	" ----- trim whitespaces -----
	exe "'<,'>s/\s\*$//"
	" ----- find the longest line -----
	let	maxlength		= 0
	let	linenumber	= line("'<")
	normal '<
	while linenumber <= line("'>")
		if maxlength<virtcol("$")
			let maxlength= virtcol("$")
		endif
		let linenumber=linenumber+1
		normal j
	endwhile
	let	maxlength	= maxlength-1
	let	maxlength	= ((maxlength + &tabstop)/&tabstop)*&tabstop
	" ----- fill lines with tabs -----
	let	linenumber	= line("'<")
	normal '<
	while linenumber <= line("'>")
		let ll		= virtcol("$")-1
		let diff	= (maxlength-ll)/&tabstop
		if ll%(&tabstop)!=0
			let diff	= diff+1
		endif
		while diff>0
			exe "normal	$A	"
			let diff=diff-1
		endwhile
		exe "normal	$a# "
		let linenumber=linenumber+1
		normal j
	endwhile
	" ----- back to the beginning of the marked block -----
	normal '<
endfunction
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
		if  a:arg=='header' 
			:goto 1
			let	pos1  = 1
			exe '0read '.templatefile
		else
			exe 'read '.templatefile
		endif
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
endfunction
"
"------------------------------------------------------------------------------
"  run : run
"------------------------------------------------------------------------------
function! BASH_Run (arg1)
	exe	":cclose"								
	let	l:currentbuffer=bufname("%")
	exe	"update"
	exe	"set makeprg=$SHELL"
	exe	':setlocal errorformat='.s:BASH_Errorformat
	" 
	" ----- save script and run ------------------ 
	if a:arg1 == "r"
		exe "make     ./% ".s:BASH_CmdLineArgs
	endif
	"
	" ----- save script and check syntax --------- 
	if a:arg1 == "c"
		silent exe "make  -n ./% ".s:BASH_CmdLineArgs
	endif
	"
	" open the quickfix window (if any) 
	" reset error format / reset to standard make
	exe	":botright cwindow"

	if l:currentbuffer ==  bufname("%") && a:arg1 == "c"
		redraw
		echohl Search
		echo l:currentbuffer." : Syntax is OK"
		echohl None
		nohlsearch						" delete unwanted highlighting (Vim bug?)
	endif

	exe	":setlocal errorformat="	
	exe	"set makeprg=make"				
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments
"------------------------------------------------------------------------------
function! BASH_Arguments ()
	let	s:BASH_CmdLineArgs= BASH_Input("command line arguments : ",s:BASH_CmdLineArgs)
endfunction
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
				let	length= line("$")
				:execute "read ".l:snippetfile
				let	length= line("$")-length-1
				if length>=0
					silent exe "normal =".length."+"
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
endfunction
"
"------------------------------------------------------------------------------
"  run : hardcopy
"------------------------------------------------------------------------------
function! BASH_Hardcopy (arg1)
	let	Sou		= expand("%")								" name of the file in the current buffer
	" ----- normal mode ----------------
	if a:arg1=="n"
		exe	"hardcopy > ".Sou.".ps"		
	endif
	" ----- visual mode ----------------
	if a:arg1=="v"
		exe	"*hardcopy > ".Sou.".part.ps"		
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Run : settings
"------------------------------------------------------------------------------
function! BASH_Settings ()
	let	txt	=     "  Bash-Support settings\n\n"
	let txt = txt."            author name :  ".s:BASH_AuthorName."\n"
	let txt = txt."               initials :  ".s:BASH_AuthorRef."\n"
	let txt = txt."           autho  email :  ".s:BASH_Email."\n"
	let txt = txt."                company :  ".s:BASH_Company."\n"
	let txt = txt."                project :  ".s:BASH_Project."\n"
	let txt = txt."       copyright holder :  ".s:BASH_CopyrightHolder."\n"
	let txt = txt." code snippet directory :  ".s:BASH_CodeSnippets."\n"
	let txt = txt."     template directory :  ".s:BASH_Template_Directory."\n"
	if g:BASH_Dictionary_File != ""
		let ausgabe= substitute( g:BASH_Dictionary_File, ",", ",\n                         + ", "g" )
		let txt = txt."     dictionary file(s) :  ".ausgabe."\n"
	endif
	let txt = txt."\n"
	let txt = txt."    Additional hot keys\n\n"
	let txt = txt."                Ctrl-F9  :  update file, run script           \n"
	let txt = txt."                 Alt-F9  :  update file, run syntax check     \n"
	let	txt = txt."________________________________________________________________________\n"
	let	txt = txt." Bash-Support, Version ".s:BASH_Version." / Dr.-Ing. Fritz Mehner / mehner@fh-swf.de\n\n"
	echo txt
endfunction
"
"------------------------------------------------------------------------------
"  Look for a new bashsupport help file
"------------------------------------------------------------------------------
function! BASH_CheckNewDoc ()
	if	getftime( s:BASH_Doc_Directory.'bashsupport.txt' ) > 
		\	getftime( s:BASH_Doc_Directory.'tags' )
		silent exe 'helptags '.s:BASH_Doc_Directory
	endif
endfunction
"
"
"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
function! Bash_CreateUnLoadMenuEntries ()
	"
	" Bash is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:BASH_Active == 1
		:aunmenu &Tools.Load\ Bash\ Support
		exe 'amenu  <silent> 40.1021  &Tools.Unload\ Bash\ Support  	<C-C>:call Bash_Handle()<CR>'
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
		exe 'amenu <silent> 40.1021 &Tools.Load\ Bash\ Support <C-C>:call Bash_Handle()<CR>'
	endif
	"
endfunction
"
"------------------------------------------------------------------------------
"  Loads or unloads Bash extensions menus
"------------------------------------------------------------------------------
function! Bash_Handle ()
	if s:BASH_Active == 0
		:call Bash_InitMenu()
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
				aunmenu Set
				aunmenu I/O-Redir
				aunmenu Run
			else
				exe "aunmenu ".s:BASH_Root
			endif
		endif

		let s:BASH_Active = 0
	endif

	call Bash_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call Bash_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
if s:BASH_LoadMenus == "yes"
	call Bash_Handle()											" load the menus
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
	autocmd BufNewFile  *.sh     call BASH_CommentTemplates('header') | :w! | :!chmod -c u+x %
endif " has("autocmd")
"
"------------------------------------------------------------------------------
"  Key mappings : show / hide the bash-support menus
"------------------------------------------------------------------------------
"
nmap    <silent>  <Leader>lbs             :call Bash_Handle()<CR>
nmap    <silent>  <Leader>ubs             :call Bash_Handle()<CR>
"
"------------------------------------------------------------------------------
"  Look for a new bashsupport help file
"------------------------------------------------------------------------------
call BASH_CheckNewDoc()
"
"------------------------------------------------------------------------------
"  vim: set tabstop=2: set shiftwidth=2: 
