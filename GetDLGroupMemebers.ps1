# Script to get the names and emails of the memebers of all Distribution Lists/Groups
# Comment out line 7-17 and uncomment line 19-27 to get output in csv format

Connect-ExchangeOnline | Out-Null
$groups = Get-Group | Where-Object -Property RecipientType -eq MailUniversalDistributionGroup

foreach($group in $groups)
{
    echo "===================="
    echo "$($group.Name)"
    echo "===================="

    foreach($member in $group.Members)
    {
        echo "$member - $((Get-EXORecipient -Identity $member).PrimarySmtpAddress)"
    }
}

#echo "`"Group Name`",`"User`",`"Email`""
#
#foreach($group in $groups)
#{
#    foreach($member in $group.Members)
#    {
#        echo "`"$($group.Name)`",`"$member`",`"$((Get-EXORecipient -Identity $member).PrimarySmtpAddress)`""
#    }
#}