# Small DSC example for creating an OU and a service account within it.
# [Adsi] is used instead of native powershell (get-aduser), as it always returns a bool.

Script ServiceAccountOU
{
    SetScript = { 
        $rootdse = (Get-ADRootDSE).rootDomainNamingContext;
        new-adorganizationalunit -DisplayName 'ServiceAccounts' -Name 'ServiceAccounts' -Path $rootdse;
        Write-Verbose -Verbose "Creating ServiceAccounts";
    }
    GetScript =  { @{} }
    TestScript = { 
        $rootdse = (Get-ADRootDSE).rootDomainNamingContext;
        [adsi]::Exists("LDAP://OU=ServiceAccounts,$rootdse");
    }
    DependsOn = "" # Set to depend on DC creation or what have you.
}	      
Script domainJoinsvc
{
    SetScript = { 
        
        For ($a=33;$a –le 126;$a++) { 

            if( ($a -ne 34) -and ($a -ne 47) -and ($a -ne 92)-and ($a -ne 59)-and ($a -ne 58) -and 
                ($a -ne 96) -and ($a -ne 39) -and ($a -ne 44) -and ($a -ne 46)){  
                    $char+=,[char][byte]$a;
                }
        }  
        0..32 | % { $newSvcPassword+=($char | Get-Random ); } 

        $rootdse = (Get-ADRootDSE).rootDomainNamingContext;               
        new-aduser -Name 'domainJoinsvc' -SamAccountName 'domainJoinsvc' -PasswordNeverExpires $true `
        -AccountPassword ("$newSvcPassword" | ConvertTo-SecureString -AsPlainText -Force) `
        -Path "OU=domainJoinsvc,$rootdse" -enabled:$true;
    }
    GetScript =  { @{} }
    TestScript = {  
        $rootdse = (Get-ADRootDSE).rootDomainNamingContext;
        [adsi]::Exists("LDAP://CN=domainJoinsvc,OU=ServiceAccounts,$rootdse");
    }
    DependsOn = "[Script]ServiceAccounts";
}