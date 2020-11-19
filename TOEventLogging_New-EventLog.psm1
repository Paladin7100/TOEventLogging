function Start-TOEventLog {
    param (
        $EventLogName,
        [Switch]$AppEventLog,
        $EventLogSizeMB = 10

    )
    If (!(Get-EventLog -List | where {$_.Log -eq $EventLogName})){
        New-EventLog -LogName $EventLogName -Source $EventLogName
        $EventLogSize = $EventLogSizeMB * 1MB
        Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
        If ($AppEventLog){
            $EventLogInfoName = $EventLogName + "Info"
            New-EventLog -LogName Application -Source $EventLogName
            $EventLogWarningName = $EventLogName + "Warning"
            New-EventLog -LogName Application -Source $EventLogName
            $EventLogErrorName = $EventLogName + "Error"
            New-EventLog -LogName Application -Source $EventLogName
        }
    }

}