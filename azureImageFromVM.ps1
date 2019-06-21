# Creating Images from VM'S was a common task.
# This small script just does it quickly via powershell.

Function New-ImageFromVm(){
Param (
        [Parameter(Mandatory=$true)][string] $vmName,
        [Parameter(Mandatory=$true)][string] $vmrgName,
        [Parameter(Mandatory=$true)][string] $imageRgName,
        [Parameter(Mandatory=$true)][string] $imageName,
        [Parameter(Mandatory=$true)][string] $resourceGroupName,
        [Parameter(Mandatory=$true)][string] $subscriptionId,
        [Parameter(Mandatory=$false)][string] $location="WestUS2"
    )

    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount}
    Select-AzureRmSubscription -SubscriptionId $subscriptionId;

    Stop-AzureRmVM -ResourceGroupName $vmrgName -Name $vmName -Force;
    Set-AzureRmVm -ResourceGroupName $vmrgName -Name $vmName -Generalized;

    $vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $vmrgName;
    $image = New-AzureRmImageConfig -Location $location -SourceVirtualMachineId $vm.ID;
    New-AzureRmImage -Image $image -ImageName $imageName -ResourceGroupName $imageRgName;

}