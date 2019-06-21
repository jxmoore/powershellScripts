<#
    .SYNOPSIS
        Gets all of the CNAME records in DNS for a given hostname

    .DESCRIPTION
        Gets all of the CNAME records in DNS for a given hostname

    .PARAMETER serverName
        The server that we want the CNAME records for.

    .EXAMPLE
        Get-ServerAlias -serverName "VirPDC01";

        Prints all of the CNAME records in DNS for the server named "VirPDC01"

    .FUNCTIONALITY
        Networking
    
    .NOTES
        The script requires the DNS module for powershell. 
#>

function Get-ServerAlias{
     
    Param (
            # The name of the server that we will be using to query DNS. 
            [Parameter(Mandatory=$true)][string] $serverName
    )
    
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
