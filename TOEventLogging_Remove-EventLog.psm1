function Remove-TOEventLog {
    Param
    (
    [Parameter(Mandatory=$true,
        Position=1)]
        [String]
        $EventLogName,
    [Parameter(Position=2)]
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
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -Source '$EventLogInfoName' -ErrorAction Continue;" + "`n"
        $ScriptblockAppConfirm = $ScriptblockAppConfirm + "Remove-EventLog -Source '$EventLogInfoName' -ErrorAction Continue -Confirm;" + "`n"
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
