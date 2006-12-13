#===  FUNCTION  ================================================================
#          NAME:  assert
#   DESCRIPTION:  abort the script if assertion is false
#    PARAMETERS:  expression    (assertion)
#                 linenumber	  (optional; use $LINENO)
#                 functionname	(optional; use $FUNCNAME)
#       RETURNS:  99  : exit error status 
#===============================================================================
function assert ()
{
  if [ ! $1 ] 
  then
		lineno=""
		[ -n "$2" ] && lineno=": line $2"
		fnctn=""
		[ -n "$3" ] && fnctn=": function '$3'"
    echo "File '$0' $lineno$fnctn: assertion '$1' failed."
    exit 99
  fi  
}    
