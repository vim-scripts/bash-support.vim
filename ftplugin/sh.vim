" Vim filetype plugin file
"
" Language   :  bash
" Plugin     :  bash-support.vim
" Maintainer :  Fritz Mehner <mehner@fh-swf.de>
" Last Change:  26.11.2004
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
 map  <buffer>            <C-F9>        <C-C>:call BASH_Run()<CR>
imap  <buffer>            <C-F9>   <C-C><C-C>:call BASH_Run()<CR>
"
 map  <buffer>  <silent>  <S-F9>             :call BASH_Arguments()<CR>
imap  <buffer>  <silent>  <S-F9>        <Esc>:call BASH_Arguments()<CR>
"
"
" ---------- Key mappings  -------------------------------------
"
nmap  <buffer>  <silent>  <Leader>cl      <Tab><Tab><Tab>#<Space>
vmap  <buffer>  <silent>  <Leader>cl      <Esc><Esc>:call BASH_MultiLineEndComments()<CR>
nmap  <buffer>  <silent>  <Leader>cf      :call BASH_CommentTemplates('frame')<CR>
nmap  <buffer>  <silent>  <Leader>cu      :call BASH_CommentTemplates('function')<CR>
nmap  <buffer>  <silent>  <Leader>ch      :call BASH_CommentTemplates('header')<CR>
vmap  <buffer>  <silent>  <Leader>cc      <Esc><Esc>:'<,'>s/^/#/<CR><Esc>:nohlsearch<CR>
vmap  <buffer>  <silent>  <Leader>co      <Esc><Esc>:'<,'>s/^#//<CR><Esc>:nohlsearch<CR>
nmap  <buffer>  <silent>  <Leader>cd      i<C-R>=strftime("%x")<CR>
nmap  <buffer>  <silent>  <Leader>ct      i<C-R>=strftime("%x %X %Z")<CR>
nmap  <buffer>  <silent>  <Leader>ckb     $<Esc>:call BASH_CommentClassified("BUG")     <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckt     $<Esc>:call BASH_CommentClassified("TODO")    <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckr     $<Esc>:call BASH_CommentClassified("TRICKY")  <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckw     $<Esc>:call BASH_CommentClassified("WARNING") <CR>kJA
nmap  <buffer>  <silent>  <Leader>ckn     $<Esc>:call BASH_CommentClassified("")        <CR>kJf:a
nmap  <buffer>  <silent>  <Leader>cv      :call BASH_CommentVimModeline()<CR>

nmap  <buffer>  <silent>  <Leader>ac      ocase  in<CR>)<CR>;;<CR><CR>)<CR>;;<CR><CR>*)<CR>;;<CR><CR>esac    # --- end of case ---<CR><Esc>11kf<Space>a
nmap  <buffer>  <silent>  <Leader>ae      oif <CR>then<CR>else<CR>fi<Esc>3kA
nmap  <buffer>  <silent>  <Leader>af      ofor  in <CR>do<CR>done<Esc>2k^f<Space>a
nmap  <buffer>  <silent>  <Leader>ai      oif <CR>then<CR>fi<Esc>2k^A
nmap  <buffer>  <silent>  <Leader>al      oelif <CR>then<Esc>1kA
nmap  <buffer>  <silent>  <Leader>as      oselect  in <CR>do<CR>done<Esc>2kf a
nmap  <buffer>  <silent>  <Leader>at      ountil <CR>do<CR>done<Esc>2kA
nmap  <buffer>  <silent>  <Leader>aw      owhile <CR>do<CR>done<Esc>2kA

vmap  <buffer>  <silent>  <Leader>ae      DOif <CR>then<CR>else<CR>fi<Esc>kP<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>2kA
vmap  <buffer>  <silent>  <Leader>af      DOfor  in <CR>do<CR>done<Esc>P2k^<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f<Space>a
vmap  <buffer>  <silent>  <Leader>ai      DOif <CR>then<CR>fi<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A
vmap  <buffer>  <silent>  <Leader>as      DOselect  in <CR>do<CR>done<Esc>P2k^<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>f<Space>a
vmap  <buffer>  <silent>  <Leader>at      DOuntil <CR>do<CR>done<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A
vmap  <buffer>  <silent>  <Leader>aw      DOwhile <CR>do<CR>done<Esc>P2k<Esc>:exe "normal =".(line("'>")-line(".")-1)."+"<CR>A

nmap  <buffer>  <silent>  <Leader>ao      ^iecho<Space>"<Esc>$a"<Esc>j
vmap  <buffer>  <silent>  <Leader>ao      secho<Space>""<Esc>P
nmap  <buffer>  <silent>  <Leader>av      0:s/echo\s\+\"// \| s/\s*\"\s*$//<CR><Esc>j

if !has('win32')
	nmap  <buffer>  <silent>  <Leader>re      <Esc>:!chmod -c u+x %<CR>
endif
 map  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("n")<CR>
vmap  <buffer>  <silent>  <Leader>rh      <Esc>:call BASH_Hardcopy("v")<CR>

