'VBScript to add printers from a print server
'Used as part of an AD login script

Option Explicit
On error Resume Next

Dim network, printerConnections, i
Set network = WScript.CreateObject("WScript.Network")
Set printerConnections = network.EnumPrinterConnections

'Duplicate the below line for additional printers
installPrinter("\\SERVER\PRINTER")

Set network = CreateObject("WScript.Network")
network.SetDefaultPrinter "\\SERVER\PRINTER"
WScript.Quit

'Checks if printer is installed, if not, then add printer
'Each printer has two connections in the array - port and printer name. Hence the Step 2.
Function installPrinter(printer)
    For i = 0 to printerConnections.Count - 1 Step 2
        if InStr(printerConnections.Item(i+1), printer) <> 0 THEN
            'WScript.Echo "Printer installed"
            Exit For
        ElseIf i = (printerConnections.Count - 2) THEN
            'WScript.Echo "Printer not installed"
            network.AddWindowsPrinterConnection printer
        end if
    Next
End Function