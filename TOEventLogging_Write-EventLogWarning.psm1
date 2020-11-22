function Write-TOEventLogWarning {
    Param
    (
    [Parameter(Mandatory=$true,
        Position=1)]
        [String]
        $EventLogName,
    [Parameter(Mandatory=$true,
        Position=2)]
        [String]
        $Message,
    [Parameter(Mandatory=$false,
        Position=3)]
        [String]
        $EventLogID = 2000,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [Switch]
        $AppEventLog,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [String]
        $AppEventLogHeader = "pss_"
    )

    $EventLogSources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    If ($EventLogSources.keys -contains $EventLogName){
        Write-EventLog -LogName $EventLogName -Source $EventLogName -EntryType Warning -EventId $EventLogID -Message $Message -Category 0
        If ($AppEventLog){
            $EventLogApplogName = $AppEventLogHeader + $EventLogName
            If ($EventLogSources.Application -contains $EventLogApplogName){
                Write-EventLog -LogName Application -Source $EventLogApplogName -EntryType Warning -EventId $EventLogID -Message $Message -Category 0
            } else {
                Write-Warning "Could not find source named $EventLogApplogName. Please run command New-TOEventLog first as administrator"
            }
        }
    } else {
        Write-Warning "Could not find Log named $EventLogName. Please run command New-TOEventLog first as administrator"
    }
}