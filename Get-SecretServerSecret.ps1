# SecretServre can rotate passwords which is great, until you need them during an outage
# At which time logging in and searching for a secret in the UI is not satisfactory...

function Get-SecretServerSecret{
  param
  (
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$secretName,
      [switch]$clip
  )
    ## Input the correct endpoint
    $endpoint = 'http://SecretServerSuperSecretURL/winauthwebservices/sswinauthwebservice.asmx'
    $ws = New-WebServiceProxy -uri $endpoint -UseDefaultCredential
    $secretId = $ws.SearchSecrets($secretName,$false,$false) | select -ExpandProperty SecretSummaries | select -ExpandProperty secretid
    $secretObj = $ws.GetSecret($secretId, $true, $null)
    $password = $secretObj.Secret.Items | ? { $_.ispassword -match $true } | select -ExpandProperty value
    
    if($clip -eq $true){
        $password | clip
    }

    write-host "$password"

}
