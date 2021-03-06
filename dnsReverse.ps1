<#
Script: dnsReverse.ps1

Script by: Scott Forsyth

Email: forsyths@sec.gov

Last Modified: 2/9/2017

USE: The revese of dnsreplace.ps1 script (used to replace IP octet on large number of DNS files from a windows server 2008/2012 DNS export CSV)

- after running this you should have 4 CSV files (the original, the dnsreplaced CSV, the dnsrevsed CSV, and a new copy of the export to run diffs on)

-output is on shell and in CSV with changes made
very little error handling, will correct later.CHECK DNS TO CONFIRM CHANGES

TOADD:
-checking on the dns zone.
-test dns change tracking so output is more acturate.
#>

#Popup for CSV file
Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.title = "Select DNS Export CVS"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

#import csv to use (should be the output csv from dnsReplace.ps1, default is dnsResults.csv)
#name of import CSV
$csvname = Get-FileName "."
$csv = Import-Csv $csvname
#Set Array
$dnsResults = @()
#set change counter var
$changeCount = 0
#set and check DNS Server Hostname
$dnsServer = read-host "Enter DNS Server Name"
if ($(Test-Connection -Computername $dnsServer -count 1 -Quiet) -ne "True" ) {
write-host "The DNS server name you typed is invalid or there is no connection" -ForegroundColor "red"
Return
}
#Set DNS zone
$zone = read-host "Enter DNS Zone Name"

#Takes the changed IPs from the dnsReplace.ps1 script and reverses the process
$csv | ForEach-Object {
    $serverName = $_.Name
    $recordType = $_.recordType
    $newIP = $_.OldAddress
    $oldIP = $_.NewAddress

    #DNS Changes
    dnscmd $dnsServer /RecordDelete $zone $serverName A /f
    dnscmd $dnsServer /RecordAdd $zone $serverName A $newIP    
    #shell output
    write-host $serverName " / " $oldIP "DNS entry changed back to " $newIP -ForegroundColor "green"
    $ChangeCount ++
    #sets psobject for the csv output
    $dnsResults += New-Object PSObject -Property @{Name=$serverName;RecordType=$recordType;OldAddress=$oldIP;NewAddress=$newIP}

}
Write-Host "--------------------------"
Write-Host "Changes made: $changeCount"
Write-Host "--------------------------"
#export changes to csv
$dnsResults | select Name, Recordtype, NewAddress, OldAddress | Export-Csv -NoTypeInformation .\dnsReversed.csv