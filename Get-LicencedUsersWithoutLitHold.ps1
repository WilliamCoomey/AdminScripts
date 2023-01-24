Connect-MsolService
Connect-ExchangeOnline

$users = (Get-MsolUser -All | Where-Object -Property isLicensed -eq $True).UserPrincipalName
$usersWithoutLitigationHold = @()
$usersWithLitigationHold = @()

foreach($user in $users)
{
    if((Get-Mailbox $user).LitigationHoldEnabled -eq $true)
    {
        $usersWithLitigationHold += $user
    }
    else
    {
        $usersWithoutLitigationHold += $user
    }
}

echo "Users with Litigation Hold"
echo "============================="
echo $usersWithLitigationHold
echo "============================="
echo "Users without Litigation Hold"
echo "============================="
echo $usersWithoutLitigationHold