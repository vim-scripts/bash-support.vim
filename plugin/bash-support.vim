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
let s:BASH_Version = "1.7"              " version number of this script; do not change
"     Revision:  08.08.2003
"      Created:  26.02.2001
"###############################################################################################
"
"------------------------------------------------------------------------------
"
"  Global variables (with default values) which can be overridden.
"
let s:BASH_AuthorName            = ""
let s:BASH_AuthorRef             = ""
let s:BASH_Email                 = ""
let s:BASH_Company               = ""
let s:BASH_Project               = ""
let s:BASH_CopyrightHolder       = ""
"
let s:BASH_LoadMenus             = "yes"
" 
let s:BASH_CodeSnippets          = $HOME."/.vim/codesnippets-bash"
" 
let s:BASH_Template_Directory    = $HOME."/.vim/plugin/templates/"
let s:BASH_Template_File         = "bash-file-header"
let s:BASH_Template_Frame        = "bash-frame"
let s:BASH_Template_Function     = "bash-function-description"
"
"
let s:BASH_Pager                 = "less"
"
"------------------------------------------------------------------------------
"
"  Look for global variables (if any), to override the defaults.
"  
if exists("g:BASH_AuthorName")
	let s:BASH_AuthorName         = g:BASH_AuthorName
endif

if exists("g:BASH_AuthorRef")
	let s:BASH_AuthorRef          = g:BASH_AuthorRef       
endif

if exists("g:BASH_Email")
	let s:BASH_Email              = g:BASH_Email
endif

if exists("g:BASH_Company")
	let s:BASH_Company            = g:BASH_Company
endif

if exists("g:BASH_Project")
	let s:BASH_Project            = g:BASH_Project
endif

if exists("g:BASH_CopyrightHolder")
	let s:BASH_CopyrightHolder    = g:BASH_CopyrightHolder
endif
"
if exists("g:BASH_LoadMenus")
	let s:BASH_LoadMenus          = g:BASH_LoadMenus
endif
"
if exists("g:BASH_CodeSnippets")
	let s:BASH_CodeSnippets       = g:BASH_CodeSnippets
endif
"                           
if exists("g:BASH_Template_Directory")
	let s:BASH_Template_Directory = g:BASH_Template_Directory
endif
"                           
if exists("g:BASH_Template_File")
	let s:BASH_Template_File      = g:BASH_Template_File
endif
"                           
if exists("g:BASH_Template_Frame")
	let s:BASH_Template_Frame     = g:BASH_Template_Frame
endif
"                           
if exists("g:BASH_Template_Function")
	let s:BASH_Template_Function  = g:BASH_Template_Function
endif
"
if exists("g:BASH_Pager")
	let s:BASH_Pager              = g:BASH_Pager
endif
"
"
"------------------------------------------------------------------------------
"  BASH Menu Initialization
"------------------------------------------------------------------------------
function!	Bash_InitMenu ()
"
"
"----- for developement only -------------------------------------------------------------------
"
	noremap   <F12>       :write<CR><Esc>:so %<CR><Esc>:call Bash_Handle()<CR><Esc>:call Bash_Handle()<CR>
	inoremap  <F12>  <Esc>:write<CR><Esc>:so %<CR><Esc>:call Bash_Handle()<CR><Esc>:call Bash_Handle()<CR>
