# TODO: this is pasted from xc-windows.git/do_build.ps1 but I would like to find a way

# to share code. For now if you fix a bug here please fix it in that version

# as well.



# run a command with output redirection so that we wait

# and check the error code and fail if non-zero

function Invoke-CommandChecked {
  Write-Host ("Invoke "+([string]$args))
  $description = $args[0]
  $command = $args[1]
  # doing "& *args" now would be good if it didn't take all the arguments and turn 
  # it into a string and try and run that. We need to specify the command name separately.
  # we cannot remove items from arrays
  # see http://technet.microsoft.com/en-us/library/ee692802.aspx
  # so we turn the args into an arraylist instead
  $arglist = New-Object System.Collections.ArrayList
  $arglist.AddRange($args)
  # ... then remove the first two argument
  $arglist.RemoveRange(0,2)
  # Quote the command arguments if not done so by invoker
  Quote-CommandArguments -arguments $arglist
  Write-Host ("+$command "+[string]$arglist)
  & $command $arglist | Out-Host
  Write-Host "$command exited with code $LastExitCode"
  if ($LastExitCode -ne 0) {
      throw "failed $description; $command exited with code $LastExitCode"
  }
}

# Function to quote a command, passed as the parameter "arguments", which is of type 
# System.Collections.ArrayList containing String values
#
# Note: This does not automatically fix malformatted commands which have 
# unterminated quotes already. This also will cause problems for any unconventional
# commands, scripts, or binaries
function Quote-CommandArguments {
  #Use named command parameter
  Param([System.Collections.ArrayList]${arguments})
  
  ${original} = ${arguments}.Clone()
  # Get array of indices for parameters (valued beginning with '-')
  ${parameters} = New-Object System.Collections.ArrayList
  for (${index}=0;${index} -lt ${arguments}.Count; ${index}++)
  {
    # Check if current value is a parameter declaration
    # Dash (-) for powershell and some other command types
    # Forward slash (/) for common Windows applications
    if (${arguments}[${index}] -match "^[-/]")
    {
        ${parameters}.add(${index}) | out-null
    }
  }
  
  # Iterate the list of parameters to ensure they are quoted
  for (${index}=0;${index} -lt ${parameters}.Count; ${index}++)
  {
    # Skip parameters with no value
    ## Left half checks if last parameter is at end of command string
    ## Right half checks if another parameter immediately follows the current parameter
    if (${parameters}[${index}] -eq ${arguments}.Count - 1 -or $parameters[$index] + 1 -eq $parameters[$index + 1])
    {
      # 
      continue
    }
    
    # Handle where we are at the end of the array.
    ${end} = ${parameters}[${index} + 1] - 1
    if (${index} -eq ${parameters}.Count - 1)
    {
      ${end} = ${arguments}.Count - 1
    }
    
    # If not already quoted do so
    ## Regex matches beginning of String with single or double quote, double quote escaped with backtick
    ## Note, this does not handle 
    if (! (${arguments}[${parameters}[${index}] + 1] -match "^['`"]"))
    {
        ## Quote the 
        ${arguments}[${parameters}[${index}] + 1] = "'"+${arguments}[${parameters}[${index}] + 1]
        ${arguments}[${end}] = ${arguments}[${end}]+"'"
    }
  }
  
  Write-Host ${MyInvocation}.MyCommand ": Changed arguments from"
  Write-Host ${MyInvocation}.MyCommand ": `t" ${original}
  Write-Host ${MyInvocation}.MyCommand ": To"
  Write-Host ${MyInvocation}.MyCommand ":`t" ${arguments}
}
