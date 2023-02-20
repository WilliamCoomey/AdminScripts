# Script to send the disk usage information to an email address/DL
# Servers to check should be listed in "ServerList.txt" in the same directory

$Tab = [char]9

function Get-Disks
{
    param ([string[]]$computers)
    $diskInfos = @()

    foreach($computer in $computers)
    {
        # Requesting the disk info from each computer
        $wmiObj = Get-WmiObject win32_logicaldisk -ComputerName $computer
        $name = $wmiObj.SystemName[0]
        $disks = @()

        # Looping through each disk
        Foreach ($disk in $wmiObj)
        {
            $id = $disk.DeviceID
            $free = [math]::floor($disk.FreeSpace / 1GB)
            $size = [math]::floor($disk.Size / 1GB)

            # Calculating the disk usage percent
            if($size -ne 0)
            {
                $percent = ($free / $size) * 100
                $percent = [math]::Floor($percent)
            }
            else
            {
                # Setting percentage to avoid divide by zero error
                $percent = 0
            }

            # Skipping disks with nothing free as they are usually not real drives
            if($free -eq 0)
            {
                continue
            }

            $disks += [PSCustomObject]@{
                id = $id
                freeSpace = $free
                size = $size
                percentFree = $percent
            }
        }

        $diskInfos += [PSCustomObject]@{
            server = $computer
            disks = $disks
        }
    }

    return $diskInfos
}

# Styling for the HTML email
$style = @"
table {
	border-collapse: collapse;
    font-family: Tahoma, Geneva, sans-serif;
}
table td {
	padding: 15px;
}
table thead td {
	background-color: #adacaa;
	color: #ffffff;
	font-weight: bold;
	font-size: 13px;
	border: 1px solid #54585d;
}
table tbody td {
	color: #636363;
	border: 1px solid #dddfe1;
}
table tbody tr {
	background-color: #f9fafb;
}
table tbody tr:nth-child(odd) {
	background-color: #ffffff;
}
"@

function Get-HTML{
    param ([PSCustomObject]$diskInfos)

    $html += "<html>"
    $html += "    <head>"
    $html += "    <style>"
    $html += $style
    $html += "    </style>"
    $html += "    </head>"
    $html += "    <body>"
    
    foreach($diskInfo in $diskInfos)
    {
        #Out-Host -InputObject $diskInfo
        $html += "<table style=`"width: 68%`" style=`" border: 1px solid `#008080;`">"
        $html += "    <tr>"
        $html += "        <td colspan=`"4`" style=`"border: 1px solid black; text-align: center;` background-color: `#cfcfcf`">"
        $html += "            "+$diskInfo.server
        $html += "        </td>"
        $html += "    </tr>"
        $html += "    <tr>"
        $html += "        <td style=`"border: 1px solid black;`">"
        $html += "            ID"
        $html += "        </td>"
        $html += "        <td style=`"border: 1px solid black;`">"
        $html += "            Free Space"
        $html += "        </td>"
        $html += "        <td style=`"border: 1px solid black;`">"
        $html += "            Size"
        $html += "        </td>"
        $html += "        <td style=`"border: 1px solid black;`">"
        $html += "            Percent Free"
        $html += "        </td>"
        $html += "    </tr>"

        foreach($disk in $diskInfo.disks)
        {
            # Changing table row colour if there's less than 15% free space
            if($disk.percentFree -gt 15)
            {
                $html += "<tr>"
            }
            else
            {
                $html += "<tr style=`"background-color: `#ffc799`">"
            }
            
            $html += "    <td>"
            $html += "        "+$disk.id
            $html += "    </td>"
            $html += "    <td>"
            $html += "        "+$disk.freeSpace
            $html += "    </td>"
            $html += "    <td>"
            $html += "        "+$disk.size
            $html += "    </td>"
            $html += "    <td>"
            $html += "        "+$disk.percentFree
            $html += "    </td>"
            $html += "</tr>"
        }
        $html += "</table>"
        $html += "</br>"
        $html += "</br>"
        $html += "</br>"
    }

    $html += "    </body>"
    $html += "</html>"

    return $html
}

function Send-Email
{
    param ([string]$html)

    $smtpServer = "SMTP_SERVER"
    $smtpPort = "25"
    $emailFrom = "FROM_EMAIL"
    $emailTo = "TO_EMAIL"
    $emailSubject = "Disk Usage Report"

    Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $html -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort
}

# Servers listed in a text file in the same directory
$servers = Get-Content .\ServerList.txt
$disks = Get-Disks $server
$html = Get-Html $disks

Send-Email $html
