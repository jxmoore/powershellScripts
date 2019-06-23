<#
    .SYNOPSIS
        This pulls a laps managed password and either creates a secret for it in secret server or updates a secret in secret server. 

    .DESCRIPTION
        This pulls a laps managed password and either creates a secret for it in secret server or updates a secret in secret server. 

    .FUNCTIONALITY
        Active Directory

#>



Function Set-LapsPasswordInSecretServer{

    $comp = Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwd | select samaccountname, ms-Mcs-AdmPwd | ? {  $_.'ms-Mcs-AdmPwd'  }  |  % { 
            $sam = $_.samaccountname -replace ("[$]",""); #We dont need that prefix so lets just remove it, it will confuse some folks for sure.
            $secret = $($sam+"-LAPS"); # Name that will be in SecretServer
            $pas = $_.'ms-Mcs-AdmPwd'; # Password from AD
            $templateName = "Server-LAPS"; # The template in SecretServer
            $where = 'http://ss.jomoserver.com/winauthwebservices/sswinauthwebservice.asmx'; # SS webservice endpoint.
            $ws = New-WebServiceProxy -uri $where -UseDefaultCredential;
            $folder = $ws.searchfolders("ServerLAPS") | select -ExpandProperty folders | select -ExpandProperty id;
            $template = $ws.GetSecretTemplates().SecretTemplates | Where {$_.Name -eq $templateName}

            # Simple check to see if the secret needs to be created or updated.
            $id = $null ; $id = $ws.SearchSecrets($secret,$false,$false) | select -ExpandProperty SecretSummaries;          
            if($id -eq $null){ #Secret needs to be created
                $secretItemFields = ( (Get-SecretFieldId $template "Domain"), (Get-SecretFieldId $template "Username"), (Get-SecretFieldId $template "Password"), (Get-SecretFieldId $template "Notes"));
                $secretItemValues=("jomo.com",$secret,$pas, "");
                $check = $ws.AddSecret($template.Id, $secret, $secretItemFields, $secretItemValues, $folder);
            }

            Else{ # update the password
                $ws.checkin($id);
                $id = $id | select -ExpandProperty secretid;
                $secret=$ws.GetSecret($id, $true, $null);
                $secret.Secret.Items[2].value = $pas;
                $update = $ws.UpdateSecret($secret.Secret);
            }
        
    }

}

# Simple helper script.
function Get-SecretFieldId($template, [string]$name) {
    Return ($template.Fields | Where {$_.DisplayName -eq $name}).Id;
}