"
"-------------------------------------------------------------------------------------
"
if has("gui_running")

	amenu b&ash.<Tab>bash                                    <Esc>
	amenu b&ash.-Sep0-                         :

	amenu b&ash.&Comments.<Tab>bash                                    <Esc>
	amenu b&ash.&Comments.-Sep0-                         :

	amenu b&ash.&Comments.&Line\ End\ Comment           <Esc><Esc>A<Tab><Tab><Tab># 

	amenu <silent>  b&ash.&Comments.&Frame\ Comment          <Esc><Esc>:call BASH_CommentTemplates('frame')<CR>
	amenu <silent>  b&ash.&Comments.F&unction\ Description   <Esc><Esc>:call BASH_CommentTemplates('function')<CR>
	amenu <silent>  b&ash.&Comments.File\ &Header            <Esc><Esc>:call BASH_CommentTemplates('header')<CR>

	amenu b&ash.&Comments.-Sep1-                             :
	vmenu b&ash.&Comments.&code->comment                     <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>
	vmenu b&ash.&Comments.c&omment->code                     <Esc><Esc>:'<,'>s/^\#//<CR><Esc>:nohlsearch<CR>
	amenu b&ash.&Comments.-SEP2-                             :

	 menu b&ash.&Comments.&Date                              i<C-R>=strftime("%x")<CR>
	imenu b&ash.&Comments.&Date                               <C-R>=strftime("%x")<CR>
	 menu b&ash.&Comments.Date\ &Time                        i<C-R>=strftime("%x %X %Z")<CR>
	imenu b&ash.&Comments.Date\ &Time                         <C-R>=strftime("%x %X %Z")<CR>

	amenu b&ash.&Comments.-SEP3-                        :

	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.<Tab>bash                                    <Esc>
	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.-Sep0-                         :

	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.&BUG              <Esc><Esc>$<Esc>:call BASH_CommentClassified("BUG")     <CR>kgJA
	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.&TODO             <Esc><Esc>$<Esc>:call BASH_CommentClassified("TODO")    <CR>kgJA
	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.T&RICKY           <Esc><Esc>$<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kgJA
	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.&WARNING          <Esc><Esc>$<Esc>:call BASH_CommentClassified("WARNING") <CR>kgJA
	amenu b&ash.&Comments.\#\ \:&KEYWORD\:.&new\ keyword     <Esc><Esc>$<Esc>:call BASH_CommentClassified("")        <CR>kgJf:a

	amenu b&ash.&Comments.-SEP3-                        :
	amenu b&ash.&Comments.&vim\ modeline          <Esc><Esc>:call BASH_CommentVimModeline()<CR>
	"
	amenu b&ash.St&atements.<Tab>bash                                    <Esc>
	amenu b&ash.St&atements.-Sep0-                         :

	 menu b&ash.St&atements.${\.\.\.}							<Esc>a${}<Esc>i
	 menu b&ash.St&atements.$(\.\.\.)							<Esc>a$()<Esc>i
	 menu b&ash.St&atements.$((\.\.\.))						<Esc>a$(())<Esc>hi
	vmenu b&ash.St&atements.${\.\.\.}							s${}<Esc>Pla
	vmenu b&ash.St&atements.$(\.\.\.)							s$()<Esc>Pla
	vmenu b&ash.St&atements.$((\.\.\.))						s$(())<Esc>hP2la
	imenu b&ash.St&atements.${\.\.\.}							${}<Esc>i
	imenu b&ash.St&atements.$(\.\.\.)							$()<Esc>i
	imenu b&ash.St&atements.$((\.\.\.))						$(())<Esc>hi
	"
	amenu b&ash.St&atements.-SEP1-                      :
	amenu b&ash.St&atements.&case									<Esc><Esc>ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
	amenu b&ash.St&atements.e&lif									<Esc><Esc>oelif <CR>then<Esc>1kA
	amenu b&ash.St&atements.&for									<Esc><Esc>ofor  in <CR>do<CR>done<Esc>2k^f<Space>a
	amenu b&ash.St&atements.&if										<Esc><Esc>oif <CR>then<CR>fi<Esc>2k^A
	amenu b&ash.St&atements.if-&else							<Esc><Esc>oif <CR>then<CR>else<CR>fi<Esc>3kA
	amenu b&ash.St&atements.&select								<Esc><Esc>oselect  in <CR>do<CR>done<Esc>2kf<Space>a
	amenu b&ash.St&atements.un&til								<Esc><Esc>ountil <CR>do<CR>done<Esc>2kA
	amenu b&ash.St&atements.&while								<Esc><Esc>owhile <CR>do<CR>done<Esc>2kA

	vmenu b&ash.St&atements.&for								  DOfor  in <CR>do<CR>done<Esc>P2k^<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f<Space>a
	vmenu b&ash.St&atements.&if										DOif <CR>then<CR>fi<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A
	vmenu b&ash.St&atements.if-&else							DOif <CR>then<CR>else<CR>fi<Esc>kP<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>2kA
	vmenu b&ash.St&atements.&select								DOselect  in <CR>do<CR>done<Esc>P2k^<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f<Space>a
	vmenu b&ash.St&atements.un&til								DOuntil <CR>do<CR>done<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A
	vmenu b&ash.St&atements.&while								DOwhile <CR>do<CR>done<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A

	amenu b&ash.St&atements.&break								<Esc><Esc>obreak 
	amenu b&ash.St&atements.co&ntinue							<Esc><Esc>ocontinue 
	amenu b&ash.St&atements.f&unction							<Esc><Esc>o<Esc>:call BASH_CodeFunction()<CR>2jA
	amenu b&ash.St&atements.&return								<Esc><Esc>oreturn 
	amenu b&ash.St&atements.return\ &0\ (true)		<Esc><Esc>oreturn 0
	amenu b&ash.St&atements.return\ &1\ (false)		<Esc><Esc>oreturn 1
	amenu b&ash.St&atements.e&xit									<Esc><Esc>oexit 
	amenu b&ash.St&atements.s&hift								<Esc><Esc>oshift 
	amenu b&ash.St&atements.tra&p									<Esc><Esc>otrap 
	"
	amenu b&ash.St&atements.-SEP2-                      :
	"
	vmenu b&ash.St&atements.'\.\.\.'							s''<Esc>Pla
	vmenu b&ash.St&atements."\.\.\."							s""<Esc>Pla
	vmenu b&ash.St&atements.`\.\.\.`							s``<Esc>Pla
	"
	amenu b&ash.St&atements.ech&o\ "xxx"	  									<Esc><Esc>^iecho<Space>"<Esc>$a"<Esc>j
	imenu b&ash.St&atements.ech&o\ "xxx"	  									echo<Space>""<Esc>i
	vmenu b&ash.St&atements.ech&o\ "xxx"    									secho<Space>""<Esc>P
	"
	amenu <silent> b&ash.St&atements.remo&ve\ echo  		      <Esc><Esc>0:s/echo\s\+\"// \| s/\s*\"\s*$//<CR><Esc>j
	"
	if s:BASH_CodeSnippets != ""
		amenu  b&ash.St&atements.-SEP4-                      :
		amenu  <silent> b&ash.St&atements.read\ code\ snippet        <C-C>:call BASH_CodeSnippets("r")<CR>
		amenu  <silent> b&ash.St&atements.write\ code\ snippet       <C-C>:call BASH_CodeSnippets("w")<CR>
		vmenu  <silent> b&ash.St&atements.write\ code\ snippet       <C-C>:call BASH_CodeSnippets("wv")<CR>
		amenu  <silent> b&ash.St&atements.edit\ code\ snippet        <C-C>:call BASH_CodeSnippets("e")<CR>
	endif
	"
	"-------------------------------------------------------------------------------
	" file tests
	"-------------------------------------------------------------------------------
	" 
	amenu b&ash.&Tests.<Tab>bash                                    <Esc>
	amenu b&ash.&Tests.-Sep0-                         :

	 menu b&ash.&Tests.file\ &exists																											<Esc>a[ -e  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ a\ size\ greater\ than\ &zero							<Esc>a[ -s  ]<Esc>hi
	" 
	imenu b&ash.&Tests.file\ &exists																											[ -e  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ a\ size\ greater\ than\ &zero							[ -s  ]<Esc>hi
	" 
	imenu b&ash.&Tests.-Sep1-                         :
	"
	"---------- submenu arithmetic tests -----------------------------------------------------------
	"
	amenu b&ash.&Tests.&arithmetic\ tests.<Tab>bash                                    <Esc>
	amenu b&ash.&Tests.&arithmetic\ tests.-Sep0-                         :
	 menu b&ash.&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2													<Esc>a[  -eq  ]<Esc>F[la
	 menu b&ash.&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2													<Esc>a[  -ne  ]<Esc>F[la
	 menu b&ash.&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2															<Esc>a[  -lt  ]<Esc>F[la
	 menu b&ash.&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2							<Esc>a[  -le  ]<Esc>F[la
	 menu b&ash.&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2													<Esc>a[  -gt  ]<Esc>F[la
	 menu b&ash.&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2						<Esc>a[  -ge  ]<Esc>F[la
	"
	imenu b&ash.&Tests.&arithmetic\ tests.arg1\ is\ &equal\ to\ arg2													[  -eq  ]<Esc>F[la
	imenu b&ash.&Tests.&arithmetic\ tests.arg1\ &not\ equal\ to\ arg2													[  -ne  ]<Esc>F[la
	imenu b&ash.&Tests.&arithmetic\ tests.arg1\ &less\ than\ arg2															[  -lt  ]<Esc>F[la
	imenu b&ash.&Tests.&arithmetic\ tests.arg1\ le&ss\ than\ or\ equal\ to\ arg2							[  -le  ]<Esc>F[la
	imenu b&ash.&Tests.&arithmetic\ tests.arg1\ &greater\ than\ arg2													[  -gt  ]<Esc>F[la
	imenu b&ash.&Tests.&arithmetic\ tests.arg1\ g&reater\ than\ or\ equal\ to\ arg2						[  -ge  ]<Esc>F[la
	"
	"---------- submenu file exists and has permission ---------------------------------------------
	"
	amenu b&ash.&Tests.file\ exists\ and\ has\ &permission.<Tab>bash                                    <Esc>
	amenu b&ash.&Tests.file\ exists\ and\ has\ &permission.-Sep0-                         :
	 menu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &readable									<Esc>a[ -r  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &writable									<Esc>a[ -w  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ e&xecutable								<Esc>a[ -x  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&UID-bit\ is\ set				<Esc>a[ -u  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&GID-bit\ is\ set				<Esc>a[ -g  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ "&sticky"\ bit\ is\ set	<Esc>a[ -k  ]<Esc>hi
	"
	imenu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &readable									[ -r  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &writable									[ -w  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ e&xecutable								[ -x  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&UID-bit\ is\ set				[ -u  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&GID-bit\ is\ set				[ -g  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ "&sticky"\ bit\ is\ set	[ -k  ]<Esc>hi
	"
	"---------- submenu file exists and has type ----------------------------------------------------
	"
	amenu b&ash.&Tests.file\ exists\ and\ has\ &type.<Tab>bash                                    <Esc>
	amenu b&ash.&Tests.file\ exists\ and\ has\ &type.-Sep0-                         :
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &block\ special\ file			<Esc>a[ -b  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &character\ special\ file	<Esc>a[ -c  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &directory									<Esc>a[ -d  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ named\ &pipe\ (FIFO)				<Esc>a[ -p  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &regular\ file							<Esc>a[ -f  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &socket										<Esc>a[ -S  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ symbolic\ &link						<Esc>a[ -L  ]<Esc>hi
	"
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &block\ special\ file			[ -b  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &character\ special\ file	[ -c  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &directory									[ -d  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ named\ &pipe\ (FIFO)				[ -p  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &regular\ file							[ -f  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ &socket										[ -S  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ &type.file\ exists\ and\ is\ a\ symbolic\ &link						[ -L  ]<Esc>hi
	"
	"---------- submenu string comparison ------------------------------------------------------------
	"
	amenu b&ash.&Tests.&string\ comparison.<Tab>bash                                    <Esc>
	amenu b&ash.&Tests.&string\ comparison.-Sep0-                         :
	 menu b&ash.&Tests.&string\ comparison.length\ of\ string\ is\ &zero											<Esc>a[ -z  ]<Esc>hi
	 menu b&ash.&Tests.&string\ comparison.length\ of\ string\ is\ n&on-zero									<Esc>a[ -n  ]<Esc>hi
	 menu b&ash.&Tests.&string\ comparison.strings\ are\ &equal																<Esc>a[  ==  ]<Esc>F[la
	 menu b&ash.&Tests.&string\ comparison.strings\ are\ &not\ equal													<Esc>a[  !=  ]<Esc>F[la
	 menu b&ash.&Tests.&string\ comparison.string1\ sorts\ &before\ string2\ lexicograph\.		<Esc>a[  <  ]<Esc>F[la
	 menu b&ash.&Tests.&string\ comparison.string1\ sorts\ &after\ string2\ lexicographically	<Esc>a[  >  ]<Esc>F[la
	"
	imenu b&ash.&Tests.&string\ comparison.length\ of\ string\ is\ &zero											[ -z  ]<Esc>hi
	imenu b&ash.&Tests.&string\ comparison.length\ of\ string\ is\ n&on-zero									[ -n  ]<Esc>hi
	imenu b&ash.&Tests.&string\ comparison.strings\ are\ &equal																[  ==  ]<Esc>F[la
	imenu b&ash.&Tests.&string\ comparison.strings\ are\ &not\ equal													[  !=  ]<Esc>F[la
	imenu b&ash.&Tests.&string\ comparison.string1\ sorts\ &before\ string2\ lexicograph\.		[  <  ]<Esc>F[la
	imenu b&ash.&Tests.&string\ comparison.string1\ sorts\ &after\ string2\ lexicographically	[  >  ]<Esc>F[la
	"
	 menu b&ash.&Tests.-Sep2-                         :
	 menu b&ash.&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &UID								<Esc>a[ -O  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID								<Esc>a[ -G  ]<Esc>hi
	 menu b&ash.&Tests.file\ exists\ and\ has\ been\ &modified\ since\ it\ was\ last\ read	<Esc>a[ -N  ]<Esc>hi
	 menu b&ash.&Tests.file\ &descriptor\ fd\ is\ open\ and\ refers\ to\ a\ terminal				<Esc>a[ -t  ]<Esc>hi
	 menu b&ash.&Tests.-Sep3-                         :
	 menu b&ash.&Tests.file1\ is\ &newer\ than\ file2\ (modification\ date)									<Esc>a[  -nt  ]<Esc>F[la
	 menu b&ash.&Tests.file1\ is\ &older\ than\ file2																				<Esc>a[  -ot  ]<Esc>F[la
	 menu b&ash.&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers			<Esc>a[  -ef  ]<Esc>F[la
	 menu b&ash.&Tests.-Sep4-                         :
	 menu b&ash.&Tests.she&ll\ option\ optname\ is\ enabled																	<Esc>a[ -o  ]<Esc>hi
	"
	imenu b&ash.&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &UID								[ -O  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID								[ -G  ]<Esc>hi
	imenu b&ash.&Tests.file\ exists\ and\ has\ been\ &modified\ since\ it\ was\ last\ read	[ -N  ]<Esc>hi
	imenu b&ash.&Tests.file\ &descriptor\ fd\ is\ open\ and\ refers\ to\ a\ terminal				[ -t  ]<Esc>hi
	imenu b&ash.&Tests.-Sep3-                         :
	imenu b&ash.&Tests.file1\ is\ &newer\ than\ file2\ (modification\ date)									[  -nt  ]<Esc>F[la
	imenu b&ash.&Tests.file1\ is\ &older\ than\ file2																				[  -ot  ]<Esc>F[la
	imenu b&ash.&Tests.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers			[  -ef  ]<Esc>F[la
	imenu b&ash.&Tests.-Sep4-                         :
	imenu b&ash.&Tests.she&ll\ option\ optname\ is\ enabled																	[ -o  ]<Esc>hi
	"
	"-------------------------------------------------------------------------------
	" parameter substitution
	"-------------------------------------------------------------------------------
	" 
	amenu b&ash.&ParmSub.<Tab>bash                                    <Esc>
	amenu b&ash.&ParmSub.-Sep0-                         :

	 menu b&ash.&ParmSub.Use\ Default\ Value														<Esc>a${:-}<ESC>F{a
	 menu b&ash.&ParmSub.Assign\ Default\ Value													<Esc>a${:=}<ESC>F{a
	 menu b&ash.&ParmSub.Display\ Error\ if\ Null\ or\ Unset						<Esc>a${:?}<ESC>F{a
	 menu b&ash.&ParmSub.Use\ Alternate\ Value													<Esc>a${:+}<ESC>F{a
	 menu b&ash.&ParmSub.parameter\ length\ in\ characters							<Esc>a${#}<ESC>F#a
	 menu b&ash.&ParmSub.match\ the\ beginning;\ delete\ shortest\ part	<Esc>a${#}<ESC>F{a
	 menu b&ash.&ParmSub.match\ the\ beginning;\ delete\ longest\ part	<Esc>a${##}<ESC>F{a
	 menu b&ash.&ParmSub.match\ the\ end;\ delete\ shortest\ part	      <Esc>a${%}<ESC>F{a
	 menu b&ash.&ParmSub.match\ the\ end;\ delete\ longest\ part	      <Esc>a${%%}<ESC>F{a
	 menu b&ash.&ParmSub.replace\ first\ match										 			<Esc>a${/ / }<ESC>F{a
	 menu b&ash.&ParmSub.replace\ all\ matches											    <Esc>a${// / }<ESC>F{a
	"
	imenu b&ash.&ParmSub.Use\ Default\ Value														${:-}<ESC>F{a
	imenu b&ash.&ParmSub.Assign\ Default\ Value													${:=}<ESC>F{a
	imenu b&ash.&ParmSub.Display\ Error\ if\ Null\ or\ Unset						${:?}<ESC>F{a
	imenu b&ash.&ParmSub.Use\ Alternate\ Value													${:+}<ESC>F{a
	imenu b&ash.&ParmSub.parameter\ length\ in\ characters							${#}<ESC>F#a
	imenu b&ash.&ParmSub.match\ the\ beginning;\ delete\ shortest\ part	${#}<ESC>F{a
	imenu b&ash.&ParmSub.match\ the\ beginning;\ delete\ longest\ part	${##}<ESC>F{a
	imenu b&ash.&ParmSub.match\ the\ end;\ delete\ shortest\ part	      ${%}<ESC>F{a
	imenu b&ash.&ParmSub.match\ the\ end;\ delete\ longest\ part	      ${%%}<ESC>F{a
	imenu b&ash.&ParmSub.replace\ first\ match										 			${/ / }<ESC>F{a
	imenu b&ash.&ParmSub.replace\ all\ matches											    ${// / }<ESC>F{a
	"
	"-------------------------------------------------------------------------------
	" special variables
	"-------------------------------------------------------------------------------
	"
	amenu b&ash.Spec&Vars.<Tab>bash                                    <Esc>
	amenu b&ash.Spec&Vars.-Sep0-                         :

	 menu b&ash.Spec&Vars.Number\ of\ positional\ parameters							<Esc>a${#}
	 menu b&ash.Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)		<Esc>a${*}
	 menu b&ash.Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)	<Esc>a${@}
	 menu b&ash.Spec&Vars.Flags\ set																			<Esc>a${-}
	 menu b&ash.Spec&Vars.Return\ code\ of\ last\ command									<Esc>a${?}
	 menu b&ash.Spec&Vars.Process\ number\ of\ this\ shell								<Esc>a${$}
	 menu b&ash.Spec&Vars.Process\ number\ of\ last\ background\ command	<Esc>a${!}
	"
	imenu b&ash.Spec&Vars.Number\ of\ positional\ parameters							${#}
	imenu b&ash.Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)		${*}
	imenu b&ash.Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)	${@}
	imenu b&ash.Spec&Vars.Flags\ set																			${-}
	imenu b&ash.Spec&Vars.Return\ code\ of\ last\ command									${?}
	imenu b&ash.Spec&Vars.Process\ number\ of\ this\ shell								${$}
	imenu b&ash.Spec&Vars.Process\ number\ of\ last\ background\ command	${!}
	"
	"-------------------------------------------------------------------------------
	" Shell Variables
	"-------------------------------------------------------------------------------
	"
	amenu b&ash.E&nviron.<Tab>bash                                    <Esc>
	amenu b&ash.E&nviron.-Sep0-                         :

	"
	amenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.<Tab>bash                                    <Esc>
	amenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.-Sep0-                         :
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&BASH            <Esc>a${BASH}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.B&ASH_ENV        <Esc>a${BASH_ENV}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.BA&SH_VERSINFO   <Esc>a${BASH_VERSINFO}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.BAS&H_VERSION    <Esc>a${BASH_VERSION}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&CDPATH          <Esc>a${CDPATH}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.C&OLUMNS         <Esc>a${COLUMNS}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.CO&MPREPLY       <Esc>a${COMPREPLY}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COM&P_CWORD      <Esc>a${COMP_CWORD}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&LINE       <Esc>a${COMP_LINE}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_POI&NT      <Esc>a${COMP_POINT}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&WORDS      <Esc>a${COMP_WORDS}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&DIRSTACK        <Esc>a${DIRSTACK}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&EUID            <Esc>a${EUID}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&FCEDIT          <Esc>a${FCEDIT}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&IGNORE         <Esc>a${FIGNORE}
	 menu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&UNCNAME        <Esc>a${FUNCNAME}
	"
	amenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.<Tab>bash                                    <Esc>
	amenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.-Sep0-                         :
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE    <Esc>a${GLOBIGNORE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS        <Esc>a${GROUPS}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD       <Esc>a${HISTCMD}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL   <Esc>a${HISTCONTROL}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE      <Esc>a${HISTFILE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE  <Esc>a${HISTFILESIZE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE    <Esc>a${HISTIGNORE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE      <Esc>a${HISTSIZE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME          <Esc>a${HOME}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E      <Esc>a${HOSTFILE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME      <Esc>a${HOSTNAME}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE      <Esc>a${HOSTTYPE}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS           <Esc>a${IFS}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF     <Esc>a${IGNOREEOF}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C       <Esc>a${INPUTRC}
	 menu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG          <Esc>a${LANG}
	"
	amenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.<Tab>bash                                    <Esc>
	amenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.-Sep0-                         :
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          <Esc>a${LC_ALL}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      <Esc>a${LC_COLLATE}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        <Esc>a${LC_CTYPE}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     <Esc>a${LC_MESSAGES}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      <Esc>a${LC_NUMERIC}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          <Esc>a${LINENO}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           <Esc>a${LINES}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        <Esc>a${MACHTYPE}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            <Esc>a${MAIL}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       <Esc>a${MAILCHECK}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        <Esc>a${MAILPATH}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          <Esc>a${OLDPWD}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          <Esc>a${OPTARG}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          <Esc>a${OPTERR}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          <Esc>a${OPTIND}
	 menu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          <Esc>a${OSTYPE}
	"
	amenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.<Tab>bash                                    <Esc>
	amenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.-Sep0-                         :
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&PATH                 <Esc>a${PATH}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           <Esc>a${PIPESTATUS}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      <Esc>a${POSIXLY_CORRECT}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 <Esc>a${PPID}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       <Esc>a${PROMPT_COMMAND}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&1                  <Esc>a${PS1}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&2                  <Esc>a${PS2}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&3                  <Esc>a${PS3}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&4                  <Esc>a${PS4}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.P&WD                  <Esc>a${PWD}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               <Esc>a${RANDOM}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                <Esc>a${REPLY}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              <Esc>a${SECONDS}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.S&HELLOPTS            <Esc>a${SHELLOPTS}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                <Esc>a${SHLVL}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           <Esc>a${TIMEFORMAT}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                <Esc>a${TMOUT}
	 menu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&UID                  <Esc>a${UID}

	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&BASH            ${BASH}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.B&ASH_ENV        ${BASH_ENV}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.BA&SH_VERSINFO   ${BASH_VERSINFO}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.BAS&H_VERSION    ${BASH_VERSION}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&CDPATH          ${CDPATH}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.C&OLUMNS         ${COLUMNS}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.CO&MPREPLY       ${COMPREPLY}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COM&P_CWORD      ${COMP_CWORD}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&LINE       ${COMP_LINE}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_POI&NT      ${COMP_POINT}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.COMP_&WORDS      ${COMP_WORDS}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&DIRSTACK        ${DIRSTACK}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&EUID            ${EUID}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.&FCEDIT          ${FCEDIT}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&IGNORE         ${FIGNORE}
	imenu b&ash.E&nviron.&BASH\ \.\.\.\ FUNCNAME.F&UNCNAME        ${FUNCNAME}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&GLOBIGNORE    ${GLOBIGNORE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.GRO&UPS        ${GROUPS}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&HISTCMD       ${HISTCMD}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HI&STCONTROL   ${HISTCONTROL}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIS&TFILE      ${HISTFILE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HIST&FILESIZE  ${HISTFILESIZE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTIG&NORE    ${HISTIGNORE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HISTSI&ZE      ${HISTSIZE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.H&OME          ${HOME}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTFIL&E      ${HOSTFILE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTN&AME      ${HOSTNAME}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.HOSTT&YPE      ${HOSTTYPE}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&IFS           ${IFS}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.IGNO&REEOF     ${IGNOREEOF}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.INPUTR&C       ${INPUTRC}
	imenu b&ash.E&nviron.&GLOBIGNORE\ \.\.\.\ LANG.&LANG          ${LANG}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&LC_ALL          ${LC_ALL}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&COLLATE      ${LC_COLLATE}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_C&TYPE        ${LC_CTYPE}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_M&ESSAGES     ${LC_MESSAGES}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LC_&NUMERIC      ${LC_NUMERIC}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.L&INENO          ${LINENO}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.LINE&S           ${LINES}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&MACHTYPE        ${MACHTYPE}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.M&AIL            ${MAIL}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAILCHEC&K       ${MAILCHECK}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.MAIL&PATH        ${MAILPATH}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.&OLDPWD          ${OLDPWD}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTAR&G          ${OPTARG}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTER&R          ${OPTERR}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OPTIN&D          ${OPTIND}
	imenu b&ash.E&nviron.&LC_ALL\ \.\.\.\ OSTYPE.OST&YPE          ${OSTYPE}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&PATH                 ${PATH}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.P&IPESTATUS           ${PIPESTATUS}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.P&OSIXLY_CORRECT      ${POSIXLY_CORRECT}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PPI&D                 ${PPID}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PROMPT_&COMMAND       ${PROMPT_COMMAND}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&1                  ${PS1}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&2                  ${PS2}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&3                  ${PS3}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.PS&4                  ${PS4}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.P&WD                  ${PWD}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&RANDOM               ${RANDOM}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.REPL&Y                ${REPLY}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&SECONDS              ${SECONDS}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.S&HELLOPTS            ${SHELLOPTS}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.SH&LVL                ${SHLVL}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&TIMEFORMAT           ${TIMEFORMAT}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.T&MOUT                ${TMOUT}
	imenu b&ash.E&nviron.&PATH\ \.\.\.\ UID.&UID                  ${UID}

	"
	"-------------------------------------------------------------------------------
	" Builtins
	"-------------------------------------------------------------------------------
	"
	amenu b&ash.B&uiltins.<Tab>bash                                    <Esc>
	amenu b&ash.B&uiltins.-Sep0-                         :

	 menu b&ash.B&uiltins.&cd         <Esc>acd<Space>
	 menu b&ash.B&uiltins.&echo       <Esc>aecho<Space>
	 menu b&ash.B&uiltins.e&val       <Esc>aeval<Space>
	 menu b&ash.B&uiltins.e&xec       <Esc>aexec<Space>
	 menu b&ash.B&uiltins.ex&port     <Esc>aexport<Space>
	 menu b&ash.B&uiltins.&getopts    <Esc>agetopts<Space>
	 menu b&ash.B&uiltins.&hash       <Esc>ahash<Space>
	 menu b&ash.B&uiltins.&newgrp     <Esc>anewgrp<Space>
	 menu b&ash.B&uiltins.p&wd        <Esc>apwd<Space>
	 menu b&ash.B&uiltins.&read       <Esc>aread<Space>
	 menu b&ash.B&uiltins.read&only   <Esc>areadonly<Space>
	 menu b&ash.B&uiltins.ret&urn     <Esc>areturn<Space>
	 menu b&ash.B&uiltins.&times      <Esc>atimes<Space>
	 menu b&ash.B&uiltins.t&ype       <Esc>atype<Space>
	 menu b&ash.B&uiltins.u&mask      <Esc>aumask<Space>
	 menu b&ash.B&uiltins.w&ait       <Esc>await<Space>
	"
	imenu b&ash.B&uiltins.&cd         cd<Space>
	imenu b&ash.B&uiltins.&echo       echo<Space>
	imenu b&ash.B&uiltins.e&val       eval<Space>
	imenu b&ash.B&uiltins.e&xec       exec<Space>
	imenu b&ash.B&uiltins.ex&port     export<Space>
	imenu b&ash.B&uiltins.&getopts    getopts<Space>
	imenu b&ash.B&uiltins.&hash       hash<Space>
	imenu b&ash.B&uiltins.&newgrp     newgrp<Space>
	imenu b&ash.B&uiltins.p&wd        pwd<Space>
	imenu b&ash.B&uiltins.&read       read<Space>
	imenu b&ash.B&uiltins.read&only   readonly<Space>
	imenu b&ash.B&uiltins.ret&urn     return<Space>
	imenu b&ash.B&uiltins.&times      times<Space>
	imenu b&ash.B&uiltins.t&ype       type<Space>
	imenu b&ash.B&uiltins.u&mask      umask<Space>
	imenu b&ash.B&uiltins.w&ait       wait<Space>
	"
	amenu b&ash.S&et.<Tab>bash                                    <Esc>
	amenu b&ash.S&et.-Sep0-                         :

	 menu b&ash.S&et.set																															<Esc>aset<Space>
	 menu b&ash.S&et.unset 																													<Esc>aunset<Space>
	 menu b&ash.S&et.mark\ modified\ or\ modified\ variables													<Esc>aset -o allexport
	 menu b&ash.S&et.exit\ when\ command\ returns\ non-zero\ exit\ code							<Esc>aset -o errexit
	 menu b&ash.S&et.Disable\ file\ name\ generation																	<Esc>aset -o noglob
	 menu b&ash.S&et.remember\ (hash)\ commands																			<Esc>aset -o hashall
	 menu b&ash.S&et.All\ keyword\ arguments\ are\ placed\ in\ the\ environment			<Esc>aset -o keyword
	 menu b&ash.S&et.Read\ commands\ but\ do\ not\ execute\ them											<Esc>aset -o noexec
	 menu b&ash.S&et.Script\ is\ running\ in\ SUID\ mode             								<Esc>aset -o privileged
	 menu b&ash.S&et.Exit\ after\ reading\ and\ executing\ one\ command							<Esc>aset -o onecmd
	 menu b&ash.S&et.Treat\ undefined\ variables\ as\ errors\ not\ as\ null					<Esc>aset -o nounset
	 menu b&ash.S&et.Print\ shell\ input\ lines\ before\ running\ them								<Esc>aset -o verbose
	 menu b&ash.S&et.Print\ commands\ (after\ expansion)\ before\ running\ them			<Esc>aset -o xtrace
	"            &
	imenu b&ash.S&et.set																															set<Space>
	imenu b&ash.S&et.unset 																													unset<Space>
	imenu b&ash.S&et.mark\ modified\ or\ modified\ variables													set -o allexport
	imenu b&ash.S&et.exit\ when\ command\ returns\ non-zero\ exit\ code							set -o errexit
	imenu b&ash.S&et.Disable\ file\ name\ generation																	set -o noglob
	imenu b&ash.S&et.remember\ (hash)\ commands																			set -o hashall
	imenu b&ash.S&et.All\ keyword\ arguments\ are\ placed\ in\ the\ environment			set -o keyword
	imenu b&ash.S&et.Read\ commands\ but\ do\ not\ execute\ them											set -o noexec
	imenu b&ash.S&et.Script\ is\ running\ in\ SUID\ mode             								set -o privileged
	imenu b&ash.S&et.Exit\ after\ reading\ and\ executing\ one\ command							set -o onecmd
	imenu b&ash.S&et.Treat\ undefined\ variables\ as\ errors\ not\ as\ null					set -o nounset
	imenu b&ash.S&et.Print\ shell\ input\ lines\ before\ running\ them								set -o verbose
	imenu b&ash.S&et.Print\ commands\ (after\ expansion)\ before\ running\ them			set -o xtrace
	"
	"-------------------------------------------------------------------------------
	" I/O redirection
	"-------------------------------------------------------------------------------
	" 
	amenu b&ash.&I/O-Redir.<Tab>bash                                    <Esc>
	amenu b&ash.&I/O-Redir.-Sep0-                         :

	 menu b&ash.&I/O-Redir.take\ standard\ input\ from\ file												<Esc>a<Space><<Space><ESC>a
	 menu b&ash.&I/O-Redir.direct\ standard\ output\ to\ file												<Esc>a<Space>><Space><ESC>a
	 menu b&ash.&I/O-Redir.direct\ standard\ output\ to\ file;\ append							<Esc>a<Space>>><Space><ESC>a
	"
	 menu b&ash.&I/O-Redir.direct\ file\ descriptor\ to\ file												<Esc>a<Space>><Space><ESC>2hi
	 menu b&ash.&I/O-Redir.direct\ file\ descriptor\ to\ file;\ append							<Esc>a<Space>>><Space><ESC>2hi
	 menu b&ash.&I/O-Redir.take\ file\ descriptor\ from\ file												<Esc>a<Space><<Space><ESC>2hi
	"
	 menu b&ash.&I/O-Redir.duplicate\ standard\ input\ from\ file\ descriptor				<Esc>a<Space><& <ESC>a
	 menu b&ash.&I/O-Redir.duplicate\ standard\ output\ to\ file\ descriptor				<Esc>a<Space>>& <ESC>a
	 menu b&ash.&I/O-Redir.direct\ standard\ output\ and\ standard\ error\ to\ file	<Esc>a<Space>&> <ESC>a
	"
	 menu b&ash.&I/O-Redir.close\ the\ standard\ input															<Esc>a<Space><&- <ESC>a
	 menu b&ash.&I/O-Redir.close\ the\ standard\ output															<Esc>a<Space>>&- <ESC>a
	 menu b&ash.&I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n							<Esc>a<Space><&- <ESC>3hi
	 menu b&ash.&I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n						<Esc>a<Space>>&- <ESC>3hi
	"
	 menu b&ash.&I/O-Redir.here-document			<Esc>a<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki
	" 
	imenu b&ash.&I/O-Redir.take\ standard\ input\ from\ file												<Space><<Space><ESC>a
	imenu b&ash.&I/O-Redir.direct\ standard\ output\ to\ file												<Space>><Space><ESC>a
	imenu b&ash.&I/O-Redir.direct\ standard\ output\ to\ file;\ append							<Space>>><Space><ESC>a
	"
	imenu b&ash.&I/O-Redir.direct\ file\ descriptor\ to\ file												<Space>><Space><ESC>2hi
	imenu b&ash.&I/O-Redir.direct\ file\ descriptor\ to\ file;\ append							<Space>>><Space><ESC>2hi
	imenu b&ash.&I/O-Redir.take\ file\ descriptor\ from\ file												<Space><<Space><ESC>2hi
	"
	imenu b&ash.&I/O-Redir.duplicate\ standard\ input\ from\ file\ descriptor				<Space><& <ESC>a
	imenu b&ash.&I/O-Redir.duplicate\ standard\ output\ to\ file\ descriptor				<Space>>& <ESC>a
	imenu b&ash.&I/O-Redir.direct\ standard\ output\ and\ standard\ error\ to\ file	<Space>&> <ESC>a
	"
	imenu b&ash.&I/O-Redir.close\ the\ standard\ input															<Space><&- <ESC>a
	imenu b&ash.&I/O-Redir.close\ the\ standard\ output															<Space>>&- <ESC>a
	imenu b&ash.&I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n							<Space><&- <ESC>3hi
	imenu b&ash.&I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n						<Space>>&- <ESC>3hi
	"
	imenu b&ash.&I/O-Redir.here-document			<< EOF<CR><CR>EOF<CR># ===== end of here-document =====<ESC>2ki
	"
	"------------------------------------------------------------------------------
	"  Run Script
	"------------------------------------------------------------------------------
	"
	"   run the script from the local directory 
	"   ( the one in the current buffer ; other versions may exist elsewhere ! )
	" 
	amenu b&ash.&Run.<Tab>bash                                    <Esc>
	amenu b&ash.&Run.-Sep0-                         :

	amenu b&ash.&Run.update\ file\ and\ &run\ script<Tab><Ctrl><F9>    <C-C>:call BASH_Run()<CR>
	"
	"   set execution right only for the user ( may be user root ! )
	"
	amenu <silent> b&ash.&Run.make\ script\ e&xecutable                      <C-C>:!chmod -c u+x %<CR>
	amenu <silent> b&ash.&Run.command\ line\ &arguments                      <C-C>:call BASH_Arguments()<CR>
	amenu          b&ash.&Run.-Sep1-                                         :
	amenu <silent> b&ash.&Run.&hardcopy\ all\ to\ FILENAME\.ps               <C-C>:call BASH_Hardcopy("n")<CR>
	vmenu <silent> b&ash.&Run.hard&copy\ part\ to\ FILENAME\.ps              <C-C>:call BASH_Hardcopy("v")<CR>
	imenu          b&ash.&Run.-SEP2-                                         :
	amenu <silent> b&ash.&Run.&settings                                      <C-C>:call BASH_Settings()<CR>
	"
endif

endfunction			" function Bash_InitMenu
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
				:execute ":write! ".l:snippetfile
			endif
		endif
		"
		" write marked area into snippet file 
		" 
		if a:arg1 == "wv"
			let	l:snippetfile=browse(0,"write a code snippet",s:BASH_CodeSnippets,"")
			if l:snippetfile != ""
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
	let settings = settings."author name  :  ".s:BASH_AuthorName."\n"
	let settings = settings."author ref  :  ".s:BASH_AuthorRef."\n"
	let settings = settings."autho  email  :  ".s:BASH_Email."\n"
	let settings = settings."company  :  ".s:BASH_Company."\n"
	let settings = settings."project  :  ".s:BASH_Project."\n"
	let settings = settings."copyright holder  :  ".s:BASH_CopyrightHolder."\n"
	let settings = settings."code snippet directory  :  ".s:BASH_CodeSnippets."\n"
	let settings = settings."template directory  :  ".s:BASH_Template_Directory."\n"
	if exists("g:BASH_Dictionary_File")
		let settings = settings."dictionary file  :  ".g:BASH_Dictionary_File."\n"
	endif
let settings = settings."pager  :  ".s:BASH_Pager."\n"
	let settings = settings."\n"
	let	settings = settings."----------------------------------------------------------------------------------------\n"
	let	settings = settings."Bash-Support, Version ".s:BASH_Version."  /  Dr.-Ing. Fritz Mehner  /  mehner@fh-swf.de\n"
	let dummy=confirm( settings, "ok", 1, "Info" )
endfunction
"
"
"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
let s:BASH_Active = -1														" state variable controlling the Bash-menus
let s:BASH_CmdLineArgs  = ""           " command line arguments for Run-run; initially empty

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
			aunmenu bash
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
nmap    <silent>  <Leader>lbs             :call Bash_Handle()<CR>
nmap    <silent>  <Leader>ubs             :call Bash_Handle()<CR>
"
"------------------------------------------------------------------------------
"  vim: set tabstop=2: set shiftwidth=2: 
