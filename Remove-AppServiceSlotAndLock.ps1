<#
    .SYNOPSIS
        This removes a lock on an app service and its slot if there is one and then removes the slot. 

    .DESCRIPTION
        This removes a lock on an app service and its slot if there is one and then removes the slot. 

   .PARAMETER appService
        The name of the app service

   .PARAMETER stagingSlotName
        The name of the slot

   .PARAMETER resourceGroupName
        The resourcegroup that holds the app services.

   .PARAMETER subscriptionId
        The subscription id for the App services.

    .FUNCTIONALITY
        Azure

#>

Function Remove-AppServiceSlotAndLock{


    Param (
            # The name of the app service
            [string] $appService,
            # The name of the slot
            [string] $stagingSlotName = "staging",
            # The name of the resource group that the app service is in 
            [string] $resourceGroupName,
            # The id of the subscription that the app service is in.
            [string] $subscriptionId
        )


    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
    Select-AzureRmSubscription -SubscriptionId $SubscriptionId;

    Write-Host "$(get-date) :: Removing resource locks...";
    Get-AzureRmResourceLock  -ResourceName "$appService" -ResourceType "microsoft.web/sites" -ResourceGroupName $resourceGroupName | Remove-AzureRmResourceLock -Force;

    Write-Host "$(get-date) :: Removing slot...";
    Remove-AzureRmWebAppSlot -Name $appService -Slot $stagingSlotName  -ResourceGroupName $resourceGroupName -Force -Confirm:$false;

}
