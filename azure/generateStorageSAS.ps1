## Small script for generating Azure storage container sas tokens.

Param (
        [string] $storageAccount,
        [string] $resourceGroupName,
        [string] $spnPassword,
        [string] $spnID,
        [string] $tenant,
        [string] $subscriptionId
    )


	   
	   
	   
# alternativly we could run this interactively and provide creds.
$azurePassword = ConvertTo-SecureString $spnPassword -AsPlainText -Force;
$psCred = New-Object System.Management.Automation.PSCredential($spnID, $azurePassword);
try {
    Login-AzureRmAccount -Credential $psCred -TenantId $tenant -ServicePrincipal -SubscriptionId $subscriptionId;
}
catch {
    Write-Error "$(get-date) :: Error logging into Azure Subscription $subscriptionID.";
    exit(1);
}
$st = Get-AzureRmStorageAccount -StorageAccountName $storageAccount -ResourceGroupName $resourceGroupName  -ErrorAction SilentlyContinue;
if($st -eq $null){
    write-error "$(get-date) :: Could not access storage account : $storageAccount";
    exit(1);
}
else{
    $context = $st.Context;
    $keys = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $context;
    $storageKey = $keys[0].Value;
}

$blobContainers = "httplogs","weblogs","applogs";
foreach($blobContainer in $blobContainers){
   	$container = $null;
	$container = Get-AzureStorageContainer -Name $blobContainer -Context $context -ErrorAction SilentlyContinue;
	if($container -match $null)	{
		Write-Output "$(get-date) :: $blobContainer is not in $storageAccount";
	}
	else{
		Write-Output "$(get-date) :: Creating sas token for $blobContainer.";       
        $expiryDate = (Get-Date).AddYears(1);
        $token = $container | New-AzureStorageContainerSASToken -Permission rwdl -ExpiryTime $expiryDate;
        $fullURI = $container | New-AzureStorageContainerSASToken -Permission rwdl -ExpiryTime $expiryDate -FullUri;

        Write-Output "$(get-date) :: $blobContainer : $token";
        Write-Output "$(get-date) :: $blobContainer : $fullURI";
	}
}


