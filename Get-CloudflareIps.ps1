<#
    .SYNOPSIS
        Retrieves the IPV4 CIDR ranges for CloudFlare.

    .DESCRIPTION
        Retrieves the IPV4 CIDR ranges for CloudFlare.

    .EXAMPLE
        $CIDR = Get-CloudFlareIps;

        Gets the Cidr blocks and stores them in a variable named CIDR.

    .FUNCTIONALITY
        Network
#>

function Get-CloudflareIps(){
    return $( (Invoke-WebRequest -Uri "https://www.cloudflare.com/ips-v4" | select -ExpandProperty Content) -split '\n');
}

