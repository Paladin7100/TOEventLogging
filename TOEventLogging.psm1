#
#
#
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

function Write-TOEventLogInfo {
<#
.SYNOPSIS
    Writes an Info message to the event log.

.DESCRIPTION
    Writes an Info message to the event log.
    
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
    Write-TOEventLogInfo -EventLogName TaskOrganizer -Message "Everything is OK"

    Writes Information event to the event log 'TaskOrganizer'. 

    .EXAMPLE
    Write-TOEventLogInfo -EventLogName TaskOrganizer -Message "Everything is OK" -EventLogID 1010 -AppEventLog -AppEventLogHeader "abc_"

    Writes Information event to the event log 'TaskOrganizer' using the eventid 1010 and same Information message written to 'Application' log using the source 'abc_TaskOrganizer'.
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
        $EventLogID = 1000,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [Switch]
        $AppEventLog,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [String]
        $AppEventLogHeader = "pss_"
    )

    $EventLogSources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    If ($EventLogSources.keys -contains $EventLogName){
        Write-EventLog -LogName $EventLogName -Source $EventLogName -EntryType Information -EventId $EventLogID -Message $Message -Category 0
        If ($AppEventLog){
            $EventLogApplogName = $AppEventLogHeader + $EventLogName
            If ($EventLogSources.Application -contains $EventLogApplogName){
                Write-EventLog -LogName Application -Source $EventLogApplogName -EntryType Information -EventId $EventLogID -Message $Message -Category 0
            } else {
                Write-Warning "Could not find source named $EventLogApplogName. Please run command New-TOEventLog first as administrator"
            }
        }
    } else {
        Write-Warning "Could not find Log named $EventLogName. Please run command Start-TOEventLog first as administrator"
    }
}

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

function Write-TOEventLogError {
<#
.SYNOPSIS
    Writes an Error message to the event log.

.DESCRIPTION
    Writes an Error message to the event log.
    
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
    Write-TOEventLogError -EventLogName TaskOrganizer -Message "Everything went kaboom"

    Writes Error event to the event log 'TaskOrganizer'. 

    .EXAMPLE
    Write-TOEventLogError -EventLogName TaskOrganizer -Message "Everything went kaboom" -EventLogID 3010 -AppEventLog -AppEventLogHeader "abc_"

    Writes Error event to the event log 'TaskOrganizer' using the eventid 3010 and same Error message written to 'Application' log using the source 'abc_TaskOrganizer'.
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
        $EventLogID = 3000,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [Switch]
        $AppEventLog,
        [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [String]
        $AppEventLogHeader = "pss_"
    )

    $EventLogSources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    If ($EventLogSources.keys -contains $EventLogName){
        Write-EventLog -LogName $EventLogName -Source $EventLogName -EntryType Error -EventId $EventLogID -Message $Message -Category 0
        If ($AppEventLog){
            $EventLogApplogName = $AppEventLogHeader + $EventLogName
            If ($EventLogSources.Application -contains $EventLogApplogName){
                Write-EventLog -LogName Application -Source $EventLogApplogName -EntryType Error -EventId $EventLogID -Message $Message -Category 0
            } else {
                Write-Warning "Could not find source named $EventLogApplogName. Please run command New-TOEventLog first as administrator"
            }
        }
    } else {
        Write-Warning "Could not find Log named $EventLogName. Please run command Start-TOEventLog first as administrator"
    }
}

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
