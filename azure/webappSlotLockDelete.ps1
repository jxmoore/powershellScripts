### This should remove a lock on a azure app service slot, remove the partent lock on the app service and then delete the slot. 


Param (
        [string] $appService,
        [string] $stagingSlotName = "staging",
        [string] $resourceGroupName,
        [string] $clientID,
        [string] $clientSecret,
        [string] $tenant,
        [string] $subscriptionId
    )


Write-Host "$(get-date) :: Authenticating into azure...";
$cred = new-object -typename System.Management.Automation.PSCredential `
         			-argumentlist $clientID, ($clientSecret | ConvertTo-SecureString -AsPlainText -Force);

## Login-azurermaccount
Login-AzureRmAccount -Credential $cred  -ServicePrincipal -TenantId $tenant;
Select-AzureRmSubscription -SubscriptionId $subscriptionId;

Write-Host "$(get-date) :: Removing resource locks...";
Get-AzureRmResourceLock -LockName "DontDeleteIntSlot" -ResourceName "$appService" -ResourceType "microsoft.web/sites" -ResourceGroupName $resourceGroupName | Remove-AzureRmResourceLock -Force;
Get-AzureRmResourceLock -LockName "DontDeleteIntSlot" -ResourceName "$appService/$stagingSlotName " -ResourceType "microsoft.web/sites/slots" -ResourceGroupName $resourceGroupName | Remove-AzureRmResourceLock -Force;

Write-Host "$(get-date) :: Removing slot...";
Remove-AzureRmWebAppSlot -Name $appService -Slot $stagingSlotName  -ResourceGroupName $resourceGroupName -Force -Confirm:$false;