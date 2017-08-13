function Write-Log{
<#
.SYNOPSIS
Logs messages to file.

.DESCRIPTION
Write-Log takes text from the InputObject parameter and logs it to the logfile specified by the -LogFileName parameter. Optionaly, one can specify -NoNewline parameter to exclude the newline character(\n) at the end of the output.
If no logfile is specified, LogFilename would default to 'C:\LogOutFile.log'.
If no Text if specified for any reasons, the function would prompt for the text.
If the -NoNewLine is not specified, the default behaviour is to append the newline character.

.PARAMETER InputObject
Text to log to file.
.PARAMETER LogFileName
Provide the path and file to log into. Default: '...\Desktop\Write-Log.log'
.PARAMETER LogType
Optionally Specify the log type.
.PARAMETER NoTimeStamp
Toggle to allow Time Stamp or not
.PARAMETER TimeStampPosition
Provides the position of the Time Stamp. Valide Values are "Top", "Bottom", "Left", "Right".
The default is 'Left'.
.PARAMETER NoNewline
Specify whether or not to add the newline character(\n)
.PARAMETER ClearLog
Clears the content of the log file.

.EXAMPLE
$LogFile='C:\LogOutFile.log'
Write-Log -LogFileName $LogFile -InputObject "Doing some house keeping"
.EXAMPLE
Write-Log "Doing some house keeping" 'C:\LogOutFile.log' 
.EXAMPLE
Write-Log -LogFileName 'C:\LogOutFile.log' -InputObject "Doing some house keeping" -NoNewline
.EXAMPLE
$null |Write-Log -ClearLog
.EXAMPLE
'Message' |Write-Log -ClearLog
.EXAMPLE
'Message0', 'Msg1', 'Msg3, 4, 5, 6' |Write-Log
.EXAMPLE
'Hi', 'There' |Write-Log -TimeStampPosition Right,Left,Top,Bottom,left

.LINK
Online help: https://www.github.com/DazzyMlv
#>
    [CmdletBinding(PositionalBinding=$True,
                   DefaultParameterSetName="TimeStamp",
                   HelpUri='https://github.com/DazzyMlv',
                   RemotingCapability='None')]
    paraM(
        [Parameter(Mandatory=$True, 
                   HelpMessage="Text to log", 
                   ValueFromPipeline=$True, 
                   Position=0)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Alias('Msg', 'Message')]
        [String[]]$InputObject,
        
        [Parameter(Position=1,HelpMessage="Provide the path and file to log into")]
        [AllowEmptyString()]
        [Alias('LFN')]
        [string]$LogFileName="$Env:USERPROFILE\Desktop\$($MyInvocation.InvocationName).log",

        [Parameter(Position=2,HelpMessage="Specify the log type")]
        [ValidateSet("DEBUG", "ERROR", "WARNING", "VERBOSE", "SPEECH", "INFO")]
        [Alias('LType')]
        [String[]]$LogType,

        [ValidateSet("Top", "Bottom", "Left", "Right")]
        [ValidateCount(0,4)]
        [Parameter(Position=3,HelpMessage="Specify the time stamp positition")]
        [Parameter(ParameterSetName="TimeStamp")]
        [Alias('TSP')]
        [String[]]$TimeStampPosition='Left',

        [Alias('NTS')]
        [switch]$NoTimeStamp,

        [Parameter(HelpMessage="Specify whether or not to add the newline character(\n)")]
        [Alias('NNL')]
        [switch]$NoNewline,

        [Switch]$ClearLog
    )
    BEGIN{
        Try{
            Write-Verbose "[+] Initializing $($MyInvocation.MyCommand.CommandType.ToString().ToLower()) '$($MyInvocation.InvocationName)'";
            [string]$LogString = "";
            [bool]$LoggingIsOk = $false
            $WriteLogCustomDate = Get-Date -uformat "%a, %d/%m/%Y - %H:%M:%S:<%s>"
            $ToString = New-Object System.Collections.Generic.List[System.Object]
            $InputStrings = New-Object System.Collections.Generic.List[System.Object]
            #$ToString.Add("")
            $ReturnObjectProps = @{}
            $ReturnObjectProps.Add("LogFile", $LogFileName)
            $ReturnObjectProps.Add("TimeStamp", $WriteLogCustomDate)
            $ReturnObjectProps.Add("TimeStampPosition",$TimeStampPosition)
            $ReturnObjectProps.Add("LogType",$LogType)
            $ReturnObjectProps.Add("NoTimeStamp",$NoTimeStamp)
            $ReturnObjectProps.Add("NoNewline",$NoNewline)
            $ReturnObjectProps.Add("ClearLog",$ClearLog)
           
            # Now checking '$LogFileName' access write.
            Try{
                Write-Verbose "[+] $($MyInvocation.MyCommand.CommandType.ToString()) '$($MyInvocation.InvocationName)' verifying write access to '$LogFileName'..."
                "" |Out-File -FilePath $LogFileName -Append -NoNewline | Out-Null
                Write-Verbose "[+] $($MyInvocation.MyCommand.CommandType.ToString()) '$($MyInvocation.InvocationName)' write access to '$LogFileName' verification completed."
                $LoggingIsOk = $True
            }Catch{
                $LoggingIsOk = $false
                Write-Verbose "[-] $($_.Exception)"
                Write-Warning "[-] $($_.Exception.Message)"
                Write-Debug "[-] $($Error[0]) (while $($MyInvocation.MyCommand.CommandType.ToString().ToLower()) '$($MyInvocation.InvocationName)' was trying to write to '$LogFileName').";
                Return; # Skips to PROCESS{}
            } # End: END{} Try{}Catch{}

            if($ClearLog){
                Out-File $LogFileName| Out-Null
                Write-Verbose "[-] $($MyInvocation.MyCommand.CommandType.ToString()) '$($MyInvocation.InvocationName)' cleared log file '$LogFileName'."
            }
        }Catch{
            $LoggingIsOk = $false
            Write-Verbose "[-] $($_.Exception)"
            Write-Warning "[-] $($_.Exception.Message)"
            Write-Debug "[-] $($Error[0]) (while Initializing $($MyInvocation.MyCommand.CommandType.ToString().ToLower()) '$($MyInvocation.InvocationName)'.";
            Return; # Skips to PROCESS{}
        }Finally{
            if($LoggingIsOk){
                Write-Verbose "[+] $($MyInvocation.MyCommand.CommandType.ToString()): '$($MyInvocation.InvocationName)' initialization completed successfully.";
            }Else{
                Write-Verbose "[-] $($MyInvocation.MyCommand.CommandType.ToString()): '$($MyInvocation.InvocationName)' initialization completed unsuccessfully.";
            }          
        } # End: END{} Try{}Catch{}
    }
    PROCESS{
        try{
            if( !($LoggingIsOk) ){Return} # Skips to END{}
            Write-Verbose "[+] '$($MyInvocation.InvocationName)' PROCESS started.";
            foreach($Ltype in $LogType){
                Switch($Ltype){
                    DEBUG   {$LogTypeString += "DEBUG: ";Break;}
                    ERROR   {$LogTypeString += "ERROR: ";Break}
                    WARNING {$LogTypeString += "WARNING: ";Break}
                    VERBOSE {$LogTypeString += "VERBOSE: ";Break}
                    SPEECH  {$LogTypeString += "SPEECH: ";Break}
                    INFO    {$LogTypeString += "INFO: ";Break}
                    Default {$LogTypeString += "";Break}
                }
            }
            foreach($Text in $InputObject){
                $LogString = ""
                If(!$NoTimeStamp){
                    If ($TimeStampPosition -eq 'Top'){
                            $LogString += "[$($WriteLogCustomDate)]`n"
                    }
                    If($TimeStampPosition -eq 'Left'){
                            $LogString += "[$($WriteLogCustomDate)] "
                    }
                }

                if($NoTimeStamp){
                    $LogString = $LogTypeString + $Text
                } Else{
                    $LogString += $LogTypeString + $Text
                    If($TimeStampPosition -eq 'Right'){
                        $LogString += " [$($WriteLogCustomDate)] "
                    }
                    If($TimeStampPosition -eq 'Bottom'){
                        $LogString += "`n[$($WriteLogCustomDate)] "
                    }
                }
                if(!$NoNewline){
                    $LogString += "`n";
                }
                $LoggingIsOk=$True
                $LogString |Out-File -FilePath $LogFileName -Append -NoNewline
                $ToString.Add($LogString)
                $InputStrings.Add($Text)
            } # End: foreach($Text in $InputObject){}
        }Catch{
            Write-Verbose "[-] $($_.Exception)."
            Write-Warning "[-] $($MyInvocation.MyCommand.CommandType.ToString()):<'$($MyInvocation.InvocationName)'> $($_.Exception.Message)";
            Write-Debug "[-] $($_.Exception.Message) (while '$($MyInvocation.InvocationName)' was doing some housekeeping).";
        } # End: END{} Try{}Catch{}
    } # End: PROCESS{}
    END{
        Try{
            Write-Verbose "[+] $($MyInvocation.MyCommand.CommandType.ToString()): '$($MyInvocation.InvocationName)' doing some housekeeping...";
            $ReturnObjectProps.Add("String", $ToString)
            $ReturnObjectProps.Add("InputObject", $InputStrings)
            $ReturnObjectProps.Add("Status", $LoggingIsOk)
            $ReturnObject = New-Object -TypeName psobject -Property $ReturnObjectProps
            Write-Output $ReturnObject
        }Catch{
            $LoggingIsOk = $false
            Write-Verbose "[-] $($_.Exception)"
            Write-Warning "[-] $($_.Exception.Message)"
            Write-Debug "[-] $($Error[0]) (while '$($MyInvocation.InvocationName)' $($MyInvocation.MyCommand.CommandType.ToString().ToLower()) was doing some housekeeping).";
        }Finally{
            if($LoggingIsOk){
                Write-Verbose "[+] $($MyInvocation.MyCommand.CommandType.ToString()): '$($MyInvocation.InvocationName)' completed successfully.";
            }Else{
                Write-Verbose "[-] $($MyInvocation.MyCommand.CommandType.ToString()): '$($MyInvocation.InvocationName)' completed unsuccessfully.";
            }    
        } # End: END{} Try{}Catch{}
    } # END: END {}
} # END: Write-Log
