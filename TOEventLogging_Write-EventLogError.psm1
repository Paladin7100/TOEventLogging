function Write-TOEventLogError {
    param (
        $EventLogName,
        $EventLogID = 3000,
        [Switch]$AppEventLog,
        $Message

    )
    If (Get-EventLog -List | where {$_.Log -eq $EventLogName}){
        Write-EventLog -LogName $EventLogName -Source $EventLogName -EntryType Error -EventId $EventLogID -Message $Message -Category 0
        If ($AppEventLog){
            $EventLogErrorName = $EventLogName + "Error"
            Write-EventLog -LogName Application -Source $EventLogErrorName -EntryType Error -EventId $EventLogID -Message $Message -Category 0
        }
    } else {
        Write-Warning "Could not find Log named $EventLogName. Please run command Start-TOEventLog first as administrator"
    }
}