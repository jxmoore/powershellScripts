<#
    .SYNOPSIS
        This empties out cloud storage tables that have a specific suffix

    .DESCRIPTION
        This empties out cloud storage tables that have a specific suffix

   .PARAMETER storageAccountName
        The name of the azure storage account where the table resides

   .PARAMETER resourceGroupName
        The resource group that contains the storage account
        
   .PARAMETER subscriptionId
        The subscription ID for the storage account.

   .PARAMETER suffix
        The suffix that we will search for when clearing tables 

    .FUNCTIONALITY
        Azure

#>

Function Remove-CloudStorageTableRows{


    Param (
            # The name of the azure storage account where the table resides
            [string[]][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$storageAccountName,
            # The resource group that contains the storage account
            [string[]][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$resourceGroupName,
            # The subscription ID for the storage account.
            [string[]][Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$subscriptionId,
            # The suffix for the table name
            [string[]][Parameter(Mandatory=$false)]$suffix = "cahce"

        )

   
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
}

