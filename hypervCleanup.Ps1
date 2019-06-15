# Hyper-V leaves behind some files when a VM is deleted - HD, artifacts in the root.
# This just removes those and the VM at once.

# Write-Highlight is a command provided by Octopus deploy, this was integrated into a CI/CD pipeline for destroying
# And re-creating enviroments.

$vmNames = "FedoraPowerVM01","asd";
foreach($vmName in $vmNames){
    
    $hypervVM = get-vm -Name $vmName -ErrorAction SilentlyContinue;

    if ($hypervVM){
        $hardDrive = $hypervVM.HardDrives.path;
        $rootPath = $hypervVM.path;
        write-highlight "$(get-date) :: Shutting down $vmName...";
        Stop-VM -Name $hypervVM.Name -TurnOff -Force;
        Start-Sleep -Seconds 30;
        write-highlight "$(get-date) :: Removing $vmName...";
        Remove-VM -Name $hypervVM.Name -Force -Confirm:$false;
        write-highlight "$(get-date) :: The VHD that will be removed is : $hardDrive";
        write-highlight "$(get-date) :: The Directory that will be removed is : $rootPath...";
        Remove-Item -Path $hardDrive -Force -Confirm:$false;
        Remove-Item -Path $rootpath -Force -Recurse -Confirm:$false;
    }
    else {
        Write-Error "$(get-date) :: The VM $vmName was not found...";
    }

}
