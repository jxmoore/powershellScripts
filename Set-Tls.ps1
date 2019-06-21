<#
    .SYNOPSIS
        Enforces TLS 1.2

    .DESCRIPTION
        Enforces TLS 1.2

    .EXAMPLE
        Set-TLS1.2();

        Enforces TLS1.2 in the current shell.
    
    .FUNCTIONALITY
        Networking
    
    .NOTES
        This will prevent the error 'connection was forcibily closed' when using invoke-webrequest against an endpoint which only 
        supports TLS 1.2
#>

function Set-TLS1.2(){

    Write-Host "Setting TLS 1.2 -- [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12";
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

}