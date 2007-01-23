#===  FUNCTION  ================================================================
#          NAME:  assert
#   DESCRIPTION:  Abort the script if assertion is false.
#    PARAMETERS:  expression     : assertion
#                 [linenumber]   : use $LINENO
#                 [functionname] : use $FUNCNAME
#       RETURNS:  99             : exit error status 
#===============================================================================
function assert ()
{
  if [ ! $1 ] 
  then
    local linenumber=""
    local functionname=""
    [ -n "$2" ] && linenumber=": line $2"
    [ -n "$3" ] && functionname=": function '$3'"
    echo "File '$0' $linenumber$functionname: assertion '$1' failed."
    exit 99
  fi  
}    
