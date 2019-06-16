# This script is/was designed to remove all SQLPAAS FW rules and add in the outbound IP addresses for app services that require DB access.
# In this instance we did not want end users or jump boxes to have FW rules living on the FW rule list.
# We did not use an ASE, these app services had dynamic IP addresses (although not likely to change)
# Azure services (0.0.0.0) was removed per a request by securtiy

Function Reset-SqlFWRules(){
Param (
        [Parameter(Mandatory=$true)][string] $sqlServer,
        [Parameter(Mandatory=$true)][string] $sqlServerRG,
        [Parameter(Mandatory=$true)][string] $appServiceResourceGroupName,
        [Parameter(Mandatory=$true)][string] $subscriptionId
    )

    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
    Select-AzureRmSubscription -SubscriptionId $subscriptionId;

    # Strip current rules
    Get-AzureRmSqlServerFirewallRule -ServerName $sqlServer -ResourceGroupName $sqlServerRG | % {
        Remove-AzureRmSqlServerFirewallRule -ServerName $sqlServer `
                                            -ResourceGroupName $sqlServerRG `
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
        New-AzureRmSqlServerFirewallRule -ServerName $sqlServer -ResourceGroupName $sqlServerRG`
                                        -FirewallRuleName "AppServiceRule-$ip"`
                                        -StartIpAddress $ip `
                                        -EndIpAddress $ip;
    }

}