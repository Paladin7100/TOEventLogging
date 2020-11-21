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
                    Sleep 3
                "
                Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
            } else {
                New-EventLog -LogName $EventLogName -Source $EventLogName
                Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
                New-EventLog -LogName Application -Source $EventLogInfoName
                New-EventLog -LogName Application -Source $EventLogWarningName
                New-EventLog -LogName Application -Source $EventLogErrorName
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
            $Scriptblock = "
                New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
                Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
                Sleep 3
            "
            Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
            } else {
                New-EventLog -LogName $EventLogName -Source $EventLogName
                Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
            }
        }
    }
}
