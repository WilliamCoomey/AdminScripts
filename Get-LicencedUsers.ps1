Connect-MsolService

$users = Get-MsolUser -All
$LicensedUsers = @()

foreach($user in $users)
{
    if($user.IsLicensed -eq $true)
    {
        $LicensedUsers += [PSCustomObject]@{
            DisplayName = $user.DisplayName
            FirstName = $user.FirstName
            LastName = $user.LastName
            Email = $user.UserPrincipalName
        }
    }
}

$LicensedUsers | Export-Csv -Path C:\Temp\LicensedUsers.csv