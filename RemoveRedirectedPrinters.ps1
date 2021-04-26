#Script to fix niche issue where Relay takes a long time to add letters due to a buildup
#Of redirected printer registry entries
#Can cause redirected printers to stop working. Logging out/in will resolve that issue.

$path = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Devices"
$devices = Get-Item -path $path
$items = ($devices | Select-Object -ExpandProperty Property) | Where-Object {$_ -like "*redirected*"}


foreach($item in $items)
{
    Remove-ItemProperty -Path $path -Name $item
}