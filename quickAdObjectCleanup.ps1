# AD cleanup

$inactiveUsers = search-adaccount -accountinactive -TimeSpan 30:00:00:00 -UsersOnly  -SearchBase "OU=EastUsers,OU=IT,DC=jomo,DC=com" | select -ExpandProperty distinguishedname;
foreach ($user in $inactiveUsers){
    if(!(get-aduser $user -properties *).pwdLastSet -eq 0){
        remove-adobject $user -Recursive -confirm: $false;
        Write-Host "Removing $user...";
    }
}

$date = (get-date).AddDays(-30);
$computerObjects = get-adcomputer -Filter {LastLogonTimeStamp -lt $date } -SearchBase "OU=EastOffice,OU=Workstations,OU=ComputerObjects,DC=jomo,DC=com" | select -ExpandProperty DistinguishedName;
foreach($computer in $computerObjects){ 
    remove-adobject $computer -recursive -confirm:$false;
    Write-Host "Removing $computerObjects...";
}
