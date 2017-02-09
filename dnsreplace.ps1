<#
Script by: Scott Forsyth
Email: script@nurvox.com

USE: Replace IP octet on large number of DNS files from a windows server 2008/2012 DNS export CSV

- You should have the original export list
- Run script (to test run with "-whatif" at the end of line 34

-output is on shell and in CSV with changes made

-to reverse run the DNSreverse.ps1 script
#>

Get-Module DNSServer
$csv = Import-CSV .\dnstest.csv
$dnsResults = @()
$changeCount = 0
#$dnsServer = "dc_server_name"
#$zone = "dns.zone"


$csv | ForEach-Object {
    $serverName = $_.Name
    $recordType = $_.Type
    $oldIP = $_.data
    if ( $_.data -as [ipaddress] ) {
        $currentIP = $_.data.split('.')
        if ( ($currentIP[1] -eq "24" ) -and ($currentIP[0] -eq "10") ) {
            $newIP = $currentIP[0],25,$currentIP[2],$currentIP[3] -join '.'
            if ( ($csv.Where({$_.Name -eq $serverName}).Data) -notcontains $newIP ) {
                $_.data = $newIP
                write-host $_.name " / " $_.data "DNS entry changed" -ForegroundColor "green"
                $dnsResults += New-Object PSObject -Property @{Name=$serverName;RecordType=$recordType;OldAddress=$oldIP;NewAddress=$newIP}
                <#
                $new.RecordData.IPv4Address = [System.Net.IPAddress]::parse($newIP)
                $new = $old = Get-DnsServerResourceRecord -ComputerName $dnsServer -ZoneName $zone -Name $serverName
                Set-DnsServerResourceRecord -NewInputObject $new -OldInputObject $old -ZoneName $zone -ComputerName $dnsServer
                #>
                $ChangeCount ++
            } else {
                write-host $_.name " / " $_.data "Exsist - No Change" -ForegroundColor "red"
            }
        }
    }
 
}
Write-Host "--------------------------"
Write-Host "Changes made: $changeCount"
Write-Host "--------------------------"
$dnsResults | select Name, Recordtype, OldAddress, NewAddress | Export-Csv -NoTypeInformation .\dnsResults.csv