<#
    .SYNOPSIS
        This removes inactive AD users and Computers. 

    .DESCRIPTION
        This removes inactive AD users and Computers. 

   .PARAMETER days
        The number of days back (timespan) we will be searching when querying AD.


    .FUNCTIONALITY
        Active Directory

#>


Function Remove-InactiveUsersAndComputers{

    Param (
            # The number of days we are going back in time when searching AD
            [string] $days
        )

        $inactiveUsers = search-adaccount -accountinactive -TimeSpan "-$days" -UsersOnly  -SearchBase "OU=EastUsers,OU=IT,DC=jomo,DC=com" | select -ExpandProperty distinguishedname;
        foreach ($user in $inactiveUsers){
            if(!(get-aduser $user -properties *).pwdLastSet -eq 0){
                Write-Host "$(get-date) :: Removing $user...";
                remove-adobject $user -Recursive -confirm: $false;
            }
        }

        $date = (get-date).AddDays(-$days);
        $computerObjects = get-adcomputer -Filter {LastLogonTimeStamp -lt $date } -SearchBase "OU=EastOffice,OU=Workstations,OU=ComputerObjects,DC=jomo,DC=com" | select -ExpandProperty DistinguishedName;
        foreach($computer in $computerObjects){ 
            Write-Host "$(get-date) :: Removing $computerObjects...";
            remove-adobject $computer -recursive -confirm:$false;
        }

}
