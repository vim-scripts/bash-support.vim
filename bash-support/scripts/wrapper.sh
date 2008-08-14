#!/bin/bash
#===============================================================================
#          FILE:  wrapper.sh
#         USAGE:  ./wrapper.sh scriptname [cmd-line-args] 
#   DESCRIPTION:  Wraps the execution of a programm or script.
#                 Use with xterm: xterm -e wrapper.sh scriptname cmd-line-args
#                 This script is used by several plugins:
#                  bash-support.vim, c.vim and perl-support.vim
#       OPTIONS:  ---
#  REQUIREMENTS:  which(1) - shows the full path of (shell) commands.
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#       COMPANY:  Fachhochschule Südwestfalen, Iserlohn
#       CREATED:  23.11.2004 18:04:01 CET
#      REVISION:  $Id: wrapper.sh,v 1.4 2008/08/02 15:50:55 mehner Exp $
#===============================================================================

command=${@}                                    # the complete command line
scriptname=${1}                                 # name of the scriptname; may be quoted

fullname=$(which $scriptname 2>/dev/null)
[ $? -eq 0 ] && scriptname=$fullname

if [ ${#} -ge 1 ] ; then
	shift
	if [ -x "$scriptname" ] ; then                # start an executable script
		"$scriptname" ${@}
	else
		$SHELL "$scriptname" ${@}                   # start a script which is not executable
	fi
	echo -e "\"${command}\" returned ${?}"
else
  echo -e "\n  !! ${0} : missing argument for wrapper script !!"
fi

read -p "  ... press return key ... " dummy
