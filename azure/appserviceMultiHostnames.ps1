# Small little script for adding multiple traffic managers to a web appliation
 
﻿$newfqdn="jomoTesto-GTM.trafficmanager.net"
$newfqdn2="jomoTesto2-East.trafficmanager.net"
$webappname="East-JomoTesto"
$existingomdomains="$webappname.azurewebsites.net, $webappname.scm.azurewebsites.net"
$location="East US 2"
$Resourcegroup = 'East-JomoTesto-RG'
Set-AzureRmWebApp -Name $webappname -ResourceGroupName $Resourcegroup -HostNames @($newfqdn,$newfqdn2,$existingomdomains)
