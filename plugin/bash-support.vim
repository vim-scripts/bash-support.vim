"###############################################################################################
"
"     Filename:  bash-support.vim
"
"  Description:  BASH support     (VIM Version 6.0)
"
"                Write BASH-scripts by inserting comments, statements, tests, 
"                variables and builtins.
"
" GVIM Version:  6.0+
"
"       Author:  Dr.-Ing. Fritz Mehner 
"                Fachhochschule Südwestfalen, 58644 Iserlohn, Germany
"
"        Email:  mehner@fh-swf.de
"        
"        Usage:  (1.0) Configure  bash-support.vim  (section Configuration below).
"                (2.1) Load  bash-support.vim  manually into VIM with the 'so' command:
"                        :so ~/<any directory>/bash-support.vim
"                      or better
"                (2.2) Load bash-support.vim on startup (VIM version 6.0 and higher) :
"                      move this file to the directory ~/.vim/plugin/
"                bash-support.vim inserts an additional menu entry into the Tools-menu for
"                loading/unloading the BASH support.
"
"       Credit:  Lennart Schultz, les@dmi.min.dk 
"                The file shellmenu.vim in the macro directory of the 
"                vim standard distribution was my starting point.
"
let s:BASH_Version = "1.5"              " version number of this script; do not change
"     Revision:  31.05.2003
"      Created:  26.02.2001
"###############################################################################################
"
"  Configuration  (use my configuration as an example)
"
"------------------------------------------------------------------------------------------
"   plugin variable          value                                     tag
"------------------------------------------------------------------------------------------
let s:BASH_AuthorName      = "Dr.-Ing. Fritz Mehner"				 				 " |AUTHOR|
let s:BASH_AuthorRef       = "Mn"                            				 " |AUTHORREF|
let s:BASH_Email           = "mehner@fh-swf.de"              				 " |EMAIL|
let s:BASH_Company         = "FH Südwestfalen, Iserlohn"     				 " |COMPANY|   
let s:BASH_Project         = ""                                      " |PROJECT|
let s:BASH_CopyrightHolder = s:BASH_AuthorName    								   " |COPYRIGHTHOLDER|
"
"  Copyright information. If the code has been developed over a period of years, 
"  each year must be stated. In a template file use a fixed year in the first position :
"  
"    '#     Copyright (C) 1998-|YEAR|  |COPYRIGHTHOLDER|'
"
"
" The menu entries for code snippet support will not appear if the following string is empty 
" 
let s:BASH_CodeSnippetDir = $HOME."/.vim/codesnippets-bash"   " code snippet, Makefile-templates, ...
"
let s:BASH_ShowMenues     = "yes"   " show menues immediately after loading (yes/no)
"
"  
let s:BASH_Template_Directory    = $HOME."/.vim/plugin/templates/"
"                           
"                             ----- bash template files ---- ( 1. set of templates ) ----
"                             
let s:BASH_Template_File         = "bash-file-header"
let s:BASH_Template_Frame        = "bash-frame"
let s:BASH_Template_Function     = "bash-function-description"
"
"---------------------------------------------------------------------------------------------
"
function!	Bash_InitMenu ()
"
"===============================================================================================
"----- Menu : Key Mappings ---------------------------------------------------------------------
"===============================================================================================
"  The following key mappings are for convenience only. 
"  Comment out the mappings if you dislike them.
"  If enabled, there may be conflicts with predefined key bindings of your window manager.
"-------------------------------------------------------------------------------------
"  Ctrl-F9   update file and run script
"
"   run the script from the local directory 
"   ( the one which is being edited; other versions may exist elsewhere ! )
"   
	noremap  <C-F9>    :call BASH_Run()<CR>
"
	inoremap  <C-F9>  <Esc>:call BASH_Run()<CR>
"
"
"----- for developement only -------------------------------------------------------------------
"
"	noremap   <F12>       :write<CR><Esc>:so %<CR><Esc>:call Bash_Handle()<CR><Esc>:call Bash_Handle()<CR><Esc>:call Bash_Handle()<CR>
"	inoremap  <F12>  <Esc>:write<CR><Esc>:so %<CR><Esc>:call Bash_Handle()<CR><Esc>:call Bash_Handle()<CR><Esc>:call Bash_Handle()<CR>
"
"-------------------------------------------------------------------------------------
"
amenu &Comments.&Line\ End\ Comment           <Esc><Esc>A<Tab><Tab><Tab># 

amenu  <silent>  &Comments.&Frame\ Comment         <Esc><Esc>:call BASH_CommentTemplates('frame')<CR>
amenu  <silent>  &Comments.F&unction\ Description  <Esc><Esc>:call BASH_CommentTemplates('function')<CR>
amenu  <silent>  &Comments.File\ &Header           <Esc><Esc>:call BASH_CommentTemplates('header')<CR>

amenu &Comments.-Sep1-                         :
vmenu &Comments.&code->comment                <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>
vmenu &Comments.c&omment->code                <Esc><Esc>:'<,'>s/^\#//<CR><Esc>:nohlsearch<CR>
amenu &Comments.-SEP2-                        :

 menu  &Comments.&Date                      i<C-R>=strftime("%x")<CR>
