#Script to output the status of Azure backups

Connect-AzAccount | Out-Null
$vault = Get-AzRecoveryServicesVault
$output = Get-AzRecoveryServicesBackupJob -VaultId $vault.ID | Select-Object -Property WorkLoadName, Status, StartTime, EndTime | Format-Table

#Need to pipe output to get around printing after pause statement bug
$output | Out-Host

pause