<#
    .SYNOPSIS
        Removes all firewall rules on a SQL PAAS instance and replaces it with the outbound IP addresses of the app services found in a RG.

    .DESCRIPTION
        Removes all firewall rules on a SQL PAAS instance and replaces it with the outbound IP addresses of the app services found in a RG.

    .PARAMETER sqlServer
        The name of the Sql Server

    .PARAMETER sqlServerResourceGroupName
        The resource group containing the Sql Paas instance

    .PARAMETER appServiceResourceGroupName
        The resource group containing the app services

    .PARAMETER subscriptionId
        The ID of the subscription that hosts the resources

    .EXAMPLE
        Reset-SqlAppServiceFwRules -sqlServer 'JoboDb01' -sqlServerResourceGroupName 'JoboDatabases-Rg' `
                                -appServiceResourceGroupName 'JoboWebApi-Rg' -subscriptionId '12ac2-fewr3d-......'

        Removes all of the SQL firewall rules om 'JoboDb01' and adds the outbound ip address for the app services in 'JoboWebApi-Rg'.

    .FUNCTIONALITY
        SQL
        Azure
#>

Function Reset-SqlAppServiceFwRules{

    Param (
            # The SQL server that we are going to modify and its resource group.
            [Parameter(Mandatory=$true)][string] $sqlServer,
            [Parameter(Mandatory=$true)][string] $sqlServerResourceGroupName,

            # The resource group to search for app services.
            [Parameter(Mandatory=$true)][string] $appServiceResourceGroupName,
            
            # The subscription Id 
            [Parameter(Mandatory=$true)][string] $subscriptionId
        )

    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
    Select-AzureRmSubscription -SubscriptionId $subscriptionId;

    # Strip current rules
    Get-AzureRmSqlServerFirewallRule -ServerName $sqlServer -ResourceGroupName $sqlServerResourceGroupName | % {
        Remove-AzureRmSqlServerFirewallRule -ServerName $sqlServer `
                                            -ResourceGroupName $sqlServerResourceGroupName `
                                            -FirewallRuleName $_.FirewallRuleName;
    }

    # Gather the outbound IPS for the app services. 
    $ips = @()
    Find-AzureRmResource -ResourceType Microsoft.Web/sites -ResourceGroupNameContains $appServiceResourceGroupName | % {
        $ipBuffer = (Get-AzureRmWebApp -Name $_.name -ResourceGroupName $_.ResourceGroupName | select -ExpandProperty outboundipaddresses) -split ','
        $ips+=$ipBuffer;
    } 
    $ips = $ips | select -Unique;

    # Add in the app service outbound IP'S
    foreach($ip in $ips) {
        New-AzureRmSqlServerFirewallRule -ServerName $sqlServer -ResourceGroupName $sqlServerResourceGroupName`
                                        -FirewallRuleName "AppServiceRule-$ip"`
                                        -StartIpAddress $ip `
                                        -EndIpAddress $ip;
    }

}