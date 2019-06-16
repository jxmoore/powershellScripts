# updates an availability set to managed and converts the VM disks to managed.

Login-AzureRmAccount;
Select-AzureRmSubscription -SubscriptionName $subscriptionID;
$resourceGroup = 'JomoResorceGroup';
$availabilitySetName = 'availabilitSet1';

$availabilitySet =  Get-AzureRmAvailabilitySet -ResourceGroupName $resourceGroup -Name $availabilitySetName
Update-AzureRmAvailabilitySet -AvailabilitySet $availabilitySet -Managed

foreach($vmInfo in $availabilitySet.VirtualMachinesReferences){
   $vm =  Get-AzureRmVM -ResourceGroupName $resourceGroup | ? {$_.Id -eq $vmInfo.id}
   Stop-AzureRmVM -ResourceGroupName $resourceGroup -Name  $vm.Name -Force;
   ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $resourceGroup -VMName $vm.Name -confirm:$false;
   Start-AzureRmVM -ResourceGroupName $resourceGroup -Name $vm.Name;
}