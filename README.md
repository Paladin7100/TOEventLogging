# TOEventLogging
Logging to Windows Eventlog

## Reason for creating the script
To ease the handling of writing to windows eventlog.
Sometimes I need to have the Error logs sent to the application log, as it is the one being monitored. This way i can maintain a log for my scripts and have incident handling through the application logs.

## Functions
### New-TOEventLog
Creates a new eventlog folder/file in Windows Event Logs and sets size limit. 
Switch to create sources for events in Applicationlog. This will create the source for pss_LOGNAME, or another selfdefined header.
Starts the command in an elevated window if it's not already so.
### Write-TOEventLogInfo
Writes an info message to eventlog. Switch to write events in Applicationlog as well with the source pss_LOGNAME, or another selfdefined header.
### Write-TOEventLogWarning
Writes an warning message to eventlog. Switch to write events in Applicationlog as well with the source pss_LOGNAME, or another selfdefined header.
### Write-TOEventLogError
Writes an Error message to eventlog. Switch to write events in Applicationlog as well with the source pss_LOGNAME, or another selfdefined header.
### Remove-TOEventLogError
Removes eventlog folder/file in Windows Event Logs. 
Switch to remove source for events in Applicationlog. This will remove the source for pss_LOGNAME, or another selfdefined header.
Starts the command in an elevated window if it's not already so.
