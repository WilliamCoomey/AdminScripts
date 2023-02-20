# Script to list the free space of drives in a computer
# Add hostnames to Print-Disks call to add additional computers to list

$Tab = [char]9

function Print-Disks
{
    param ([string[]]$computers)

    foreach($computer in $computers)
    {
        $wmiObj = Get-WmiObject win32_logicaldisk -ComputerName $computer
        $name = $wmiObj.SystemName[0]

        echo "$name Disks"
        echo "---------------------------"
        echo "ID $Tab Free $Tab Size $Tab %"
        Foreach ($disk in $wmiObj)
        {
            $id = $disk.DeviceID
            $free = [math]::floor($disk.FreeSpace / 1GB)
            $size = [math]::floor($disk.Size / 1GB)

            if($size -ne 0)
            {
                $percent = ($free / $size) * 100
                $percent = [math]::Floor($percent)
            }
            else
            {
                $percent = 0
            }
    
    
            if($free -eq 0)
            {
                continue
            }
            elseif($free -lt 10)
            {
                echo "$id $Tab $free$Tab$Tab $size $Tab$Tab $percent"
            }
            else
            {
                echo "$id $Tab $free $Tab $size $Tab $percent"
            }
        }

        echo "==========================="
    }
}


$servers = Get-Content .\ServerList.txt
Print-Disks $servers