imenu  &Comments.&Date                       <C-R>=strftime("%x")<CR>
 menu  &Comments.Date\ &Time                i<C-R>=strftime("%x %X %Z")<CR>
imenu  &Comments.Date\ &Time                 <C-R>=strftime("%x %X %Z")<CR>

amenu &Comments.-SEP3-                        :
amenu &Comments.\#\ \:&KEYWORD\:.&BUG               <Esc><Esc>$<Esc>:call BASH_CommentClassified("BUG")     <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.&TODO              <Esc><Esc>$<Esc>:call BASH_CommentClassified("TODO")    <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.T&RICKY            <Esc><Esc>$<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.&WARNING           <Esc><Esc>$<Esc>:call BASH_CommentClassified("WARNING") <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.&new\ keyword      <Esc><Esc>$<Esc>:call BASH_CommentClassified("")        <CR>kgJf:a

amenu &Comments.-SEP3-                        :
amenu &Comments.&vim\ modeline            <Esc><Esc>:call BASH_CommentVimModeline()<CR>
"
 menu St&mts.${\.\.\.}						<Esc>a${}<Esc>i
 menu St&mts.$(\.\.\.)						<Esc>a$()<Esc>i
 menu St&mts.$((\.\.\.))					<Esc>a$(())<Esc>hi
vmenu St&mts.${\.\.\.}						s${}<Esc>Pla
vmenu St&mts.$(\.\.\.)						s$()<Esc>Pla
vmenu St&mts.$((\.\.\.))					s$(())<Esc>hP2la
imenu St&mts.${\.\.\.}						${}<Esc>i
imenu St&mts.$(\.\.\.)						$()<Esc>i
imenu St&mts.$((\.\.\.))					$(())<Esc>hi
"
amenu St&mts.-SEP1-                      :
amenu St&mts.&for									<Esc><Esc>ofor  in <CR>do<CR>done<Esc>2k^f<Space>a
amenu St&mts.&case								<Esc><Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
amenu St&mts.&if									<Esc><Esc>oif <CR>then<CR>fi<Esc>2k^A
amenu St&mts.if-&else							<Esc><Esc>oif <CR>then<CR>else<CR>fi<Esc>3kA
amenu St&mts.e&lif								<Esc><Esc>oelif <CR>then<Esc>1kA
amenu St&mts.&select							<Esc><Esc>oselect  in <CR>do<CR>done<Esc>2kf a
amenu St&mts.&while								<Esc><Esc>owhile <CR>do<CR>done<Esc>2kA
amenu St&mts.un&til								<Esc><Esc>ountil <CR>do<CR>done<Esc>2kA

vmenu St&mts.&for								  DOfor  in <CR>do<CR>done<Esc>P2k^<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f<Space>a
vmenu St&mts.&if									DOif <CR>then<CR>fi<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A
vmenu St&mts.if-&else							DOif <CR>then<CR>else<CR>fi<Esc>kP<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>2kA
vmenu St&mts.&select							DOselect  in <CR>do<CR>done<Esc>P2k^<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f<Space>a
vmenu St&mts.&while								DOwhile <CR>do<CR>done<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A
vmenu St&mts.un&til								DOuntil <CR>do<CR>done<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A

amenu St&mts.&break								<Esc><Esc>obreak 
amenu St&mts.co&ntinue						<Esc><Esc>ocontinue 
amenu St&mts.f&unction						<Esc><Esc>o<Esc>:call BASH_CodeFunction()<CR>2jA
amenu St&mts.&return							<Esc><Esc>oreturn 
amenu St&mts.return\ &0\ (true)		<Esc><Esc>oreturn 0
amenu St&mts.return\ &1\ (false)	<Esc><Esc>oreturn 1
amenu St&mts.e&xit								<Esc><Esc>oexit 
amenu St&mts.s&hift								<Esc><Esc>oshift 
amenu St&mts.tra&p								<Esc><Esc>otrap 
"
amenu St&mts.-SEP2-                      :
"
vmenu St&mts.'\.\.\.'							s''<Esc>Pla
vmenu St&mts."\.\.\."							s""<Esc>Pla
vmenu St&mts.`\.\.\.`							s``<Esc>Pla
"
amenu St&mts.ech&o\ "xxx"	  									<Esc><Esc>^iecho<Space>"<Esc>$a"
imenu St&mts.ech&o\ "xxx"	  									echo<Space>""<Esc>i
vmenu St&mts.ech&o\ "xxx"    									secho<Space>""<Esc>P
amenu <silent> St&mts.remo&ve\ echo  		      <Esc><Esc>0:s/echo\s\+\"// \| s/\s*\"\s*$//<CR>
"
	if s:BASH_CodeSnippetDir != ""
		amenu  St&mts.-SEP4-                      :
		amenu  <silent> St&mts.read\ code\ snippet        <C-C>:call BASH_CodeSnippets("r")<CR>
		amenu  <silent> St&mts.write\ code\ snippet       <C-C>:call BASH_CodeSnippets("w")<CR>
		vmenu  <silent> St&mts.write\ code\ snippet       <C-C>:call BASH_CodeSnippets("wv")<CR>
		amenu  <silent> St&mts.edit\ code\ snippet        <C-C>:call BASH_CodeSnippets("e")<CR>
	endif
