
CommandLineParameter="$*"

function RunInformation ()
{
  echo "\"$0\"  started $(date)"
  echo "Command line parameter(s) : ${CommandLineParameter}"
}    # ----------  end of function RunInformation  ----------

RunInformation

