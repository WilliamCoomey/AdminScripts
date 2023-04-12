param($Username, $Password)

if($Username -eq $null -or $Password -eq $null)
{
	Out-Host -InputObject "Username and Password must be specified"
	exit
}

$DCs = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=domain,DC=com"
$pass = ConvertTo-SecureString $Password -AsPlainText -Force

# Active Directory Web Services must be enabled on the DCs for the below to run
foreach($DC in $DCs)`
{
	Set-ADAccountPassword -Identity $Username -NewPassword $pass -Server $DC.Name
	Unlock-ADAccount -Identity $Username -Server $DC.Name
}