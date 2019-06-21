# This script creates a set of local sql users with a random userid/password then it assigns the users permissions defined in the script
# And all the info is saved into keyvault. The purpose was to create random users for applications to use. 
# These accounts/connection strings would live in Kv, the apps would pull them on startup using MSI, rather than storing any info in the app settings.json.
# In the event something happened (security wise or disaster), the accounts could be removed and the script could be re-ran 
# Effectively re-seeding the vault/database with new accounts.



# Server info
$server = "someServer.database.windows.net";
$database = "PowerDB"; 
# Local dbo owner on the sql instance
$adminId = "sqlAdman";
$adminPass = "z0mb13s";
# Vault stuff
$vaultname = 'SomeKindOfVault' #vault to write connection strings to 
$subscriptionId = ''; # The sub with the vault.


# A list of applications along with the table permissions that they will receive. These string app names should correlate to
# A permission variable name. 
$apps = 'frontEnd1','frontEnd2', 'platformLayer';
$frontEnd1 = @{
    tb1 = 'SELECT';
    tb2 = 'SELECT, INSERT, UPDATE, DELETE';
    tb3 = 'SELECT, INSERT, UPDATE, DELETE';
    tb7 = 'SELECT, INSERT, UPDATE, DELETE';
    tb4 = 'SELECT';
    tb9 = 'SELECT';
};
$frontEnd2 = @{
    tb4 = 'SELECT, INSERT, UPDATE, DELETE';
    tb5 = 'SELECT, INSERT, UPDATE, DELETE';
    tb6 = 'SELECT, INSERT, UPDATE, DELETE';
    tb1 = 'SELECT';
};
$platformLayer = @{
    tb1 = 'SELECT';
    tb3 = 'SELECT';
    tb8 = 'SELECT';
};


# Log in and jump over to our sub
if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
Select-AzureRmSubscription -SubscriptionId $subscriptionId;


# Now we loop through each app
foreach($app in $apps) { 
    # We need to make a random set of creds for the app to use and form a connection string for it.
    $userId = (([char[]](65..90+97..122) | Get-Random -Count 11) -Join '') #aA-Zz
    $password = ( (0..9 | Get-Random -Count 3 ) + (([char[]](65..90+97..122) | Get-Random -Count 16) -Join '') + (0..9 | Get-Random -Count 2 ) -Join '')
    $connectionString = @"
    Server=tcp:$server,1433;Initial Catalog=$database;Persist Security Info=False;User ID=$userId;Password=$password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
"@

        # We dont want to put that into the appsettings.json, it should be pulled from kv, so lets store each apps creds and con strings in the vault.
        Set-AzureKeyVaultSecret -VaultName $vaultName -Name "$app`-sqlUser" `
                                -SecretValue $( $userID | ConvertTo-SecureString -AsPlainText -Force) -ContentType "$app sql server userId"
        Set-AzureKeyVaultSecret -VaultName $vaultName -Name "$app`-sqlPassword" `
                                -SecretValue $( $password | ConvertTo-SecureString -AsPlainText -Force) -ContentType "$app sql server password"
        Set-AzureKeyVaultSecret -VaultName $vaultName -Name "$app`-sqlConnectionString" `
                                -SecretValue $( $connectionString | ConvertTo-SecureString -AsPlainText -Force) -ContentType "$app connectionString";

        # And now we can make the user
        Invoke-Sqlcmd -ServerInstance "$server" -Database master -Username $adminId `
                      -Password $adminPass -Query "
                      CREATE LOGIN $userId WITH PASSWORD = '$password'
                        GO";

        Invoke-Sqlcmd -ServerInstance "$server" -Database  $database -Username $adminID `
                      -Password $adminPass -Query "
                        IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$userId')
                        BEGIN
                            CREATE USER [$userID] FOR LOGIN [$userID]
                        END;
                        GO";

        # Things get squirly here, we want to grab the variable that matches the current $app
        # Then loop through the keys (this would be the tables names 'tb1' for example)
        # Add assign the perms defined for the table (key)
        $tblInfo = Get-Variable -Name $app -ValueOnly;
        foreach ( $key in $tblInfo.Keys ) {
            $permission = $tblInfo.Item($key);
            Invoke-Sqlcmd -ServerInstance "$server" -Database  $database -Username $adminId `
                          -Password $adminPass -Query "
                           GRANT $permission ON dbo.$key TO $userID;";
       }


}

