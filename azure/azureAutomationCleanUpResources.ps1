   # Simple AA runbook that would clean up behind developers who were creating vms
   # The problem was just general sprawl, VMS would be created and deleted but the 
   # Resources like nics would be left to fester until an admin found and deleted them. The same can be said for RG'S 
   
Param(
        # Bools just determine whats removed.
        [Parameter(Mandatory=$true)] [bool]$removeInterfaces,
        [Parameter(Mandatory=$true)] [bool]$removeDisk,
        [Parameter(Mandatory=$true)] [string]$subscriptionId,
        [Parameter(Mandatory=$true)] [bool]$removeEmptyResGroups
)

$Conn = Get-AutomationConnection -Name AzureRunAsConnection;
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
Select-AzureRmSubscription -SubscriptionId $SubscriptionId;

$nics = Get-AzureRmNetworkInterface | ? { $_.virtualmachine -eq $null} | select name, ResourceGroupName;
$disks = Get-AzureRmDisk ; $disks = $disks | ? { !($_.OwnerId) } | select Name, ResourceGroupName;
$RGS = Get-AzureRmResourceGroup | ? { 
                                ( $( Find-AzureRmResource -ResourceGroupNameContains $_.ResourceGroupName).count -eq 0) 
                                } | select -ExpandProperty ResourceGroupName;
$resources=@();
foreach($nic in $nics){ 
        $obj = New-Object -TypeName psobject;
        $obj | Add-Member -NotePropertyName "Type" -NotePropertyValue "Nic";
        $obj | Add-Member -NotePropertyName "Name" -NotePropertyValue $nic.Name;
        $obj | Add-Member -NotePropertyName "ResourceGroup" -NotePropertyValue $nic.ResourceGroupName;
        $resources+=$obj;
        if($removeInterfaces) {
                Remove-AzureRmNetworkInterface -Name $nic.name -ResourceGroupName $nic.ResourceGroupName -Force -Confirm:$False;
                Write-output " $($nic.name) was removed from $($nic.resourcegroupname)";
        }

}
foreach($disk in $disks){ 
        $obj = New-Object -TypeName psobject;
        $obj | Add-Member -NotePropertyName "Type" -NotePropertyValue "Disk";
        $obj | Add-Member -NotePropertyName "Name" -NotePropertyValue $disk.Name;
        $obj | Add-Member -NotePropertyName "ResourceGroup" -NotePropertyValue $disk.ResourceGroupName;
        $resources+=$obj;
        if($removeDisk) {
                Remove-AzureRmDisk -DiskName $disk.name -ResourceGroupName $disk.resourcegroupname -Force -Confirm:$false;
                Write-output "$($disk.name) was removed from $($disknic.resourcegroupname)";
        }
}

foreach($RG in $RGS){ 
                $obj = New-Object -TypeName psobject;
                $obj | Add-Member -NotePropertyName "Type" -NotePropertyValue "Empty Resource Group";
                $obj | Add-Member -NotePropertyName "Name" -NotePropertyValue $RG;
                $obj | Add-Member -NotePropertyName "ResourceGroup" -NotePropertyValue $RG;
                $resources+=$obj;
        if($removeEmptyResGroups) {
                Remove-AzureRmResourceGroup -Name $RG -Force -Confirm:$false;
                Write-output "$rg was removed";
        }
}


Write-output $resources;

    