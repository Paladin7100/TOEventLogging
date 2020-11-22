function New-TOEventLog {
    Param
    (
    [Parameter(Mandatory=$true,
        Position=1)]
        [String]
        $EventLogName,
    [Parameter(Position=2)]
        [Int]
        $EventLogSizeMB = 10,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [Switch]
        $AppEventLog,
    [Parameter(ParameterSetName="ApplicationLog",Mandatory=$false)]
        [String]
        $AppEventLogHeader = "pss_"
    )

    $EventLogApplogName = $AppEventLogHeader + $EventLogName
    $EventLogSources = Get-WmiObject -Namespace "root\cimv2" -Class "Win32_NTEventLOgFile" | Select-Object FileName, Sources | ForEach-Object -Begin { $hash = @{}} -Process { $hash[$_.FileName] = $_.Sources } -end { $Hash }
    $Scriptblock = ""
    $ScriptblockApp = ""
    # If (!($EventLogSources.keys -contains $EventLogName)) {
        $Scriptblock = $Scriptblock + "New-EventLog -LogName '$EventLogName' -Source '$EventLogName' -ErrorAction Continue;" + "`n"
        $ScriptblockApp = $ScriptblockApp + "New-EventLog -LogName '$EventLogName' -Source '$EventLogName' -ErrorAction Continue;" + "`n"
    # }
    # {
        $Scriptblock = $Scriptblock + "Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize -ErrorAction Continue;"
        $ScriptblockApp = $ScriptblockApp + "Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize -ErrorAction Continue;" + "`n"
    # }
    # If (!($EventLogSources.Application -contains $EventLogApplogName)) {
        $ScriptblockApp = $ScriptblockApp + "New-EventLog -LogName 'Application' -Source $EventLogApplogName -ErrorAction Continue;"
    # }
    # If (!(Get-EventLog -List | where {$_.Log -eq $EventLogName})){
    If (!($EventLogSources.keys -contains $EventLogName)){
        $EventLogSize = $EventLogSizeMB * 1MB
        If ($AppEventLog){
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
                # $Scriptblock = "
                #     New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
                #     Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
                #     New-EventLog -LogName 'Application' -Source $EventLogApplogName;
                #     Sleep 3
                # "
                Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptblockApp" -verb RunAs
            } else {
                New-EventLog -LogName $EventLogName -Source $EventLogName
                Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
                New-EventLog -LogName Application -Source $EventLogApplogName
            }
        } else {
            If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){
            # $Scriptblock = "
            #     New-EventLog -LogName '$EventLogName' -Source '$EventLogName';
            #     Limit-EventLog -LogName '$EventLogName' -MaximumSize $EventLogSize;
            #     Sleep 3
            # "
            Start-Process -FilePath powershell.exe -ArgumentList "-command", "$ScriptBlock" -verb RunAs
            } else {
                New-EventLog -LogName $EventLogName -Source $EventLogName
                Limit-EventLog -LogName $EventLogName -MaximumSize $EventLogSize
            }
        }
    }
}
