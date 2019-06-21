# Create a snapshot from a vhd located outside of the subscription.

Function New-SnapshotFromRemoteVHD(){
Param (
        [Parameter(Mandatory=$true)][string] $subscriptionID,
        [Parameter(Mandatory=$true)][string] $resourceGroupName,
        [Parameter(Mandatory=$false)][string] $storageType = 'StandardLRS'
        [Parameter(Mandatory=$false)][string] $location = 'westus'
        [Parameter(Mandatory=$true)][string] $sourceVHDURI,
        [Parameter(Mandatory=$true)][string] $storageAccountResId, 
        [Parameter(Mandatory=$true)][string] $snapshotName
    )

    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId;
    $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $location -CreateOption Import `
                                        -StorageAccountId $storageAccountResId -SourceUri $sourceVHDURI;
    New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName;

}