<#
    .SYNOPSIS
        This cleans up old hyper-v vm deployments, removing the disk, the path that it was in and the vm itself

    .DESCRIPTION
        This cleans up old hyper-v vm deployments, removing the disk, the path that it was in and the vm itself

   .PARAMETER vmNames
        The names of the VMS that we are going to be cleaning up

    .FUNCTIONALITY
        Hyper-V

#>



Function Remove-HypervVmDeployment{


    Param (
            # The names of the vms
            [string[]][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$vmNames
        )

   
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
}

