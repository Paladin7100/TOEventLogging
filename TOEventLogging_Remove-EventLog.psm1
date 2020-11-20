function Remove-TOEventLog {
    param (
        $EventLogName,
        [Switch]$AppEventLog,
        $Confirm = $false
    )
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
    Write-Host "This script needs to be run As Administrator"
    Break
    } else {
        If ($confirm -eq $false){
            Remove-EventLog -LogName $EventLogName
        }else {
            Remove-EventLog -LogName $EventLogName -Confirm        
        }
        If ($AppEventLog){
            $EventLogInfoName = $EventLogName + "Info"
            Remove-EventLog -Source $EventLogName
            $EventLogWarningName = $EventLogName + "Warning"
            Remove-EventLog -Source $EventLogName
            $EventLogErrorName = $EventLogName + "Error"
            Remove-EventLog -Source $EventLogName
        }
    }
}
