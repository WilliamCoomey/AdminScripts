#Connect-ExchangeOnline
#Connect-MsolService

$mailboxes = Get-MailBox -ResultSize Unlimited

foreach ($mailbox in $mailboxes)
{
    $domain = ($mailbox.PrimarySmtpAddress).Split("@")
    $user = Get-MsolUser -UserPrincipalName $mailbox.UserPrincipalName
    if($domain[1] -eq "COMPANY.onmicrosoft.com")
    {
        if($user.IsLicensed -eq $true)
        {
            echo $mailbox.PrimarySmtpAddress
        }
    }
}