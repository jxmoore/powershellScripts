# Small silly script just for dumping user info. 
# Get-MassUserInfo | export-csv -NoTypeInformaiton .\UserList.csv
function Get-MassUserInfo()
{

    $userList = @();
    Get-ADUser -Filter {Enabled -eq $true } -Properties * | % { 
                    $obj = New-Object -TypeName psobject;
                    $obj | Add-Member -NotePropertyName "DisplayName" -NotePropertyValue $_.DisplayName;
                    $obj | Add-Member -NotePropertyName "Description" -NotePropertyValue $_.Description;
                    $obj | Add-Member -NotePropertyName "Department" -NotePropertyValue $_.Department;
                    $obj | Add-Member -NotePropertyName "Office" -NotePropertyValue $_.Office;
                    $obj | Add-Member -NotePropertyName "HomeDrive" -NotePropertyValue $_.HomeDrive;
                    $obj | Add-Member -NotePropertyName "Manager" -NotePropertyValue $_.Manager;
                    $obj | Add-Member -NotePropertyName "StartDate" -NotePropertyValue $_.Created;
                    $obj | Add-Member -NotePropertyName "Samaccountname" -NotePropertyValue $_.samaccountname;
                    $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName;
                    $obj | Add-Member -NotePropertyName "LastLogonDate" -NotePropertyValue $_.LastLogonDate;
                    $obj | Add-Member -NotePropertyName "PasswordLastSet" -NotePropertyValue $_.PasswordLastSet;
                    $userList+=$obj;
    }


}


