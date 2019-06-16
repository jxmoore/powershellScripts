<# 
  Very simple script that is run inside VSTS and transforms the keyvault resource ID in the template parameters reference section 
  Using an env variable set in a previous step. The portion changed looks like : 

        "adminPassword": {
            "reference": {
              "keyVault": {
                "id": "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.KeyVault/vaults/<vault-name>"
              },
              "secretName": "ExamplePassword"
            }
        }
#>

$newID = $env:VaultID; # ENV variable from VSTS
$file = "$(Build.SourcesDirectory)\ARM Templates\azuredeploy.parameters.json"; # Original file
$file2 = "JSONdump$(Get-Random -Maximum 40000).json"; # TMP

(Get-Content -Path $file ) | Foreach-Object {
    if ( $_ -match "providers/Microsoft.KeyVault/vaults" ) {
@" 
    "id": "$newID"
"@ | Out-File .\$file2 -Append;


    } 
    else {  $_ | Out-File .\$file2  -Append ; }
}

# Just overwrite the original 
Copy-Item .\$file2  -Destination $file -Force;
