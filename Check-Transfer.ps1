# This script gets passed the return value of a robocopy script and then sends an email to specified SMTP server
# SecureString output saved to a pass.key file required for SMTP server auth

# Passing in return code of robocopy batch file
param($retCode)
$log = ".\transfer.log"

function Send-Email
{
    # Text of the email to send and SMTP server password
    param($text, $pass)

    # Required params for sending email
    $EmailTo = "TO EMAIL"
    $EmailFrom = "FROM EMAIL"
    $Subject = "Transfer Report"
    $Body = $text
    $SMTPServer = "SMTPSERVER"
    $SMTPPort = 25
    
    # Creating required objects and sending the email
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailFrom, $pass)
    
    $SMTPClient.Send($SMTPMessage)
}

# Getting SMTP password from saved secure string
$pass = (Get-Content .\pass.key | ConvertTo-SecureString)

# Logging the time started
(Get-Date).toString().Trim() >> $log
$text = ""

# Ret codes 0-3 indicate success or success with warnings
if($retCode -lt 4 -and $retCode -gt -1)
{
    $text = "Transfer completed successfully. Exit code was $retCode."
}
else
{
    $text = "Transfer completed with errors. Exit code was $retCode"
}

# Logging the results
$text+"`n" >> $log

# Sending the email and logging the result
try
{
    Send-Email $text $pass
}
catch
{
    "Encountered error sending email" >> $log
    exit
}

"Email sent" >> $log