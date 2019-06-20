# Enabling and using Tls 1.2 so we dont get hit with the unexpected error on send:
# Invoke-WebRequest : The underlying connection was closed: An unexpected error occurred on a send
# Simply because i cant remember the syntax to call this when i need to. 
function Set-TLS1.2(){

    Write-Host "Setting TLS 1.2 -- [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12";
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
}