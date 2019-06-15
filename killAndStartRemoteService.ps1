## Loop through an ou, find all the computer objects not containing 'admin'. Once the machines are found we loop through them and verify 
## $serviceName is running. In the event it is not, the pid is used to stop the process and the service is restarted. 
## This came about as we had roughly 300/400 remote sites that had DHCP stuck in a 'starting' status post WSUS, preventing many workstations at remote sites
## from obtaining leaseses.


Add-PSSnapin quest.activeroles.admanagement
$serviceName = 'DHCPServer'

$compCollection= @() # This will just store all of the machines found with the service down for reporting.
Get-QADComputer -SearchRoot 'jomoco.com/Computers/eastDivision' -SizeLimit 1000000 | select -ExpandProperty samaccountname | ? { $_ -notmatch 'admin'} | % {
   
   $distantServer = $_.replace('$',$NULL);
   if (Test-Connection $distantServer -Count 1 -ErrorAction SilentlyContinue){
       $svc = (Get-Service $serviceName -ComputerName $distantServer ).status;
       if ( $svc -notmatch 'running' ){
           $obj = New-Object -TypeName psobject;
           $obj | Add-Member -NotePropertyName "Far Off Server" -NotePropertyValue $distantServer;
           $obj | Add-Member -NotePropertyName "Service Status" -NotePropertyValue $svc;
           Invoke-Command -computername $distantServer -ScriptBlock {
             $servicePID = (get-wmiobject win32_service | where { $_.name -eq $using:serviceName}).processID;
             Stop-Process -id $ServicePID -Force;
             Start-Service $using:serviceName;
           }

           $compCollection+=$obj
       }
   }
}

write-host $compCollection;
