<#
    .SYNOPSIS
        Create a snapshot from a vhd located outside of the subscription.

    .DESCRIPTION
        Create a snapshot from a vhd located outside of the subscription.

   .PARAMETER subscriptionId
        The ID of the subscription that will hold the snapshot.

   .PARAMETER resourceGroupName
        The resourcegroup were the snapshot will be stored.

   .PARAMETER storageType
        The type of storage (LRS, GRS, etc..)

   .PARAMETER location
        The azure region location (westus, eastus etc..)

   .PARAMETER sourceVHDURI
        The uri for the source VHD.

   .PARAMETER storageAccountResId
        The resource ID for the storage account.

   .PARAMETER snapshotName
        The name of the snapshot.

    .FUNCTIONALITY
        Azure

    .TODO
        There are many ways this could be improved upon when there is time:
            * storage resourceID should be removed, in replace for storage name, the resource id should be pulled in via cmdlets
            * vhdUri should be pulled automatically on requiring name of the VHD and storage account.
            * Location could be rg location.
#>

Function New-SnapshotFromRemoteVHD{
Param (
        [Parameter(Mandatory=$true)][string] $subscriptionId,
        [Parameter(Mandatory=$true)][string] $resourceGroupName,
        [Parameter(Mandatory=$false)][string] $storageType = 'StandardLRS',
        [Parameter(Mandatory=$false)][string] $location = 'westus',
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
