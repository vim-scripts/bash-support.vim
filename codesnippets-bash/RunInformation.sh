
CommandLineParameter="$*"                       # save command line parameter

#-------------------------------------------------------------------------------
#   echo run information
#-------------------------------------------------------------------------------
function RunInformation ()
{
  echo -e "   Script: '$0'"
  echo -e "  Started: $(date)"
  echo -e "Parameter: ${CommandLineParameter}\n"
}    # ----------  end of function RunInformation  ----------

RunInformation

