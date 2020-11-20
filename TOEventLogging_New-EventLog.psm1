function New-TOEventLog {
    param (
        $EventLogName,
        [Switch]$AppEventLog,
        $EventLogSizeMB = 10
    )
    If (!(Get-EventLog -List | where {$_.Log -eq $EventLogName})){
        $EventLogSize = $EventLogSizeMB * 1MB
        If ($AppEventLog){
            $EventLogInfoName = $EventLogName + "Info"
            $EventLogWarningName = $EventLogName + "Warning"
            $EventLogErrorName = $EventLogName + "Error"
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
                $Scriptblock = "
                    New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
                    Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
                    New-EventLog -LogName Application -Source $EventLogInfoName;
                    New-EventLog -LogName Application -Source $EventLogWarningName;
                    New-EventLog -LogName Application -Source $EventLogErrorName;
                    Sleep 5
                "
                Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
            $Scriptblock = "
                New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
                Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
                Sleep 5
            "
            Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
            }
        }
    }
}

#     )
#     If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
#     {
#     Write-Host "This script needs to be run As Administrator"
#     Break
#     } else {
#         If (!(Get-EventLog -List | where {$_.Log -eq $EventLogName})){
#             New-EventLog -LogName $EventLogName -Source $EventLogName
#             $EventLogSize = $EventLogSizeMB * 1MB
#             Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
#             If ($AppEventLog){
#                 $EventLogInfoName = $EventLogName + "Info"
#                 New-EventLog -LogName Application -Source $EventLogName
#                 $EventLogWarningName = $EventLogName + "Warning"
#                 New-EventLog -LogName Application -Source $EventLogName
#                 $EventLogErrorName = $EventLogName + "Error"
#                 New-EventLog -LogName Application -Source $EventLogName
#             }
#         }
#     }
# }
