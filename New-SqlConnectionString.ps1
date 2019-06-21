# This sits in my profile so i can just call it willy nilly when i need a new connection string.
# its easier than trying to remember all of the fields and type them out each and every time.
# new-SqlConnectionString -sqlserver "JomoSqlBox" -database "Goats" -credential $(get-credential)

function New-SqlConnectionString
{
  param
  (
      [String][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$sqlServer,
      [String][Parameter(Mandatory=$false)]$sqlDatabase="master",
      [int][Parameter(Mandatory=$false)]$timeout=30,
      [PSCredential][System.Management.Automation.CredentialAttribute()][Parameter(Mandatory=$true)]$credential
  )

  # SQL PAAS
  if($sqlServer -match 'database.windows.net'){
       return "Server=tcp:$sqlServer,1433;Initial Catalog=$SqlDatabase;Persist Security Info=False;User ID=$($Credential.UserName);Password=$($Credential.GetNetworkCredential().Password);MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=$timeout;";
  }
  else{ # Regular old SQL Server
      return "Server=$SqlServer;Initial Catalog=$SqlDatabase;User ID=$($Credential.UserName);Password=$($Credential.GetNetworkCredential().Password);Connection Timeout=$timeout;";
  }

}