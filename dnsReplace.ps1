<#
script: dnsReplace.ps1

Script by: Scott Forsyth

Email: forsyths@sec.gov

Last Modified: 2/9/2017

USE: Replace IP octet on large number of DNS files from a windows server 2008/2012 DNS export CSV
- You should have the original export list
-output is on shell and in CSV with changes made
-to reverse run the DNSreverse.ps1 script
quick and dirty, little error handling. Will fix later

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


#name of import CSV
$csvname = Get-FileName "$env:USERPROFILE"
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

$csv | ForEach-Object {
    $serverName = $_.Name
    $recordType = $_.Type
    $oldIP = $_.data
    if ( $_.data -as [ipaddress] ) {
        #Split the IP into 4 parts
        $currentIP = $_.data.split('.')
        
        #check that first octet is 172 and second is 24 (the one to change)
        if ( ($currentIP[1] -eq "24" ) -and ($currentIP[0] -eq "172") ) {
            
            #change the second octet to 25 and rejoin the ip address together
            $newIP = $currentIP[0],25,$currentIP[2],$currentIP[3] -join '.'
            
            #check to make sure the newly changed IP dosn't already exist in the DNS
            if ( ($csv.Where({$_.Name -eq $serverName}).data) -notcontains $newIP ) {
                #$_.data = $newIP
                
                #output to psobject for later export to CSV for reporting
                $dnsResults += New-Object PSObject -Property @{Name=$serverName;RecordType=$recordType;OldAddress=$oldIP;NewAddress=$newIP}
                
                #DNS Changes
                dnscmd $dnsServer /RecordDelete $zone $serverName A /f
                dnscmd $dnsServer /RecordAdd $zone $serverName A $newIP
                
                #shell output
                write-host $_.name " / " $_.data "DNS entry changed" -ForegroundColor "green"
                $ChangeCount ++

            } else {
                write-host $_.name " / " $_.data "Exsist - No Change" -ForegroundColor "darkyellow"
            }
        }
    }
 }

Write-Host "--------------------------"
Write-Host "Changes made: $changeCount"
Write-Host "--------------------------"
#export changes to csv
$dnsResults | select Name, Recordtype, OldAddress, NewAddress | Export-Csv -NoTypeInformation .\dnsResults.csv