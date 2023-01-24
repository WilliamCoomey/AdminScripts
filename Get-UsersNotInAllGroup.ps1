Connect-MsolService

$users = Get-MsolUser -All | Where-Object -Property isLicensed -eq $True
$group = Get-MsolGroup -All | Where-Object -Property DisplayName -eq "All"
$groupMembers = Get-MsolGroupMember -All -GroupObjectId $group.ObjectId
$usersNotInGroup = @()

foreach($user in $users)
{
    $inGroup = $false
    foreach($member in $groupMembers)
    {
        if($member.EmailAddress -eq $user.UserPrincipalName)
        {
            $inGroup = $True
        }
    }

    if(!$inGroup)
    {
        $usersNotInGroup += $user
        echo $user.UserPrincipalName
    }
}

$usersNotInGroup | Export-Csv C:\Temp\UsersNotInAll.csv
