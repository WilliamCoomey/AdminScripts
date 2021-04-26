#Simple script to output a timestamped ping to Google to a text file
#Used to verify remote users connection dropping or latency spikes

while(1)
{
    Get-Date >> file.txt
    $string = ping www.google.com -4
    $line = ($string | Select-String -pattern "Reply|No|Request|Destination").Line
    echo $line >> file.txt
}