"
"-------------------------------------------------------------------------------
" file tests
"-------------------------------------------------------------------------------
" 
 menu Test.file\ &exists																											<Esc>a[ -e  ]<Esc>hi
 menu Test.file\ exists\ and\ has\ a\ size\ greater\ than\ &zero							<Esc>a[ -s  ]<Esc>hi
" 
imenu Test.file\ &exists																											[ -e  ]<Esc>hi
imenu Test.file\ exists\ and\ has\ a\ size\ greater\ than\ &zero							[ -s  ]<Esc>hi
" 
imenu Test.-Sep1-                         :
	"
	"---------- submenu arithmetic tests -----------------------------------------------------------
	"
	 menu Test.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2													<Esc>a[  -eq  ]<Esc>F[la
	 menu Test.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2													<Esc>a[  -ne  ]<Esc>F[la
	 menu Test.&arithmetic\ tests.arg1\ &less\ than\ arg2															<Esc>a[  -lt  ]<Esc>F[la
	 menu Test.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2							<Esc>a[  -le  ]<Esc>F[la
	 menu Test.&arithmetic\ tests.arg1\ &greater\ than\ arg2													<Esc>a[  -gt  ]<Esc>F[la
	 menu Test.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2						<Esc>a[  -ge  ]<Esc>F[la
	"
	imenu Test.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2													[  -eq  ]<Esc>F[la
	imenu Test.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2													[  -ne  ]<Esc>F[la
	imenu Test.&arithmetic\ tests.arg1\ &less\ than\ arg2															[  -lt  ]<Esc>F[la
	imenu Test.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2							[  -le  ]<Esc>F[la
	imenu Test.&arithmetic\ tests.arg1\ &greater\ than\ arg2													[  -gt  ]<Esc>F[la
	imenu Test.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2						[  -ge  ]<Esc>F[la
	"
	"---------- submenu file exists and has permission ---------------------------------------------
	"
	 menu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &readable									<Esc>a[ -r  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &writable									<Esc>a[ -w  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ e&xecutable								<Esc>a[ -x  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&UID-bit\ is\ set				<Esc>a[ -u  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&GID-bit\ is\ set				<Esc>a[ -g  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ "&sticky"\ bit\ is\ set	<Esc>a[ -k  ]<Esc>hi
	"
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &readable									[ -r  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &writable									[ -w  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ e&xecutable								[ -x  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&UID-bit\ is\ set				[ -u  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&GID-bit\ is\ set				[ -g  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ "&sticky"\ bit\ is\ set	[ -k  ]<Esc>hi
	"
	"---------- submenu file exists and has type ----------------------------------------------------
	"
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &block\ special\ file			<Esc>a[ -b  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &character\ special\ file	<Esc>a[ -c  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &directory									<Esc>a[ -d  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ named\ &pipe\ (FIFO)				<Esc>a[ -p  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &regular\ file							<Esc>a[ -f  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &socket										<Esc>a[ -S  ]<Esc>hi
	 menu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ symbolic\ &link						<Esc>a[ -L  ]<Esc>hi
	"
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &block\ special\ file			[ -b  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &character\ special\ file	[ -c  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &directory									[ -d  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ named\ &pipe\ (FIFO)				[ -p  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &regular\ file							[ -f  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &socket										[ -S  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ symbolic\ &link						[ -L  ]<Esc>hi
	"
	"---------- submenu string comparison ------------------------------------------------------------
	"
	 menu Test.&string\ comparison.length\ of\ string\ is\ &zero											<Esc>a[ -z  ]<Esc>hi
	 menu Test.&string\ comparison.length\ of\ string\ is\ n&on-zero									<Esc>a[ -n  ]<Esc>hi
	 menu Test.&string\ comparison.strings\ are\ &equal																<Esc>a[  ==  ]<Esc>F[la
	 menu Test.&string\ comparison.strings\ are\ &not\ equal													<Esc>a[  !=  ]<Esc>F[la
	 menu Test.&string\ comparison.string1\ sorts\ &before\ string2\ lexicograph\.		<Esc>a[  <  ]<Esc>F[la
	 menu Test.&string\ comparison.string1\ sorts\ &after\ string2\ lexicographically	<Esc>a[  >  ]<Esc>F[la
	"
	imenu Test.&string\ comparison.length\ of\ string\ is\ &zero											[ -z  ]<Esc>hi
	imenu Test.&string\ comparison.length\ of\ string\ is\ n&on-zero									[ -n  ]<Esc>hi
	imenu Test.&string\ comparison.strings\ are\ &equal																[  ==  ]<Esc>F[la
	imenu Test.&string\ comparison.strings\ are\ &not\ equal													[  !=  ]<Esc>F[la
	imenu Test.&string\ comparison.string1\ sorts\ &before\ string2\ lexicograph\.		[  <  ]<Esc>F[la
	imenu Test.&string\ comparison.string1\ sorts\ &after\ string2\ lexicographically	[  >  ]<Esc>F[la
	"
 menu Test.-Sep2-                         :
 menu Test.file\ exists\ and\ is\ owned\ by\ the\ effective\ &UID								<Esc>a[ -O  ]<Esc>hi
 menu Test.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID								<Esc>a[ -G  ]<Esc>hi
 menu Test.file\ exists\ and\ has\ been\ &modified\ since\ it\ was\ last\ read	<Esc>a[ -N  ]<Esc>hi
 menu Test.file\ &descriptor\ fd\ is\ open\ and\ refers\ to\ a\ terminal				<Esc>a[ -t  ]<Esc>hi
 menu Test.-Sep3-                         :
 menu Test.file1\ is\ &newer\ than\ file2\ (modification\ date)									<Esc>a[  -nt  ]<Esc>F[la
 menu Test.file1\ is\ &older\ than\ file2																				<Esc>a[  -ot  ]<Esc>F[la
 menu Test.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers			<Esc>a[  -ef  ]<Esc>F[la
 menu Test.-Sep4-                         :
 menu Test.she&ll\ option\ optname\ is\ enabled																	<Esc>a[ -o  ]<Esc>hi
"
imenu Test.file\ exists\ and\ is\ owned\ by\ the\ effective\ &UID								[ -O  ]<Esc>hi
imenu Test.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID								[ -G  ]<Esc>hi
imenu Test.file\ exists\ and\ has\ been\ &modified\ since\ it\ was\ last\ read	[ -N  ]<Esc>hi
imenu Test.file\ &descriptor\ fd\ is\ open\ and\ refers\ to\ a\ terminal				[ -t  ]<Esc>hi
imenu Test.-Sep3-                         :
imenu Test.file1\ is\ &newer\ than\ file2\ (modification\ date)									[  -nt  ]<Esc>F[la
imenu Test.file1\ is\ &older\ than\ file2																				[  -ot  ]<Esc>F[la
imenu Test.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers			[  -ef  ]<Esc>F[la
imenu Test.-Sep4-                         :
imenu Test.she&ll\ option\ optname\ is\ enabled																	[ -o  ]<Esc>hi
"
"-------------------------------------------------------------------------------
" parameter substitution
"-------------------------------------------------------------------------------
" 
 menu &ParmSub.Use\ Default\ Value														<Esc>a${:-}<ESC>F{a
 menu &ParmSub.Assign\ Default\ Value													<Esc>a${:=}<ESC>F{a
 menu &ParmSub.Display\ Error\ if\ Null\ or\ Unset						<Esc>a${:?}<ESC>F{a
 menu &ParmSub.Use\ Alternate\ Value													<Esc>a${:+}<ESC>F{a
 menu &ParmSub.parameter\ length\ in\ characters							<Esc>a${#}<ESC>F#a
 menu &ParmSub.match\ the\ beginning;\ delete\ shortest\ part	<Esc>a${#}<ESC>F{a
 menu &ParmSub.match\ the\ beginning;\ delete\ longest\ part	<Esc>a${##}<ESC>F{a
 menu &ParmSub.match\ the\ end;\ delete\ shortest\ part	      <Esc>a${%}<ESC>F{a
 menu &ParmSub.match\ the\ end;\ delete\ longest\ part	      <Esc>a${%%}<ESC>F{a
 menu &ParmSub.replace\ first\ match										 			<Esc>a${/ / }<ESC>F{a
 menu &ParmSub.replace\ all\ matches											    <Esc>a${// / }<ESC>F{a
"
imenu &ParmSub.Use\ Default\ Value														${:-}<ESC>F{a
imenu &ParmSub.Assign\ Default\ Value													${:=}<ESC>F{a
imenu &ParmSub.Display\ Error\ if\ Null\ or\ Unset						${:?}<ESC>F{a
imenu &ParmSub.Use\ Alternate\ Value													${:+}<ESC>F{a
imenu &ParmSub.parameter\ length\ in\ characters							${#}<ESC>F#a
imenu &ParmSub.match\ the\ beginning;\ delete\ shortest\ part	${#}<ESC>F{a
imenu &ParmSub.match\ the\ beginning;\ delete\ longest\ part	${##}<ESC>F{a
imenu &ParmSub.match\ the\ end;\ delete\ shortest\ part	      ${%}<ESC>F{a
imenu &ParmSub.match\ the\ end;\ delete\ longest\ part	      ${%%}<ESC>F{a
imenu &ParmSub.replace\ first\ match										 			${/ / }<ESC>F{a
imenu &ParmSub.replace\ all\ matches											    ${// / }<ESC>F{a
"
"-------------------------------------------------------------------------------
" special variables
"-------------------------------------------------------------------------------
"
 menu Spec&Vars.Number\ of\ positional\ parameters							<Esc>a${#}
 menu Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)		<Esc>a${*}
 menu Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)	<Esc>a${@}
 menu Spec&Vars.Flags\ set																			<Esc>a${-}
 menu Spec&Vars.Return\ code\ of\ last\ command									<Esc>a${?}
 menu Spec&Vars.Process\ number\ of\ this\ shell								<Esc>a${$}
 menu Spec&Vars.Process\ number\ of\ last\ background\ command	<Esc>a${!}
"
imenu Spec&Vars.Number\ of\ positional\ parameters							${#}
imenu Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)		${*}
imenu Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)	${@}
imenu Spec&Vars.Flags\ set																			${-}
imenu Spec&Vars.Return\ code\ of\ last\ command									${?}
imenu Spec&Vars.Process\ number\ of\ this\ shell								${$}
imenu Spec&Vars.Process\ number\ of\ last\ background\ command	${!}
"
"-------------------------------------------------------------------------------
" Shell Variables
"-------------------------------------------------------------------------------
"
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&BASH            <Esc>a${BASH}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.B&ASH_ENV        <Esc>a${BASH_ENV}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.BA&SH_VERSINFO   <Esc>a${BASH_VERSINFO}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.BAS&H_VERSION    <Esc>a${BASH_VERSION}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&CDPATH          <Esc>a${CDPATH}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.C&OLUMNS         <Esc>a${COLUMNS}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.CO&MPREPLY       <Esc>a${COMPREPLY}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COM&P_CWORD      <Esc>a${COMP_CWORD}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&LINE       <Esc>a${COMP_LINE}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_POI&NT      <Esc>a${COMP_POINT}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&WORDS      <Esc>a${COMP_WORDS}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&DIRSTACK        <Esc>a${DIRSTACK}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&EUID            <Esc>a${EUID}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&FCEDIT          <Esc>a${FCEDIT}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&IGNORE         <Esc>a${FIGNORE}
 menu E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&UNCNAME        <Esc>a${FUNCNAME}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE    <Esc>a${GLOBIGNORE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS        <Esc>a${GROUPS}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD       <Esc>a${HISTCMD}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL   <Esc>a${HISTCONTROL}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE      <Esc>a${HISTFILE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE  <Esc>a${HISTFILESIZE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE    <Esc>a${HISTIGNORE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE      <Esc>a${HISTSIZE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME          <Esc>a${HOME}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E      <Esc>a${HOSTFILE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME      <Esc>a${HOSTNAME}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE      <Esc>a${HOSTTYPE}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS           <Esc>a${IFS}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF     <Esc>a${IGNOREEOF}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C       <Esc>a${INPUTRC}
 menu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG          <Esc>a${LANG}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          <Esc>a${LC_ALL}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      <Esc>a${LC_COLLATE}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        <Esc>a${LC_CTYPE}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     <Esc>a${LC_MESSAGES}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      <Esc>a${LC_NUMERIC}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          <Esc>a${LINENO}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           <Esc>a${LINES}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        <Esc>a${MACHTYPE}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            <Esc>a${MAIL}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       <Esc>a${MAILCHECK}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        <Esc>a${MAILPATH}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          <Esc>a${OLDPWD}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          <Esc>a${OPTARG}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          <Esc>a${OPTERR}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          <Esc>a${OPTIND}
 menu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          <Esc>a${OSTYPE}
 menu E&nviron.&PATH\ \.\.\.\ UID.&PATH                 <Esc>a${PATH}
 menu E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           <Esc>a${PIPESTATUS}
 menu E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      <Esc>a${POSIXLY_CORRECT}
 menu E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 <Esc>a${PPID}
 menu E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       <Esc>a${PROMPT_COMMAND}
 menu E&nviron.&PATH\ \.\.\.\ UID.PS&1                  <Esc>a${PS1}
 menu E&nviron.&PATH\ \.\.\.\ UID.PS&2                  <Esc>a${PS2}
 menu E&nviron.&PATH\ \.\.\.\ UID.PS&3                  <Esc>a${PS3}
 menu E&nviron.&PATH\ \.\.\.\ UID.PS&4                  <Esc>a${PS4}
 menu E&nviron.&PATH\ \.\.\.\ UID.P&WD                  <Esc>a${PWD}
 menu E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               <Esc>a${RANDOM}
 menu E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                <Esc>a${REPLY}
 menu E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              <Esc>a${SECONDS}
 menu E&nviron.&PATH\ \.\.\.\ UID.S&HELLOPTS            <Esc>a${SHELLOPTS}
 menu E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                <Esc>a${SHLVL}
 menu E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           <Esc>a${TIMEFORMAT}
 menu E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                <Esc>a${TMOUT}
 menu E&nviron.&PATH\ \.\.\.\ UID.&UID                  <Esc>a${UID}

imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&BASH            ${BASH}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.B&ASH_ENV        ${BASH_ENV}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.BA&SH_VERSINFO   ${BASH_VERSINFO}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.BAS&H_VERSION    ${BASH_VERSION}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&CDPATH          ${CDPATH}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.C&OLUMNS         ${COLUMNS}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.CO&MPREPLY       ${COMPREPLY}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COM&P_CWORD      ${COMP_CWORD}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&LINE       ${COMP_LINE}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_POI&NT      ${COMP_POINT}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&WORDS      ${COMP_WORDS}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&DIRSTACK        ${DIRSTACK}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&EUID            ${EUID}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.&FCEDIT          ${FCEDIT}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&IGNORE         ${FIGNORE}
imenu E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&UNCNAME        ${FUNCNAME}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE    ${GLOBIGNORE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS        ${GROUPS}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD       ${HISTCMD}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL   ${HISTCONTROL}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE      ${HISTFILE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE  ${HISTFILESIZE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE    ${HISTIGNORE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE      ${HISTSIZE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME          ${HOME}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E      ${HOSTFILE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME      ${HOSTNAME}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE      ${HOSTTYPE}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS           ${IFS}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF     ${IGNOREEOF}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C       ${INPUTRC}
imenu E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG          ${LANG}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          ${LC_ALL}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      ${LC_COLLATE}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        ${LC_CTYPE}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     ${LC_MESSAGES}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      ${LC_NUMERIC}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          ${LINENO}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           ${LINES}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        ${MACHTYPE}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            ${MAIL}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       ${MAILCHECK}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        ${MAILPATH}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          ${OLDPWD}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          ${OPTARG}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          ${OPTERR}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          ${OPTIND}
imenu E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          ${OSTYPE}
imenu E&nviron.&PATH\ \.\.\.\ UID.&PATH                 ${PATH}
imenu E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           ${PIPESTATUS}
imenu E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      ${POSIXLY_CORRECT}
imenu E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 ${PPID}
imenu E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       ${PROMPT_COMMAND}
imenu E&nviron.&PATH\ \.\.\.\ UID.PS&1                  ${PS1}
imenu E&nviron.&PATH\ \.\.\.\ UID.PS&2                  ${PS2}
imenu E&nviron.&PATH\ \.\.\.\ UID.PS&3                  ${PS3}
imenu E&nviron.&PATH\ \.\.\.\ UID.PS&4                  ${PS4}
imenu E&nviron.&PATH\ \.\.\.\ UID.P&WD                  ${PWD}
imenu E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               ${RANDOM}
imenu E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                ${REPLY}
imenu E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              ${SECONDS}
imenu E&nviron.&PATH\ \.\.\.\ UID.S&HELLOPTS            ${SHELLOPTS}
imenu E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                ${SHLVL}
imenu E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           ${TIMEFORMAT}
imenu E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                ${TMOUT}
imenu E&nviron.&PATH\ \.\.\.\ UID.&UID                  ${UID}

"
"-------------------------------------------------------------------------------
" Builtins
"-------------------------------------------------------------------------------
"
 menu B&uiltins.&cd         <Esc>acd<Space>
 menu B&uiltins.&echo       <Esc>aecho<Space>
 menu B&uiltins.e&val       <Esc>aeval<Space>
 menu B&uiltins.e&xec       <Esc>aexec<Space>
 menu B&uiltins.ex&port     <Esc>aexport<Space>
 menu B&uiltins.&getopts    <Esc>agetopts<Space>
 menu B&uiltins.&hash       <Esc>ahash<Space>
 menu B&uiltins.&newgrp     <Esc>anewgrp<Space>
 menu B&uiltins.p&wd        <Esc>apwd<Space>
 menu B&uiltins.&read       <Esc>aread<Space>
 menu B&uiltins.read&only   <Esc>areadonly<Space>
 menu B&uiltins.ret&urn     <Esc>areturn<Space>
 menu B&uiltins.&times      <Esc>atimes<Space>
 menu B&uiltins.t&ype       <Esc>atype<Space>
 menu B&uiltins.u&mask      <Esc>aumask<Space>
 menu B&uiltins.w&ait       <Esc>await<Space>
"
imenu B&uiltins.&cd         cd<Space>
imenu B&uiltins.&echo       echo<Space>
imenu B&uiltins.e&val       eval<Space>
imenu B&uiltins.e&xec       exec<Space>
imenu B&uiltins.ex&port     export<Space>
imenu B&uiltins.&getopts    getopts<Space>
imenu B&uiltins.&hash       hash<Space>
imenu B&uiltins.&newgrp     newgrp<Space>
imenu B&uiltins.p&wd        pwd<Space>
imenu B&uiltins.&read       read<Space>
imenu B&uiltins.read&only   readonly<Space>
imenu B&uiltins.ret&urn     return<Space>
imenu B&uiltins.&times      times<Space>
imenu B&uiltins.t&ype       type<Space>
imenu B&uiltins.u&mask      umask<Space>
imenu B&uiltins.w&ait       wait<Space>
"
 menu Set.set																															<Esc>aset<Space>
 menu Set.unset 																													<Esc>aunset<Space>
 menu Set.mark\ modified\ or\ modified\ variables													<Esc>aset -o allexport
 menu Set.exit\ when\ command\ returns\ non-zero\ exit\ code							<Esc>aset -o errexit
 menu Set.Disable\ file\ name\ generation																	<Esc>aset -o noglob
 menu Set.remember\ (hash)\ commands																			<Esc>aset -o hashall
 menu Set.All\ keyword\ arguments\ are\ placed\ in\ the\ environment			<Esc>aset -o keyword
 menu Set.Read\ commands\ but\ do\ not\ execute\ them											<Esc>aset -o noexec
 menu Set.Script\ is\ running\ in\ SUID\ mode             								<Esc>aset -o privileged
 menu Set.Exit\ after\ reading\ and\ executing\ one\ command							<Esc>aset -o onecmd
 menu Set.Treat\ undefined\ variables\ as\ errors\ not\ as\ null					<Esc>aset -o nounset
 menu Set.Print\ shell\ input\ lines\ before\ running\ them								<Esc>aset -o verbose
 menu Set.Print\ commands\ (after\ expansion)\ before\ running\ them			<Esc>aset -o xtrace
" 
imenu Set.set																															set<Space>
imenu Set.unset 																													unset<Space>
imenu Set.mark\ modified\ or\ modified\ variables													set -o allexport
imenu Set.exit\ when\ command\ returns\ non-zero\ exit\ code							set -o errexit
imenu Set.Disable\ file\ name\ generation																	set -o noglob
imenu Set.remember\ (hash)\ commands																			set -o hashall
imenu Set.All\ keyword\ arguments\ are\ placed\ in\ the\ environment			set -o keyword
imenu Set.Read\ commands\ but\ do\ not\ execute\ them											set -o noexec
imenu Set.Script\ is\ running\ in\ SUID\ mode             								set -o privileged
imenu Set.Exit\ after\ reading\ and\ executing\ one\ command							set -o onecmd
imenu Set.Treat\ undefined\ variables\ as\ errors\ not\ as\ null					set -o nounset
imenu Set.Print\ shell\ input\ lines\ before\ running\ them								set -o verbose
imenu Set.Print\ commands\ (after\ expansion)\ before\ running\ them			set -o xtrace
"
"-------------------------------------------------------------------------------
" I/O redirection
"-------------------------------------------------------------------------------
" 
 menu &I/O-Redir.take\ standard\ input\ from\ file												<Esc>a<Space><<Space><ESC>a
 menu &I/O-Redir.direct\ standard\ output\ to\ file												<Esc>a<Space>><Space><ESC>a
 menu &I/O-Redir.direct\ standard\ output\ to\ file;\ append							<Esc>a<Space>>><Space><ESC>a
"
 menu &I/O-Redir.direct\ file\ descriptor\ to\ file												<Esc>a<Space>><Space><ESC>2hi
 menu &I/O-Redir.direct\ file\ descriptor\ to\ file;\ append							<Esc>a<Space>>><Space><ESC>2hi
 menu &I/O-Redir.take\ file\ descriptor\ from\ file												<Esc>a<Space><<Space><ESC>2hi
"
 menu &I/O-Redir.duplicate\ standard\ input\ from\ file\ descriptor				<Esc>a<Space><& <ESC>a
 menu &I/O-Redir.duplicate\ standard\ output\ to\ file\ descriptor				<Esc>a<Space>>& <ESC>a
 menu &I/O-Redir.direct\ standard\ output\ and\ standard\ error\ to\ file	<Esc>a<Space>&> <ESC>a
"
 menu &I/O-Redir.close\ the\ standard\ input															<Esc>a<Space><&- <ESC>a
 menu &I/O-Redir.close\ the\ standard\ output															<Esc>a<Space>>&- <ESC>a
 menu &I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n							<Esc>a<Space><&- <ESC>3hi
 menu &I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n						<Esc>a<Space>>&- <ESC>3hi
"
 menu &I/O-Redir.here-document			<Esc>a<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki
" 
imenu &I/O-Redir.take\ standard\ input\ from\ file												<Space><<Space><ESC>a
imenu &I/O-Redir.direct\ standard\ output\ to\ file												<Space>><Space><ESC>a
imenu &I/O-Redir.direct\ standard\ output\ to\ file;\ append							<Space>>><Space><ESC>a
"
imenu &I/O-Redir.direct\ file\ descriptor\ to\ file												<Space>><Space><ESC>2hi
imenu &I/O-Redir.direct\ file\ descriptor\ to\ file;\ append							<Space>>><Space><ESC>2hi
imenu &I/O-Redir.take\ file\ descriptor\ from\ file												<Space><<Space><ESC>2hi
"
imenu &I/O-Redir.duplicate\ standard\ input\ from\ file\ descriptor				<Space><& <ESC>a
imenu &I/O-Redir.duplicate\ standard\ output\ to\ file\ descriptor				<Space>>& <ESC>a
imenu &I/O-Redir.direct\ standard\ output\ and\ standard\ error\ to\ file	<Space>&> <ESC>a
"
imenu &I/O-Redir.close\ the\ standard\ input															<Space><&- <ESC>a
imenu &I/O-Redir.close\ the\ standard\ output															<Space>>&- <ESC>a
imenu &I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n							<Space><&- <ESC>3hi
imenu &I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n						<Space>>&- <ESC>3hi
"
imenu &I/O-Redir.here-document			<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki
"
"------------------------------------------------------------------------------
"  Run Script
"------------------------------------------------------------------------------
"
"   run the script from the local directory 
"   ( the one in the current buffer ; other versions may exist elsewhere ! )
" 
amenu &Run.update\ file\ and\ &run\ script\ <Ctrl><F9>    <C-C>:call BASH_Run()<CR>
"
"   set execution right only for the user ( may be user root ! )
"
amenu <silent> &Run.make\ script\ &executable                      <C-C>:!chmod -c u+x %<CR>
amenu <silent> &Run.command\ line\ &arguments                      <C-C>:call BASH_Arguments()<CR>
amenu          &Run.-Sep1-                                         :
amenu <silent> &Run.hardcop&y\ all\ to\ FILENAME\.ps               <C-C>:call BASH_Hardcopy("n")<CR>
vmenu <silent> &Run.hardcop&y\ part\ to\ FILENAME\.ps              <C-C>:call BASH_Hardcopy("v")<CR>
imenu          &Run.-SEP2-                                         :
amenu <silent> &Run.&settings                                      <C-C>:call BASH_Settings()<CR>
"
endfunction			" function Bash_InitMenu
"
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
			exe linenumber
			exe "d"
			put! =line
		endwhile
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
  	put = '# vim: set tabstop='.&tabstop.': set shiftwidth='.&shiftwidth.': '
endfunction    " ----------  end of function BASH_CommentVimModeline  ----------
"
"------------------------------------------------------------------------------
"  Stmts : function
"------------------------------------------------------------------------------
function! BASH_CodeFunction ()
	let	identifier=inputdialog("function name", "f" )
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
function! BASH_Run ()
	exe "update"
	let	Script	= expand("%")
	exe "!./".Script." ".s:BASH_CmdLineArgs
endfunction
"
"------------------------------------------------------------------------------
"  run : Arguments
"------------------------------------------------------------------------------
function! BASH_Arguments ()
	let	s:BASH_CmdLineArgs= inputdialog("command line arguments",s:BASH_CmdLineArgs)
endfunction
"
"------------------------------------------------------------------------------
"  Bash-Idioms : read / edit code snippet
"------------------------------------------------------------------------------
function! BASH_CodeSnippets(arg1)
	if isdirectory(s:BASH_CodeSnippetDir)
		"
		" read snippet file, put content below current line
		" 
		if a:arg1 == "r"
			let	l:snippetfile=browse(0,"read a code snippet",s:BASH_CodeSnippetDir,"")
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
			let	l:snippetfile=browse(0,"edit a code snippet",s:BASH_CodeSnippetDir,"")
			if l:snippetfile != ""
				:execute "update! | split | edit ".l:snippetfile
			endif
		endif
		"
		" write whole buffer into snippet file 
		" 
		if a:arg1 == "w"
			let	l:snippetfile=browse(0,"write a code snippet",s:BASH_CodeSnippetDir,"")
			if l:snippetfile != ""
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:BASH_CodeSnippetDir,"")
			if l:snippetfile != ""
				:execute ":*write! ".l:snippetfile
			endif
		endif

	else
		echo "code snippet directory ".s:BASH_CodeSnippetDir." does not exist (please create it)"
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
"  Run : hot keys
"------------------------------------------------------------------------------
function! Bash_HotKeys ()
	let hotkeylist =            "    Additional hot keys:        \n"
	let hotkeylist = hotkeylist."    \n"
	let hotkeylist = hotkeylist."    F2  update (save) file      \n"
	let hotkeylist = hotkeylist."    F3  file open dialog        \n"
	let dummy=confirm( hotkeylist, "ok", 1, "Info" )
endfunction
"
"------------------------------------------------------------------------------
"  Run : settings
"------------------------------------------------------------------------------
function! BASH_Settings ()
	let	settings	=         "Bash-Support settings\n\n"
	let settings = settings."author  :  ".s:BASH_AuthorName." (".s:BASH_AuthorRef.") ".s:BASH_Email."\n"
	let settings = settings."company :  ".s:BASH_Company."\n"
	let settings = settings."copyright holder :  ".s:BASH_CopyrightHolder."\n"
	let settings = settings."\n"
	let settings = settings."code snippet directory  :  ".s:BASH_CodeSnippetDir."\n"
	let settings = settings."\n"
	let settings = settings."\nMake changes in file bash-support.vim\n"
	let	settings = settings."----------------------------------------------------------------------------------------\n"
	let	settings = settings."Bash-Support, Version ".s:BASH_Version."  /  Dr.-Ing. Fritz Mehner  /  mehner@fh-swf.de\n"
	let dummy=confirm( settings, "ok", 1, "Info" )
endfunction
"
"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
let s:Bash_Active = -1														" state variable controlling the Bash-menus
let s:BASH_CmdLineArgs  = ""           " command line arguments for Run-run; initially empty

function! Bash_CreateUnLoadMenuEntries ()
	"
	" Bash is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	" protect the following submenu names against interpolation by using single qoutes (Mn)
	"
	if  s:Bash_Active == 1
		:aunmenu &Tools.Load\ Bash\ Support
		exe 'amenu  <silent> 40.1021  &Tools.Unload\ Bash\ Support  	<C-C>:call Bash_Handle()<CR>'
	else
		" Bash is now inactive and was former active or in initial state -1 
		if s:Bash_Active == 0
			" Remove Tools.Unload if Bash was former inactive
			:aunmenu &Tools.Unload\ Bash\ Support
		else
			" Set initial state Bash_Active=-1 to inactive state Bash_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:Bash_Active = 0
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
	if s:Bash_Active == 0
		:call Bash_InitMenu()
		let s:Bash_Active = 1
	else
		aunmenu Comments
		aunmenu Stmts
		aunmenu Test
		aunmenu ParmSub
		aunmenu SpecVars
		aunmenu Environ
		aunmenu Builtins
		aunmenu Set
		aunmenu I/O-Redir
		aunmenu Run
		let s:Bash_Active = 0
	endif
	
	call Bash_CreateUnLoadMenuEntries ()
endfunction
"
"------------------------------------------------------------------------------
" 
call Bash_CreateUnLoadMenuEntries()			" create the menu entry in the GVIM tool menu
if s:BASH_ShowMenues == "yes"
	call Bash_Handle()											" load the menus
endif
"
"
"------------------------------------------------------------------------------
"  vim: set tabstop=2: set shiftwidth=2: 
