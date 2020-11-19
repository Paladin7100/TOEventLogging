function Write-TOEventLogInfo {
    param (
        $EventLogName,
        $EventLogID = 2000,
        [Switch]$AppEventLog,
        $Message

    )
    If (Get-EventLog -List | where {$_.Log -eq $EventLogName}){
        Write-EventLog -LogName $EventLogName -Source $EventLogName -EntryType Warning -EventId $EventLogID -Message $Message -Category 0
        If ($AppEventLog){
            $Message = $EventLogName + ": " + $Message
            $EventLogWarningName = $EventLogName + "Warning"
            Write-EventLog -LogName Application -Source $EventLogWarningName -EntryType Error -EventId $EventLogID -Message $Message -Category 0
        }
    } else {
        Write-Warning "Could not find Log named $EventLogName. Please run command Start-TOEventLog first as administrator"
    }
}