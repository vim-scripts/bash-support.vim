"###############################################################################################
"
"     Filename:  bash-support.vim
"
"  Description:  BASH support     (VIM Version 6.0+)
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
"         Note:  The register z is used in some places.
"
"       Credit:  Lennart Schultz, les@dmi.min.dk 
"                The file shellmenu.vim in the macro directory of the 
"                vim standard distribution was my starting point.
"
let s:BASH_Version = "1.3"              " version number of this script; do not change
"     Revision:  07.08.2002
"      Created:  26.02.2001
"###############################################################################################
"
"  Configuration  (use my configuration as an example)
"
let s:BASH_AuthorName      = "Dr.-Ing. Fritz Mehner"
let s:BASH_AuthorRef       = "Mn"
let s:BASH_Email           = "mehner@fh-swf.de"
let s:BASH_Company         = "FH Südwestfalen, Iserlohn"
"
"  Copyright information
"  ---------------------
"  If the code has been developed over a period of years, each year must be stated.
"  If BASH_CopyrightHolder is empty the copyright notice will not appear.
"  If BASH_CopyrightHolder is not empty and BASH_CopyrightYears is empty, 
"  the current year will be inserted.
"
let s:BASH_CopyrightHolder = ""
let s:BASH_CopyrightYears  = ""
"
let s:BASH_ShowMenues     = "no"										" show menues immediately after loading (yes/no)
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
map    <C-F9>  :update<CR><Esc>:!./%<CR>
"
"-------------------------------------------------------------------------------------
"
amenu &Comments.&Line\ End\ Comment           <Esc><Esc>A<Tab><Tab><Tab># 
amenu &Comments.&Frame\ Comment               <Esc><Esc>:call BASH_CommentFrame()<CR>jA
amenu &Comments.F&unction\ Description        <Esc><Esc>:call BASH_CommentFunction()<CR>:/NAME<CR>A
amenu &Comments.File\ &Prologue               <Esc><Esc>:call BASH_FilePrologue()<CR>:/DESCRIPTION<CR>A
amenu &Comments.-Sep1-                         :
vmenu &Comments.&code->comment                <Esc><Esc>:'<,'>s/^/\#/<CR><Esc>:nohlsearch<CR>
vmenu &Comments.c&omment->code                <Esc><Esc>:'<,'>s/^\#//<CR><Esc>:nohlsearch<CR>
amenu &Comments.-SEP2-                        :
amenu &Comments.&Date                         <Esc><Esc>:let @z=strftime("%x")<CR>"zpa
amenu &Comments.Date\ &Time                   <Esc><Esc>:let @z=strftime("%x - %X")<CR>"zpa
amenu &Comments.-SEP3-                        :
amenu &Comments.\#\ \:&KEYWORD\:.&BUG               <Esc><Esc>$<Esc>:call BASH_CommentClassified("BUG")     <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.&TODO              <Esc><Esc>$<Esc>:call BASH_CommentClassified("TODO")    <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.T&RICKY            <Esc><Esc>$<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.&WARNING           <Esc><Esc>$<Esc>:call BASH_CommentClassified("WARNING") <CR>kgJA
amenu &Comments.\#\ \:&KEYWORD\:.&new\ keyword      <Esc><Esc>$<Esc>:call BASH_CommentClassified("")        <CR>kgJf:a
"
imenu St&mts.&for									for  in do	done<ESC>3k0ela
imenu St&mts.&case								case  in) ;;) ;;*) ;;esac    # --- end of case ---<ESC>11k0whi
imenu St&mts.&if									if  then	fi<ESC>3k0ela
imenu St&mts.if-&else							if  then	else	fi<ESC>5k0ela
imenu St&mts.e&lif								elif  	then<ESC>4k0ela
imenu St&mts.&select							select  in dobreak;done<ESC>4k0ela
imenu St&mts.&while								while  do	done<ESC>3k0ela
imenu St&mts.&break								break 
imenu St&mts.c&ontinue						continue 
imenu St&mts.f&unction						<Esc>:call BASH_CodeFunction()<CR>2jA
imenu St&mts.&return							return 
imenu St&mts.return\ &0\ (true)		return 0
imenu St&mts.return\ &1\ (false)	return 1
imenu St&mts.e&xit								exit 
imenu St&mts.s&hift								shift 
imenu St&mts.&trap								trap 
"
"-------------------------------------------------------------------------------
" file tests
"-------------------------------------------------------------------------------
" 
imenu Test.file\ &exists																											[ -e  ]<Esc>hi
imenu Test.file\ exists\ and\ has\ a\ size\ greater\ than\ &zero							[ -s  ]<Esc>hi
imenu Test.-Sep1-                         :
	"
	"---------- submenu arithmetic tests -----------------------------------------------------------
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
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &readable									[ -r  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ &writable									[ -w  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ is\ e&xecutable								[ -x  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&UID-bit\ is\ set				[ -u  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ S&GID-bit\ is\ set				[ -g  ]<Esc>hi
	imenu Test.file\ exists\ and\ has\ &permission.file\ exists\ and\ its\ "&sticky"\ bit\ is\ set	[ -k  ]<Esc>hi
	"
	"---------- submenu file exists and has type ----------------------------------------------------
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
	imenu Test.&string\ comparison.length\ of\ string\ is\ &zero											[ -z  ]<Esc>hi
	imenu Test.&string\ comparison.length\ of\ string\ is\ n&on-zero									[ -n  ]<Esc>hi
	imenu Test.&string\ comparison.strings\ are\ &equal																[  ==  ]<Esc>F[la
	imenu Test.&string\ comparison.strings\ are\ &not\ equal													[  !=  ]<Esc>F[la
	imenu Test.&string\ comparison.string1\ sorts\ &before\ string2\ lexicograph\.		[  <  ]<Esc>F[la
	imenu Test.&string\ comparison.string1\ sorts\ &after\ string2\ lexicographically	[  >  ]<Esc>F[la
	"
imenu Test.-Sep2-                         :
imenu Test.file\ exists\ and\ is\ owned\ by\ the\ effective\ &UID								[ -O  ]<Esc>hi
imenu Test.file\ exists\ and\ is\ owned\ by\ the\ effective\ &GID								[ -G  ]<Esc>hi
imenu Test.file\ exists\ and\ has\ been\ &modified\ since\ it\ was\ last\ read	[ -N  ]<Esc>hi
imenu Test.file\ &descriptor\ fd\ is\ open\ and\ refers\ to\ a\ terminal				[ -t  ]<Esc>hi
imenu Test.-Sep3-                         :
imenu Test.file1\ is\ &newer\ than\ file2\ (modification\ date)									[  -nt  ]<Esc>F[la
imenu Test.file1\ is\ &older\ than\ file2																				[  -ot  ]<Esc>F[la
imenu Test.file1\ and\ file2\ have\ the\ same\ device\ and\ &inode\ numbers			[  -ef  ]<Esc>F[la
imenu Test.-Sep4-                         :
imenu Test.she&ll\ option\ optname\ is\ enabled									[ -o  ]<Esc>hi
"
"-------------------------------------------------------------------------------
" parameter substitution
"-------------------------------------------------------------------------------
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
imenu Spec&Vars.Number\ of\ positional\ parameters							${#}
imenu Spec&Vars.All\ positional\ parameters\ (quoted\ spaces)		${*}
imenu Spec&Vars.All\ positional\ parameters\ (unquoted\ spaces)	${@}
imenu Spec&Vars.Flags\ set																			${-}
imenu Spec&Vars.Return\ code\ of\ last\ command									${?}
imenu Spec&Vars.Process\ number\ of\ this\ shell								${$}
imenu Spec&Vars.Process\ number\ of\ last\ background\ command	${!}
"
imenu E&nviron.&HOME				${HOME}
imenu E&nviron.&PATH				${PATH}
imenu E&nviron.&CDPATH			${CDPATH}
imenu E&nviron.&MAIL				${MAIL}
imenu E&nviron.MAI&LCHECK		${MAILCHECK}
imenu E&nviron.PS&1					${PS1}
imenu E&nviron.PS&2					${PS2}
imenu E&nviron.&IFS					${IFS}
imenu E&nviron.SH&ACCT			${SHACCT}
imenu E&nviron.&SHELL				${SHELL}
imenu E&nviron.LC_CT&YPE		${LC_CTYPE}
imenu E&nviron.LC_M&ESSAGES	${LC_MESSAGES}
"
imenu B&uiltins.&cd         cd
imenu B&uiltins.&echo       echo
imenu B&uiltins.e&val       eval
imenu B&uiltins.e&xec       exec
imenu B&uiltins.ex&port     export
imenu B&uiltins.&getopts    getopts
imenu B&uiltins.&hash       hash
imenu B&uiltins.&newgrp     newgrp
imenu B&uiltins.p&wd        pwd
imenu B&uiltins.&read       read
imenu B&uiltins.read&only   readonly
imenu B&uiltins.ret&urn     return
imenu B&uiltins.&times      times
imenu B&uiltins.t&ype       type
imenu B&uiltins.u&mask      umask
imenu B&uiltins.w&ait       wait
"
imenu Set.set																															set
imenu Set.unset 																													unset
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
imenu &I/O-Redir.take\ standard\ input\ from\ file												 < <ESC>a
imenu &I/O-Redir.direct\ standard\ output\ to\ file												 > <ESC>a
imenu &I/O-Redir.direct\ standard\ output\ to\ file;\ append							 >> <ESC>a
"
imenu &I/O-Redir.direct\ file\ descriptor\ to\ file												 > <ESC>2hi
imenu &I/O-Redir.direct\ file\ descriptor\ to\ file;\ append							 >> <ESC>2hi
imenu &I/O-Redir.take\ file\ descriptor\ from\ file												 < <ESC>2hi
"
imenu &I/O-Redir.duplicate\ standard\ input\ from\ file\ descriptor				 <& <ESC>a
imenu &I/O-Redir.duplicate\ standard\ output\ to\ file\ descriptor				 >& <ESC>a
imenu &I/O-Redir.direct\ standard\ output\ and\ standard\ error\ to\ file	 &> <ESC>a
"
imenu &I/O-Redir.close\ the\ standard\ input															 <&- <ESC>a
imenu &I/O-Redir.close\ the\ standard\ output															 >&- <ESC>a
imenu &I/O-Redir.close\ the\ input\ from\ file\ descriptor\ n							 <&- <ESC>3hi
imenu &I/O-Redir.close\ the\ output\ from\ file\ descriptor\ n						 >&- <ESC>3hi
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
amenu &Run.update\ file\ and\ &run\ script\ <Ctrl><F9>    <Esc>:update<CR><Esc>:!./%<CR>
"
"   set execution right only for the user ( may be user root ! )
"
amenu &Run.make\ script\ &executable                      <Esc>:!chmod u+x %<CR>
amenu &Run.a&bout\ BASH-Support                           <C-C>:call BASH_Version()<CR>
"
endfunction			" function Bash_InitMenu
"
"------------------------------------------------------------------------------
"  Comments : frame comment
"------------------------------------------------------------------------------
function! BASH_CommentFrame ()
  let @z=   "#----------------------------------------------------------------------\n"
  let @z=@z."#  \n"
  let @z=@z."#----------------------------------------------------------------------\n"
  put z
endfunction
"

"------------------------------------------------------------------------------
"  Comments : function
"------------------------------------------------------------------------------
function! BASH_CommentFunction ()
  let @z=    "#===  FUNCTION  ======================================================================\n"
  let @z= @z."#\n"
  let @z= @z."#         NAME:  \n"
  let @z= @z."#\n"
  let @z= @z."#  DESCRIPTION:  \n"
  let @z= @z."#\n"
  let @z= @z."#       AUTHOR:  ".s:BASH_AuthorName."\n"
  let @z= @z."#      CREATED:  ".strftime("%x - %X")."\n"
  let @z= @z."#     REVISION:  ---\n"
  let @z= @z."#\n"
  let @z= @z."#---- PARAMETER  ---------------------------------------------------------------------\n"
  let @z= @z."#        Number  Description\n"
  let @z= @z."#           1 :  \n"
  let @z= @z."#=====================================================================================\n"
  put z
endfunction
"
"------------------------------------------------------------------------------
"  Comments : file prologue
"------------------------------------------------------------------------------
function! BASH_FilePrologue ()

		let	File	= expand("%:t")				" name of the file in the current buffer without path
    let @z=    "#!/bin/bash\n"
    let @z= @z."#=====================================================================================\n"
    let @z= @z."#\n"
    let @z= @z."#         FILE:  ".File."\n"
    let @z= @z."#\n"
    let @z= @z."#        USAGE:  ./".File." \n"
    let @z= @z."#\n"
    let @z= @z."#  DESCRIPTION:  \n"
    let @z= @z."#\n"
    let @z= @z."#        FILES:  ---\n"
    let @z= @z."#        NOTES:  ---\n"
    let @z= @z."#       AUTHOR:  ".s:BASH_AuthorName."\n"
  if(s:BASH_Email!="")
    let @z= @z."#        EMAIL:  ".s:BASH_Email."\n"
	endif
  if(s:BASH_Company!="")
    let @z= @z."#      COMPANY:  ".s:BASH_Company."\n"
	endif
  if(s:BASH_CopyrightHolder!="")
    let @z= @z.  "\n//#  COPYRIGHT:  ".s:BASH_CopyrightHolder
    if(s:BASH_CopyrightYears=="")
      let @z= @z. " , ". strftime("%Y")
    else
      let @z= @z. " , ". s:BASH_CopyrightYears
    endif
  endif
    let @z= @z."#      VERSION:  1.0\n"
    let @z= @z."#      CREATED:  ".strftime("%x - %X")."\n"
    let @z= @z."#     REVISION:  ---\n"
    let @z= @z."#=====================================================================================\n"
    let @z= @z."\n\n"
    
    put! z
endfunction
"
"------------------------------------------------------------------------------
"  Comments : classified comments
"------------------------------------------------------------------------------
function! BASH_CommentClassified (class)
  	put = '			# :'.a:class.':'.strftime(\"%x\").':'.s:BASH_AuthorRef.': '
endfunction
"
"------------------------------------------------------------------------------
"  Stmts : function
"------------------------------------------------------------------------------
function! BASH_CodeFunction ()
	let	identifier=inputdialog("function name", "f" )
	if identifier != ""
		let @z=    "function ".identifier." ()\n{\n\t\n}"
		let @z= @z."    # ----------  end of function ".identifier."  ----------"
		put z
	endif
endfunction
"
"------------------------------------------------------------------------------
"  Run : about
"------------------------------------------------------------------------------
function! BASH_Version ()
	let dummy=confirm("BASH-Support, Version ".s:BASH_Version."\nDr. Fritz Mehner\nmehner@fh-swf.de", "ok" )
endfunction
"
"------------------------------------------------------------------------------
"	 Create the load/unload entry in the GVIM tool menu, depending on 
"	 which script is already loaded
"------------------------------------------------------------------------------
"
let s:Bash_Active = -1														" state variable controlling the C-menus
"
function! Bash_CreateUnLoadMenuEntries ()
"
	" Bash is now active and was former inactive -> 
	" Insert Tools.Unload and remove Tools.Load Menu
	if  s:Bash_Active == 1
		aunmenu Tools.Load\ Bash\ Support
		amenu   &Tools.Unload\ Bash\ Support  	<C-C>:call Bash_Handle()<CR>
	else
		" Bash is now inactive and was former active or in initial state -1 
		if s:Bash_Active == 0
			" Remove Tools.Unload if Bash was former inactive
			aunmenu Tools.Unload\ Bash\ Support
		else
			" Set initial state Bash_Active=-1 to inactive state Bash_Active=0
			" This protects from removing Tools.Unload during initialization after
			" loading this script
			let s:Bash_Active = 0
			" Insert Tools.Load
		endif
		amenu &Tools.Load\ Bash\ Support <C-C>:call Bash_Handle()<CR>
	endif
	"
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

