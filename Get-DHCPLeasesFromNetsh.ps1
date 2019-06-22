<#
    .SYNOPSIS
        Uses Netsh to query for active DHCP leases.

    .DESCRIPTION
        Uses Netsh to query for active DHCP leases.

    .PARAMETER server
        The name of the server to query

    .PARAMETER subnet
        A portion of the subnet used to filter the results

    .EXAMPLE
        Get-DHCPLeasesFromNetsh -server "JomoDc01" -subnet "10."

        Retreives all of the leases (hostname and IP) from JomoDc01.

    .FUNCTIONALITY
        Network
#>

Function Get-DHCPLeasesFromNetsh{
    Param (
            # The server we are querying
            [Parameter(Mandatory=$true)][string] $server,
            # A portion of the expected subnet to filter by. For example 172.17 or 10.16
            [Parameter(Mandatory=$true)][string] $subnet
        )

        $scope = ((netsh dhcp server \\$server show scope | ? { $_ -match $subnet }) -split '\s' | ? { $_ -notmatch '\s'})[1];
        netsh dhcp server \\$server scope $scope show clients 2 | ? { $_ -match $subnet } | ? { $_ -match '255'}|  % { 
            $splits = $_ -split '\s';
            $ip = $splits[0];
            $workstation = $splits[$splits.count-1];
            Write-Host "$ip - $workstation";
        }


}




