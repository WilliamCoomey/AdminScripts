# Script to send an email report of backups in Azure

# Required vars for cert authentication in Connect-AzAccount
$cert = Get-ChildItem Cert:\CurrentUser\cert | Where-Object {$_.Subject -eq 'CN=CertCn'}
$thumbprint = $cert.Thumbprint
$appId = "APPID"
$subscriptionID = "SUBID"
$tenantID = "TENANTID"

# IDs for each vault that the app registration has access to
$vaults = @(
    "/ID/FOR/VAULT/1",
    "/ID/FOR/VAULT/2",
    "/ID/FOR/VAULT/3"
)

# CSS for Email formatting
$style = @"
table {
	border-collapse: collapse;
        font-family: Tahoma, Geneva, sans-serif;
	border: 1px solid black;
}
table td {
	padding: 15px;
	border: 1px solid black;
}
table thead td {
	background-color: #adacaa;
	color: #ffffff;
	font-weight: bold;
	font-size: 13px;
	border: 1px solid #54585d;
}
table tbody td {
	color: black;
	
}
table tbody tr {
	background-color: #f9fafb;
}
table tbody tr:nth-child(odd) {
	background-color: #ffffff;
}
"@

function Get-HTML{
    param($jobs)

    $html += "<html>"
    $html += "    <head>"
    $html += "    <style>"
    $html += $style
    $html += "    </style>"
    $html += "    </head>"
    $html += "    <body>"

    $html += "<table style=`"width: 68%`" style=`" border: 1px solid `#008080;`">"
    $html += "    <tr>"
    $html += "        <td style=`"border: 1px solid black;`">"
    $html += "            WorkloadName"
    $html += "        </td>"
    $html += "        <td style=`"border: 1px solid black;`">"
    $html += "            Status"
    $html += "        </td>"
    $html += "        <td style=`"border: 1px solid black;`">"
    $html += "            StartTime"
    $html += "        </td>"
    $html += "        <td style=`"border: 1px solid black;`">"
    $html += "            EndTime"
    $html += "        </td>"
    $html += "    </tr>"

    foreach($job in $jobs)
    {
        # Changing the colour of the table row if the status is anything besides Completed
        if($job.Status -eq "Completed")
        {
            $html += "<tr>"
        }
        else
        {
            $html += "<tr style=`"background-color: `#ffc799`">"
        }
            
        $html += "    <td>"
        $html += "        "+$job.WorkloadName
        $html += "    </td>"
        $html += "    <td>"
        $html += "        "+$job.Status
        $html += "    </td>"
        $html += "    <td>"
        $html += "        "+$job.StartTime
        $html += "    </td>"
        $html += "    <td>"
        $html += "        "+$job.EndTime
        $html += "    </td>"
        $html += "</tr>"
    }

    $html += "    </table>"
    $html += "    </body>"
    $html += "</html>"

    return $html
}

function Send-Email
{
    param ([string]$html)

    $smtpServer = "SMTP_IP"
    $smtpPort = "SMTP_PORT"
    $emailFrom = "FROM_ADDRESS"
    $emailTo = "TO_ADDRESS"
    $emailSubject = "Azure Backups Report"

    Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $html -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort
}

# Connecting to Azure using an App Registration and certificate
Connect-AzAccount -ServicePrincipal -CertificateThumbprint $thumbprint -Tenant $tenantID -ApplicationId $appId -SubscriptionId $subscriptionID | Out-Null

foreach($vault in $vaults)
{
    $jobs += Get-AzRecoveryServicesBackupJob -VaultId $vault | Select-Object -Property WorkLoadName, Status, StartTime, EndTime
}

$html = Get-Html $jobs

Send-Email $html