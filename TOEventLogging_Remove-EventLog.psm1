function Remove-TOEventLog {
<#
.SYNOPSIS
    Removes an entire log in windows event log

.DESCRIPTION
    Removes an entire log in windows event log and optionally a connected source for the application log.
    The optional source removed is the name pss_'EVENTLOGNAME', but can be changed by use of parameters.
    
.PARAMETER EventLogName
    Mandatory. Name of the event log to be removed.

.PARAMETER Confirm
    Optional. Ask for confirmation to delete the log and optional source.

.PARAMETER AppEventLog
    Optional, Switch. If set removes the source in the event log 'Application'. 
    Default is pss_'EVENTLOGNAME'

.PARAMETER AppEventLogHeader
    Optional. Option to change header for the event log 'Application' source to remove.
    Default is pss_'EVENTLOGNAME'

.INPUTS
    Parameters above

.OUTPUTS
    Event Log removed
    Event log source removed

.NOTES
    Version:        0.9
    Author:         Frank Honore
    Creation Date:  11/22/20
    Purpose/Change: Built the basic functionality of the script.

.LINK

.EXAMPLE
    Remove-TOEventLog -EventLogName TaskOrganizer

    Removes the event log 'TaskOrganizer'. 

    .EXAMPLE
    New-TOEventLog -EventLogName TaskOrganizer -EventLogSizeMB 15 -AppEventLog -AppEventLogHeader 'abc_'

    Removes the event log 'TaskOrganizer', and the source in the 'Application' log named ''abc_TaskOrganizer'.
#>

[CmdletBinding()]
    Param
    (
    [Parameter(Mandatory=$true,
        Position=1)]
        [String]
        $EventLogName,
    [Parameter(Mandatory=$false,
        Position=2)]
        [Switch]
        $Confirm,
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
    $ScriptblockConfirm = ""
    $ScriptblockApp = ""
    $ScriptblockAppConfirm = ""
    If ($EventLogSources.keys -contains $EventLogName) {
        $Scriptblock = $Scriptblock + "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue;"
        $ScriptblockConfirm = $ScriptblockConfirm + "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue -Confirm;"
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue;" + "`n"
        $ScriptblockAppConfirm = "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue -Confirm;" + "`n"
    }
    If ($EventLogSources.Application -contains $EventLogApplogName) {
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -Source '$EventLogApplogName' -ErrorAction Continue;"
        $ScriptblockAppConfirm = $ScriptblockAppConfirm + "Remove-EventLog -Source '$EventLogApplogName' -ErrorAction Continue -Confirm;"
    }
    If ($AppEventLog){
        # Get-EventLog -List | where {$_.log -eq $EventLogName}
        # Get-EventLog -LogName Application | where {$_.Source -like $EventLogName"*"} | select Source -Unique
        # (Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application).pschildname | where {$_ -like "TOLogging*"}
        If (!($confirm)){
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                If ($ScriptblockApp) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockApp" -verb RunAs
                }
            } else {
                If ($EventLogSources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue
                }
                If ($EventLogSources.Application -contains $EventLogApplogName) {
                    Remove-EventLog -Source $EventLogApplogName -ErrorAction Continue
                }
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                If ($ScriptblockAppConfirm) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockAppConfirm" -verb RunAs
                }
            } else {
                If ($EventLogSources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue -Confirm
                }
                If ($EventLogSources.Application -contains $EventLogApplogName) {
                    Remove-EventLog -Source $EventLogApplogName -ErrorAction Continue -Confirm
                }
            }
        }
    } else {
        If (!($confirm)){
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                If ($ScriptBlock) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
                }
            } else {
                If ($EventLogSources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue
                }
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                If ($ScriptblockConfirm) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockConfirm" -verb RunAs
                }
            } else {
                If ($EventLogSources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue -Confirm
                }
            }
        }
    }
}
