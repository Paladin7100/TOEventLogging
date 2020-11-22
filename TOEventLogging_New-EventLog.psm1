function New-TOEventLog {
<#
.SYNOPSIS
    Creates a new log in windows event log

.DESCRIPTION
    Creates a new log in windows event log and optionally another source for the application log.
    The log by default be set to 10MB size, but can be changed by use of parameters.
    The optional source will by default be named pss_'EVENTLOGNAME', but can be changed by use of parameters.
    
.PARAMETER EventLogName
    Mandatory. Name of the new event log

.PARAMETER EventLogSizeMB
    Optional. Size in MB of the new event log

.PARAMETER AppEventLog
    Optional, Switch. If set creates a new source in the event log 'Application'. 
    Default is pss_'EVENTLOGNAME'

.PARAMETER AppEventLogHeader
    Optional. Option to change header for the new event log 'Application' source
    Default is pss_'EVENTLOGNAME'

.INPUTS
    Parameters above

.OUTPUTS
    Event Log created
    Event log source created

.NOTES
    Version:        0.9
    Author:         Frank Honore
    Creation Date:  11/22/20
    Purpose/Change: Built the basic functionality of the script.

.LINK

.EXAMPLE
    New-TOEventLog -EventLogName TaskOrganizer -EventLogSizeMB 15

    Creates a new event log named 'TaskOrganizer' with Limit of 15MB. 

.EXAMPLE
    New-TOEventLog -EventLogName TaskOrganizer -EventLogSizeMB 15 -AppEventLog -AppEventLogHeader 'abc_'

    Creates a new event log named 'TaskOrganizer' with Limit of 15MB, and new source in Application log named 'abc_TaskOrganizer'.
#>

[CmdletBinding()]
Param
    (
    [Parameter(Mandatory=$true,
        Position=1)]
        [String]
        $EventLogName,
    [Parameter(Position=2)]
        [Int]
        $EventLogSizeMB = 10,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [Switch]
        $AppEventLog,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [String]
        $AppEventLogHeader = "pss_"
    )

    $EventLogApplogName = $AppEventLogHeader + $EventLogName
    $EventLogSources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    $Scriptblock = ""
    $ScriptblockApp = ""
        $Scriptblock = $Scriptblock + "New-EventLog -LogName '$EventLogName' -Source '$EventLogName' -ErrorAction Continue;" + "`n"
        $ScriptblockApp = $ScriptblockApp + "New-EventLog -LogName '$EventLogName' -Source '$EventLogName' -ErrorAction Continue;" + "`n"
        $Scriptblock = $Scriptblock + "Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize -ErrorAction Continue;"
        $ScriptblockApp = $ScriptblockApp + "Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize -ErrorAction Continue;" + "`n"
        $ScriptblockApp = $ScriptblockApp + "New-EventLog -LogName 'Application' -Source $EventLogApplogName -ErrorAction Continue;"
    If (!($EventLogSources.keys -contains $EventLogName)){
        $EventLogSize = $EventLogSizeMB * 1MB
        If ($AppEventLog){
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
                # $Scriptblock = "
                #     New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
                #     Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
                #     New-EventLog -LogName 'Application' -Source $EventLogApplogName;
                #     Sleep 3
                # "
                Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockApp" -verb RunAs
            } else {
                New-EventLog -LogName $EventLogName -Source $EventLogName
                Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
                New-EventLog -LogName Application -Source $EventLogApplogName
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
            # $Scriptblock = "
            #     New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
            #     Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
            #     Sleep 3
            # "
            Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
            } else {
                New-EventLog -LogName $EventLogName -Source $EventLogName
                Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
            }
        }
    }
}
