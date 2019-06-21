<#
Loop through the tables found in the storage account with the given suffix.
If the table is not null then we query for the rows. Next we Cycle through the rows, 
if the rowkey or partitionkey is not null the row is deleted.
#>


$storageAccountName = "";
$resourceGroupName = "";
$subscriptionId = "";
$prefix = "cahce";

if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
Select-AzureRmSubscription -SubscriptionId $subscriptionId;


$storageQuery = New-Object "Microsoft.WindowsAzure.Storage.Table.TableQuery";

try {
    $storageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value;
    $Ctx = New-AzureStorageContext –StorageAccountName $StorageAccountName -StorageAccountKey $storageKey;

}
catch {
    Write-Error "Error obtaining storage context $error";
}

$tables = Get-AzureStorageTable -Context $Ctx | ? { $_.CloudTable -match "[^\d*]$prefix"}
foreach($table in $tables) { 
    if ($table -ne $null) { 
        $rows = $Table.CloudTable.ExecuteQuery($storageQuery);
        foreach($row in $rows) { 
            if(($row.rowkey) -or ($row.Partitionkey)) {
                Write-Output "Deleting the following row:`n$row";
                $table.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::Delete($row));
            }
        }
    }
}