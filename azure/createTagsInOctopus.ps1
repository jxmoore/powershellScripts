# This is a small function written to run within octopus deploy, it just sets tags on a resource
# giving details about the project, owner etc...

Function Set-ResourceTagOcto(){
Param (
        [Parameter(Mandatory=$true)][string] $clientSecret,
        [Parameter(Mandatory=$true)][string] $resourceGroupName,
        [Parameter(Mandatory=$true)][string] $resourceName,
        [Parameter(Mandatory=$true)][string] $tenant,
        [Parameter(Mandatory=$true)][string] $clientID,
        [Parameter(Mandatory=$false)][string] $ProjectOwner,
        [Parameter(Mandatory=$true)][string] $subscriptionID,
      )

    $cred = new-object -typename System.Management.Automation.PSCredential `
                        -argumentlist $clientID, ($clientSecret | ConvertTo-SecureString -AsPlainText -Force);

    Login-AzureRmAccount -Credential $cred  -ServicePrincipal -TenantId $tenant;
    Select-AzureRmSubscription -SubscriptionId $subscriptionID;
    
    if(!($projectOwner)){ $projectOwner = $OctopusParameters['Octopus.Deployment.CreatedBy.DisplayName']; }
 
    try { 

        Get-AzureRmResource -ResourceGroupName $resourceGroupName -ResourceName $resourceName `
        | Set-AzureRmResource -Tag @{
            Owner=$($projectOwner);
            OctopusProject=$($OctopusParameters["Octopus.Project.Name"]);
            Deployment=$($OctopusParameters["Octopus.Deployment.Id"]);   
            PreviousDeployment=$($OctopusParameters["Octopus.Deployment.PreviousSuccessful.Id"]);   
            Environment=$($OctopusParameters["Octopus.Environment.Name"]);
            DeploymentDate=$(get-date);
        } `
            -Force:$true -Confirm:$false;

    }
    catch {  
        Write-error "Error setting tag $error";
    }

}