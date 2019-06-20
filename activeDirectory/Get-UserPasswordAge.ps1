# Get a users password expiration date 
function Get-PasswordExperation($userId)
{
    return Get-ADUser -identity $userId –Properties "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property `
                @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}};
}

