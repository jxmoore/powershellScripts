# The issue arouse that database servers had countless CNAME records and the DBA
# Team had lost track of what aliases a specific server was using. 
# Super simple script that looks for CNAMES that exist for a single hostname

function Fetch-ServerAlias ($serverName)
{
    # domainController = "someDc.local";
    $domainController = [string]$($env:LOGONSERVER -split "\\"); $domainController = $domainController.TrimStart();
    Get-DnsServerZone -ComputerName $domainController | select -ExpandProperty zonename | % {
        #Write-Host "`nSearching in zone $_ :";
        $records = Get-DnsServerResourceRecord -RRType CName -ComputerName $domainController -ZoneName $_ `
            | ? { $_.RecordData.HostNameAlias -match $serverName } | select -ExpandProperty HostName;
        
        if($records){ 
            foreach($record in $records){
                write-host $record;
            } 

        }

        Else{ 
            Write-host "No records found.";
        }
    }
}
