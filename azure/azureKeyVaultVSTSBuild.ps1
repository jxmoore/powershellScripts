<#

    The main purpose and function of this script is to seed key vault with the secret process/build variables that are
    stored within VSTS. All of these variables are passed in as parameters as they are encrypted and thus not enviroment variables. 
    
    This script also :
        * Finds the vault from the previous build step and creates a new process/build variable for it 
        * Creates a build/process variable for the vault ResourceID 
        * Creates the random SQLAdmin userid and password 
        * Creates a secret for the storage connection string, SAS key and the redis connection string
        * Any non encrypted variables with a prefix that matches 'JomoDeploy.' are added to key vault.

#>

$envSearch = $env:envsearchstring; # this is used to easily find all the enviroment variables that match our pattern. See line 63
$Vault = Find-AzureRmResource -ResourceType "Microsoft.KeyVault/vaults" | ? { $_.name -match "-$envSearch" } |  select -First 1;

if (!$Vault) {
    Write-Output "$(get-date) :: Vault not found exiting" ; exit;
} 

else { 
  $resID =  Get-AzureRmKeyVault -vaultName $vault.name | select -ExpandProperty "ResourceID";
  $vaultName = $Vault.Name;

  # This creates/sets variables in VSTS/AzureDevOps 
  Write-Host "##vso[task.setvariable variable=VaultID]$resID";
  Write-Host "##vso[task.setvariable variable=vaultName]$vaultName";
}
Write-Output "$(get-date) :: Vault $vaultName found, variables added.";

Write-Output "$(get-date) :: Creating username/password for VM and SQL Server...";
$sqlAdmin = (([char[]](65..90+97..122) | Get-Random -Count 11) -Join '');
$vmAdmin = (([char[]](65..90+97..122) | Get-Random -Count 11) -Join '');
$char = $null ; $sqlPass = $null ; $vmPass = $null;

# Some char exclusions
For ($a=33;$a –le 126;$a++) { 

    if( ($a -ne 34) -and ($a -ne 47) -and ($a -ne 92)-and ($a -ne 59)-and ($a -ne 58) -and 
        ($a -ne 96) -and ($a -ne 39) -and ($a -ne 44) -and ($a -ne 46)){  
       $char+=,[char][byte]$a;
    }

} ; 0..21 | % { $sqlPass+=($char | Get-Random ) } ; 0..21 | % { $vmPass +=($char | Get-Random ) }

Set-AzureKeyVaultSecret -vaultName $vaultName -Name 'VM-Admin-User' `
                        -SecretValue $( $vmAdmin | ConvertTo-SecureString -AsPlainText -Force)`
                        -ContentType "VM Admin username";
Set-AzureKeyVaultSecret -vaultName $vaultName -Name 'VM-Admin-Password' `
                        -SecretValue $( $vmPass | ConvertTo-SecureString -AsPlainText -Force)`
                        -ContentType "Vm admin password";
Set-AzureKeyVaultSecret -vaultName $vaultName -Name 'SqlServerUser' `
                        -SecretValue $( $sqlAdmin | ConvertTo-SecureString -AsPlainText -Force)`
                        -ContentType "Sql server admin";
Set-AzureKeyVaultSecret -vaultName $vaultName -Name 'SQLServerPassword' `
                        -SecretValue $( $sqlPass | ConvertTo-SecureString -AsPlainText -Force)`
                        -ContentType "Sql server admin";

Write-Output "$(get-date) :: Keys created for SQL/VM admin username and password...`n Adding the process variables to vault.";


