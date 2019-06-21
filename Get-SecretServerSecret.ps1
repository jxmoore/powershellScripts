<#
    .SYNOPSIS
        Finds a secret in Secret Server and retreives the secret value

    .DESCRIPTION
        Finds a secret in Secret Server and retreives the secret value

    .PARAMETER secretName
        The name of the secret in secret server.

    .PARAMETER endpoint
        The winauthwebservice.asmx endpoint on your Secret Server instance.

    .PARAMETER clip
        A switch parameter that, when used, copies the secret value to the clipboard.

    .EXAMPLE
        Get-SecretServerSecret -SecretName "LocalAdminPass" -endpoint "https://joboSecretVault.com/winauthwebservices/sswinauthwebservice.asmx" -clip
        
        Pulls the secret value for "LocalAdminPass" from the specified Secret Server instance and pipes it to the clipboard.

    .FUNCTIONALITY
        Other/Network
        
#>
function Get-SecretServerSecret{
  param
  (
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$secretName,
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$endpoint, 
      [switch]$clip
  )

    $ws = New-WebServiceProxy -uri $endpoint -UseDefaultCredential
    $secretId = $ws.SearchSecrets($secretName,$false,$false) | select -ExpandProperty SecretSummaries | select -ExpandProperty secretid
    $secretObj = $ws.GetSecret($secretId, $true, $null)
    $password = $secretObj.Secret.Items | ? { $_.ispassword -match $true } | select -ExpandProperty value
    
    if($clip -eq $true){
        $password | clip
    }

    write-host "$password"

}
