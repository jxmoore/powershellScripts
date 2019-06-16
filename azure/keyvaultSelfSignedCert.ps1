# Quickly make a self signed cert within keyvault 

Function New-SelfSignedKvCert(){
Param (
        [Parameter(Mandatory=$true)][string] $vaultName,
        [Parameter(Mandatory=$true)][string] $subjectName,
        [Parameter(Mandatory=$true)][string] $certName
    )

    if ([string]::IsNullOrEmpty($(Get-AzureRmContext).Account)) {Login-AzureRmAccount}
    $policy = New-AzureKeyVaultCertificatePolicy -SubjectName $subjectName -IssuerName Self -ValidityInMonths 48
    Add-AzureKeyVaultCertificate -VaultName $vaultName -Name $certificateName -CertificatePolicy $policy

}