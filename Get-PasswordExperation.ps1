<#
    .SYNOPSIS
        Gets the password expiration date for an Active Directory user.

    .DESCRIPTION
        Gets the password expiration date for an Active Directory user.

    .PARAMETER userId
        The upn or samaccountname of the user.

    .EXAMPLE
        write-host $(Get-PasswordExperation('jfboor'));

        Prints 'jfboor's password expiration date. 

    .FUNCTIONALITY
        ActiveDirectory
    
    .TODO
        Error handeling if a user cannot be found.
#>

function Get-PasswordExperation{
    
    Param (
            # The user id that will be queried in Active Directory 
            [Parameter(Mandatory=$true)][string] $userId
    )
    
    return Get-ADUser -identity $userId –Properties "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property `
                @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}};

}

