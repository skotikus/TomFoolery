
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