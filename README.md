# TOEventLogging
Logging to Windows Eventlog

## Functions
### New-TOEventLog
Creates a new eventlog in Windows Logs and sets size limit. 
Switch to create sources for events in Applicationlog. This will create sources for LOGNAME+Info, LOGNAME+Warning, LOGNAME+Error.
### Write-TOEventLogInfo
Writes an info message to eventlog. Switch to write events in Applicationlog as well with the source LOGNAME+Info
### Write-TOEventLogWarning
Writes an warning message to eventlog. Switch to write events in Applicationlog as well with the source LOGNAME+Warning
### Write-TOEventLogError
Writes an Error message to eventlog. Switch to write events in Applicationlog as well with the source LOGNAME+Error