$envVariables = Get-ChildItem Env: | ? {$_.name -match '^JomoDeploy.'}
foreach($envVariable in $envVariables){
    $keyname = $envVariable.name -replace("JomoDeploy.",""); #remove dummy prefix
    $value = $envVariable.value;
    Write-Output "Creating $keyname";
    Set-AzureKeyVaultSecret -vaultName $vaultName -Name $keyname `
                            -SecretValue $( $value | ConvertTo-SecureString -AsPlainText -Force);
}

Write-Output "$(get-date) :: Adding WorkSpace information to Vault";
$oms = Find-AzureRmResource -ResourceType "microsoft.operationalinsights/workspaces" | ? { $_.name -match "-$envSearch" } |  select -First 1;
if(!($oms)) { Write-Output "$(get-date) :: No Log Analytics resource found.`nThis will need to be configured as its used for patching the VMS and logging." } 
else { 
    $workspaceID = (Get-AzureRmOperationalInsightsWorkspace -resourceGroupName $oms.resourceGroupName -Name $oms.Name).customerID.guid;
    $key = Get-AzureRmOperationalInsightsWorkspaceSharedKeys  -Name $oms.Name -resourceGroupName $oms.resourceGroupName | select -ExpandProperty PrimarySharedKey;

    Set-AzureKeyVaultSecret -vaultName $vaultName -Name 'WorkSpace-ID' `
                        -SecretValue $( $workspaceID | ConvertTo-SecureString -AsPlainText -Force); 

    Set-AzureKeyVaultSecret -vaultName $vaultName -Name 'WorkSpace-Key' `
                        -SecretValue $( $key | ConvertTo-SecureString -AsPlainText -Force);
 }


# Add the redis connection string to the vault
Write-Output "$(get-date) :: Adding redis connection string to the vault...";
$redis = Find-AzureRmResource -ResourceType "Microsoft.Cache/Redis" -ErrorAction SilentlyContinue | ? { $_.name -match "-$envSearch" } | select -First 1
if($redis) {
    $redis = Get-AzureRmRedisCache -Name $Redis.name -ResourceGroupName $redis.resourceGroupName;
    $redisKeys = Get-AzureRmRedisCacheKey -Name $redis.name -ResourceGroupName $redis.ResourceGroupName;
    $redisConnectionString = "$($redis.Name).redis.cache.windows.net:$($redis.sslPort),password=$($redisKeys.PrimaryKey),ssl=True,abortConnect=False";

    Set-AzureKeyVaultSecret -VaultName $vaultname -Name "RedisConnectionString" `
                            -SecretValue $( $redisConnectionString | ConvertTo-SecureString -AsPlainText -Force)`
                            -ContentType "Redis connection string";
}

else{
    Write-Output "Unable to locate a Redis cache in the subscription using $envSearch.`nThe Redis key was not created.";
}

# Create containers and add SAS token to keyvault
Write-Output "$(get-date) :: Creating storage containers and containers...";
$storage = Find-AzureRmResource -ResourceType "Microsoft.Storage/storageAccounts" -ErrorAction SilentlyContinue | ? { $_.name -match "^$envsearch" } | select -First 1;
if($Storage) {
    StorageConnectionString -vaultname $vault -storageRG $storage.ResourceGroupName -storageName $storage.Name ;
    $storageKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $storage.ResourceGroupName -Name $storage.Name; 
    $ctx = New-AzureStorageContext -StorageAccountName $storage.Name -StorageAccountKey $($storageKeys[0].Value);

    #Created for webapps logs
    New-AzureStorageContainer -Name "web-logs" -Context $ctx; 
    New-AzureStorageContainer -Name "app-logs" -Context $ctx;
 
    $sasToken = New-AzureStorageContainerSASToken -Container dsc -Permission rwdl -Context $ctx -ExpiryTime $(get-date).AddDays(90) -StartTime $(get-date);
    Set-AzureKeyVaultSecret -VaultName $vault -Name "Storage-SAS-Token" `
                        -SecretValue $( $sasToken | ConvertTo-SecureString -AsPlainText -Force);

    Set-AzureKeyVaultSecret -VaultName $vaultname -Name "$storageName-Connection-String" `
                            -SecretValue $( $storageConnectionString | ConvertTo-SecureString -AsPlainText -Force)`
                            -ContentType "Storage account connection string";
    Set-AzureKeyVaultSecret -VaultName $vaultname -Name "$storageName-Primary-key" `
                            -SecretValue $( $($storageKeys[0].Value) | ConvertTo-SecureString -AsPlainText -Force)`
                            -ContentType "Storage account key";

    # Each app gets its own secret for the connection string 
    $connectionStrings = "jomo2-storageConString","jomo2-storageConString","jomo3-storageConString",
                         "jomo4-storageConString","jomo5-storageConString";
    $connectionStrings | % { 
                    Set-AzureKeyVaultSecret -VaultName $vaultname -Name $_ `
                            -SecretValue $( $storageConnectionString | ConvertTo-SecureString -AsPlainText -Force)`
                            -ContentType "Storage account connection string";
    }

}

else {
    Write-Output "Unable to locate a storage account in the subscription using $envSearch.
                 `nThe containers and secrets were not created."
}


Write-Output "$(get-date) :: Script complete...";
