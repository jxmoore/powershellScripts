<#
    .SYNOPSIS
        Creates a self signed certificate in Azure Key Vault.

    .DESCRIPTION
        Creates a self signed certificate in Azure Key Vault.

    .PARAMETER vaultName
        The name of the Azure Key Vault.

    .PARAMETER subjectName
        The subject name of the certificate.

    .PARAMETER certName
        The name for the certificate.

    .EXAMPLE
        New-SelfSignedKvCert -vaultName "JomoSecrets" -subjectName "JomoFoods.biz" -CertName "foodtruck"

        Creates a new certificate and stores it in the vault.

    .FUNCTIONALITY
        Azure
#>

Function New-SelfSignedKvCert{
    Param (
            # The name of the vault
            [Parameter(Mandatory=$true)][string] $vaultName,
            [Parameter(Mandatory=$true)][string] $subjectName,
            [Parameter(Mandatory=$true)][string] $certName
        )

    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount;}
    $policy = New-AzureKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 48;
    Add-AzureKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy;

}
