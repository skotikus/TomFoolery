<#
Script by: Scott Forsyth
Email: script@nurvox.com

USE: The revese of dnsreplace.ps1 script (used to replace IP octet on large number of DNS files from a windows server 2008/2012 DNS export CSV)

- after running this you should have 4 CSV files (the original, the dnsreplaced CSV, the dnsrevsed CSV, and a new copy of the export to run diffs on)

- Run script (to test run with "-whatif" at the end of line 34

-output is on shell and in CSV with changes made

#>



#Get-Module DNSServer
$csv = Import-CSV .\dnsResults.csv
$dnsResults = @()
$changeCount = 0
#$dnsServer = "dc_server_name"
#$zone = "dns.zone"


$csv | ForEach-Object {
    $serverName = $_.Name
    $recordType = $_.recordType
    $newIP = $_.OldAddress
    $oldIP = $_.NewAddress

    <#
    $newDNS.RecordData.IPv4Address = [System.Net.IPAddress]::parse($newIP)
    $newDNS = $oldDNS = Get-DnsServerResourceRecord -ComputerName $dnsServer -ZoneName $zone -Name $serverName
    Set-DnsServerResourceRecord -NewInputObject $newDNS -OldInputObject $oldDNS -ZoneName $zone -ComputerName $dnsServer
    #>

    write-host $serverName " / " $oldIP "DNS entry changed to " $newIP -ForegroundColor "green"
    $ChangeCount ++
    $dnsResults += New-Object PSObject -Property @{Name=$serverName;RecordType=$recordType;OldAddress=$oldIP;NewAddress=$newIP}

}
Write-Host "--------------------------"
Write-Host "Changes made: $changeCount"
Write-Host "--------------------------"
$dnsResults | select Name, Recordtype, NewAddress, OldAddress | Export-Csv -NoTypeInformation .\dnsReversed.csv