function Write-TOEventLogWarning {
<#
.SYNOPSIS
    Writes an Warning message to the event log.

.DESCRIPTION
    Writes an Warning message to the event log.
    
.PARAMETER EventLogName
    Mandatory. Name of the event log to be written to.

.PARAMETER Message
    Mandatory. Message to be written to the event log.

.PARAMETER EventLogID
    Optional. Sets the Event Log ID. 

.PARAMETER AppEventLog
    Optional. If set, writes the message to the event log 'Application' as well. 
    Default is pss_'EVENTLOGNAME'

.PARAMETER AppEventLogHeader
    Optional. Option to change header for the event log 'Application' source to write to.
    Default is pss_'EVENTLOGNAME'

.INPUTS
    Parameters above

.OUTPUTS
    Writes to Event Log.

.NOTES
    Version:        0.9
    Author:         Frank Honore
    Creation Date:  11/22/20
    Purpose/Change: Built the basic functionality of the script.

.LINK

.EXAMPLE
    Write-TOEventLogWarning -EventLogName TaskOrganizer -Message "Everything is OK"

    Writes Warning event to the event log 'TaskOrganizer'. 

    .EXAMPLE
    Write-TOEventLogWarning -EventLogName TaskOrganizer -Message "Everything is OK" -EventLogID 1010 -AppEventLog -AppEventLogHeader "abc_"

    Writes Warning event to the event log 'TaskOrganizer' using the eventid 1010 and same Warning message written to 'Application' log using the source 'abc_TaskOrganizer'.
#>

[CmdletBinding()]
    Param
    (
    [Parameter(Mandatory=$true,
        Position=1)]
        [String]
        $EventLogName,
    [Parameter(Mandatory=$true,
        Position=2)]
        [String]
        $Message,
    [Parameter(Mandatory=$false,
        Position=3)]
        [String]
        $EventLogID = 2000,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [Switch]
        $AppEventLog,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [String]
        $AppEventLogHeader = "pss_"
    )

    $EventLogSources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    If ($EventLogSources.keys -contains $EventLogName){
        Write-EventLog -LogName $EventLogName -Source $EventLogName -EntryType Warning -EventId $EventLogID -Message $Message -Category 0
        If ($AppEventLog){
            $EventLogApplogName = $AppEventLogHeader + $EventLogName
            If ($EventLogSources.Application -contains $EventLogApplogName){
                Write-EventLog -LogName Application -Source $EventLogApplogName -EntryType Warning -EventId $EventLogID -Message $Message -Category 0
            } else {
                Write-Warning "Could not find source named $EventLogApplogName. Please run command New-TOEventLog first as administrator"
            }
        }
    } else {
        Write-Warning "Could not find Log named $EventLogName. Please run command New-TOEventLog first as administrator"
    }
}
