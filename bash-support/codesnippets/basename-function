#===  FUNCTION  ================================================================
#          NAME:  Basename
#   DESCRIPTION:  Replacement for basename(1) .
#    PARAMETERS:  NAME [SUFFIX]
#       RETURNS:  Print NAME with any leading directory components removed.
#===============================================================================
function Basename ()
{
  local base=${1##*/} 
  echo  ${base%$2}
}    # ----------  end of function Basename  ----------
