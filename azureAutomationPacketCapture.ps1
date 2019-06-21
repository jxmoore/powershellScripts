## Small AA runbook for creating setting up and running packet captures on VMS.

[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$subscription,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$vmNane,
[Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$resourceGroup,
[Parameter(Mandatory=$true)][string]$storageAccountName,
[Parameter(Mandatory=$true)][string]$storageAccountResourceGroup,
[Parameter(Mandatory=$false)][int]$capTime = 240


$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
Select-AzureRmSubscription -SubscriptionName $subscription

$vmInfo = Get-AzureRmVM -ResourceGroupName $resourceGroup -Name $vmNane -ErrorAction SilentlyContinue
if(!($vmInfo)){ 
	Write-Output "Error locating VM $vmNane";
} 
else {	
	Set-AzureRmVMExtension -ResourceGroupName $resourceGroup `
						   -Location $vmInfo.Location -VMName $vmNane `
						   -Name "networkWatcherAgent" -Publisher "Microsoft.Azure.NetworkWatcher" `
						   -Type "NetworkWatcherAgentWindows" -TypeHandlerVersion "1.4"
	
	if(!($?)){ 
		Write-Output "Error installing agent"; 
		exit;
	}

}

$nw = Get-AzurermResource | Where {$_.ResourceType -eq "Microsoft.Network/networkWatchers" -and $_.Location -eq $vmInfo.Location}
$storageAccount = Get-AzStorageAccount -ResourceGroupName $storageAccountResourceGroup -Name $storageAccountName -ErrorAction SilentlyContinue
if(!($storageAccount)){
    write-error "Unable to locate storage..."; 
    exit;
} 

$packetCaptureName = "$vmNane-Capture";
$networkWatcher = Get-AzureRmNetworkWatcher -Name $nw.Name -ResourceGroupName $nw.ResourceGroupName;
$packetCaptures = Get-AzureRmNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher -ErrorAction SilentlyContinue;
$packetCaptures | %{ 
	if ($_.Name -eq $packetCaptureName){ 
			Remove-AzureRmNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher -PacketCaptureName $packetCaptureName;
	}
}

New-AzureRmNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher -TargetVirtualMachineId $vmInfo.Id `
										-PacketCaptureName $packetCaptureName -StorageAccountId $storageAccount.ID `
										-TimeLimitInSeconds $capTime 
