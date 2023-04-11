# Script to enable PSRemoting on a remote host. Must be able to create a CimSession with host.
# SetPublicRule option to allow connections from different subnet if host is on a public interface
param($ComputerName, [switch]$SetPublicRule)

if($ComputerName -eq $null)
{
	Out-Host -InputObject "ComputerName cannot be null"
	Exit
}

$creds = Get-Credential

# Setting up parameters for CimMethod
$SessionArgs = @{
	ComputerName  = $ComputerName
	Credential    = $creds
	SessionOption = New-CimSessionOption -Protocol Dcom
}
$MethodArgs = @{
	ClassName     = 'Win32_Process'
	MethodName    = 'Create'
	CimSession    = New-CimSession @SessionArgs
	Arguments     = @{
		# Actual command being run on remote computer
		CommandLine = "powershell Start-Process powershell -ArgumentList 'Enable-PSRemoting -Force -SkipNetworkProfileCheck'"
	}
}

# Enabling PSRemoting
Invoke-CimMethod @MethodArgs

# Checking if the public firewall rule should be enabled for any remote host
# Only required if the computer is on a public network or is misidentifying the network as public
if($SetPublicRule)
{
	$MethodArgs = @{
		ClassName     = 'Win32_Process'
		MethodName    = 'Create'
		CimSession    = New-CimSession @SessionArgs
		Arguments     = @{
			CommandLine = "powershell Start-Process powershell -ArgumentList 'Get-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC | Set-NetFirewallRule -RemoteAddress any'"
		}
	}

	# Setting the Firewall rule
	Invoke-CimMethod @MethodArgs
}