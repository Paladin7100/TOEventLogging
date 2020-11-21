function Remove-TOEventLog {
    param (
        $EventLogName,
        [Switch]$AppEventLog,
        [Switch]$Confirm
    )

    $EventLogInfoName = $EventLogName + "Info"
    $EventLogWarningName = $EventLogName + "Warning"
    $EventLogErrorName = $EventLogName + "Error"
    $Sources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    $Scriptblock = ""
    $ScriptblockConfirm = ""
    $ScriptblockApp = ""
    $ScriptblockAppConfirm = ""
    If ($Sources.keys -contains $EventLogName) {
        $Scriptblock = $Scriptblock + "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue;"
        $ScriptblockConfirm = $ScriptblockConfirm + "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue -Confirm;"
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue;" + "`n"
        $ScriptblockAppConfirm = "Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue -Confirm;" + "`n"
    }
    If ($Sources.Application -contains $EventLogInfoName) {
        # $Scriptblock = $Scriptblock + "Remove-EventLog -Source '$EventLogInfoName' -ErrorAction Continue;" + "`n"
        # $ScriptblockConfirm = $ScriptblockConfirm + "Remove-EventLog -Source '$EventLogInfoName' -ErrorAction Continue -Confirm;" + "`n"
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -Source '$EventLogInfoName' -ErrorAction Continue;" + "`n"
        $ScriptblockAppConfirm = $ScriptblockAppConfirm + "Remove-EventLog -Source '$EventLogInfoName' -ErrorAction Continue -Confirm;" + "`n"
    }
    If ($Sources.Application -contains $EventLogWarningName) {
        # $Scriptblock = $Scriptblock + "Remove-EventLog -Source '$EventLogWarningName' -ErrorAction Continue;" + "`n"
        # $ScriptblockConfirm = $ScriptblockConfirm + "Remove-EventLog -Source '$EventLogWarningName' -ErrorAction Continue -Confirm;" + "`n"
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -Source '$EventLogWarningName' -ErrorAction Continue;" + "`n"
        $ScriptblockAppConfirm = $ScriptblockAppConfirm + "Remove-EventLog -Source '$EventLogWarningName' -ErrorAction Continue -Confirm;" + "`n"
    }
    If ($Sources.Application -contains $EventLogErrorName) {
        # $Scriptblock = $Scriptblock + "Remove-EventLog -Source '$EventLogErrorName' -ErrorAction Continue;" + "`n"
        # $ScriptblockConfirm = $ScriptblockConfirm + "Remove-EventLog -Source '$EventLogErrorName' -ErrorAction Continue -Confirm;" + "`n"
        $ScriptblockApp = $ScriptblockApp + "Remove-EventLog -Source '$EventLogErrorName' -ErrorAction Continue;" + "`n"
        $ScriptblockAppConfirm = $ScriptblockAppConfirm + "Remove-EventLog -Source '$EventLogErrorName' -ErrorAction Continue -Confirm;" + "`n"
    }

    If ($AppEventLog){
        # Get-EventLog -List | where {$_.log -eq $EventLogName}
        # Get-EventLog -LogName Application | where {$_.Source -like $EventLogName"*"} | select Source -Unique
        # (Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application).pschildname | where {$_ -like "TOLogging*"}
        If (!($confirm)){
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
            #     $Scriptblock = "
            #     Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue;
            #     Remove-EventLog -Source $EventLogInfoName -ErrorAction Continue;
            #     Remove-EventLog -Source $EventLogWarningName -ErrorAction Continue;
            #     Remove-EventLog -Source $EventLogErrorName -ErrorAction Continue;
            #     Sleep 3
            # "
                If ($ScriptblockApp) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockApp" -verb RunAs
                }
            } else {
                If ($Sources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue
                }
                If ($Sources.Application -contains $EventLogInfoName) {
                    Remove-EventLog -Source $EventLogInfoName -ErrorAction Continue
                }
                If ($Sources.Application -contains $EventLogWarningName) {
                    Remove-EventLog -Source $EventLogWarningName -ErrorAction Continue
                }
                If ($Sources.Application -contains $EventLogErrorName) {
                    Remove-EventLog -Source $EventLogErrorName -ErrorAction Continue
                }
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
            #     $Scriptblock = "
            #     Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue -Confirm;
            #     Remove-EventLog -Source $EventLogInfoName -ErrorAction Continue -Confirm;
            #     Remove-EventLog -Source $EventLogWarningName -ErrorAction Continue -Confirm;
            #     Remove-EventLog -Source $EventLogErrorName -ErrorAction Continue -Confirm;
            #     Sleep 3
            # "
                If ($ScriptblockAppConfirm) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockAppConfirm" -verb RunAs
                }
            } else {
                If ($Sources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue -Confirm
                }
                If ($Sources.Application -contains $EventLogInfoName) {
                    Remove-EventLog -Source $EventLogInfoName -ErrorAction Continue -Confirm
                }
                If ($Sources.Application -contains $EventLogWarningName) {
                    Remove-EventLog -Source $EventLogWarningName -ErrorAction Continue -Confirm
                }
                If ($Sources.Application -contains $EventLogErrorName) {
                    Remove-EventLog -Source $EventLogErrorName -ErrorAction Continue -Confirm
                }
            }
        }
    } else {
        If (!($confirm)){
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
                #     $Scriptblock = "
                #     Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue;
                #     Sleep 3
                # "
                If ($ScriptBlock) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
                }
            } else {
                If ($Sources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue
                }
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {
            #     $Scriptblock = "
            #     Remove-EventLog -LogName '$EventLogName' -ErrorAction Continue -Confirm;
            #     Sleep 3
            # "
                If ($ScriptblockConfirm) {Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockConfirm" -verb RunAs
                }
            } else {
                If ($Sources.keys -contains $EventLogName) {
                    Remove-EventLog -LogName $EventLogName -ErrorAction Continue -Confirm
                }
            }
        }
    }
}


    # If ($confirm -eq $false){
    #     If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    #     {
    #         $Scriptblock = "
    #         Remove-EventLog -LogName '$EventLogName';
    #         Remove-EventLog -Source $EventLogInfoName;
    #         Remove-EventLog -Source $EventLogWarningName;
    #         Remove-EventLog -Source $EventLogErrorName;
    #         Sleep 3
    #     "
    #     Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
    #     } else {
    #         Remove-EventLog -LogName $EventLogName
    #         Remove-EventLog -Source $EventLogInfoName
    #         Remove-EventLog -Source $EventLogWarningName
    #         Remove-EventLog -Source $EventLogErrorName
    #     }
    # } else {
    #     Remove-EventLog -LogName $EventLogName -Confirm        
    #     Remove-EventLog -Source $EventLogInfoName -Confirm
    #     Remove-EventLog -Source $EventLogWarningName -Confirm
    #     Remove-EventLog -Source $EventLogErrorName -Confirm
    # }





    # If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    # {
    # Write-Host "This script needs to be run As Administrator"
    # Break
    # } else {
    #     If ($confirm -eq $false){
    #         Remove-EventLog -LogName $EventLogName
    #     }else {
    #         Remove-EventLog -LogName $EventLogName -Confirm        
    #     }
    #     If ($AppEventLog){
    #         $EventLogInfoName = $EventLogName + "Info"
    #         Remove-EventLog -Source $EventLogName
    #         $EventLogWarningName = $EventLogName + "Warning"
    #         Remove-EventLog -Source $EventLogName
    #         $EventLogErrorName = $EventLogName + "Error"
    #         Remove-EventLog -Source $EventLogName
    #     }
    # }
