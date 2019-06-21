# Get passwords expiring in 'x' number of days
function Get-ExpiringPasswords($daysInAdvanced)
{

    return Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property `
                    samaccountname, @{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | `
                    ? { $_.ExpiryDate.length -gt 0 } | ? { $_.ExpiryDate -lt (get-date).AddDays(2)} | Sort-Object ExpiryDate;

}





