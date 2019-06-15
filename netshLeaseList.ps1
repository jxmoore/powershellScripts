## This came about because we had roughly 2K (32bit 2008) dhcp servers that did not at the time have the powershell DHCP module installed
## and we needed a way to query leases via powershell. This searches DHCP for a scope (in this case all scopes org wide are 172.17.xxx.xxx)
## once the scope is found leases are pulled and displayed.

$server = "jomoStoreTester";
$scope = ((netsh dhcp server \\$server show scope | ? { $_ -match '172.17' }) -split '\s' | ? { $_ -notmatch '\s'})[1];
netsh dhcp server \\$server scope $scope show clients 2 | ? { $_ -match '172.17'} | ? { $_ -match '255'}|  % { 
    $splits = $_ -split '\s';
    $ip = $splits[0];
    $workstation = $splits[$splits.count-1];
    Write-Host "$ip - $workstation";
}
