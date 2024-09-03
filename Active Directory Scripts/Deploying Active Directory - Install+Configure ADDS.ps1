#Installing and Configurating Active Directory Domain Services completely via Powershell
#Author: Antonio Tanco
#Last Date Modified: 9-2-24
#Website: github.com/antoniotanco
#Script Version: v1

#Installing ADDS
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

#Importing ADDS to install and configure ADDSForest for the server
Import-Module ADDSDeployment

#Setting the DSRM password to pass into the Install-ADDSForest parameters
$securePassword = ConvertTo-SecureString "resetADadmin24" -AsPlainText -Force

#Installing ADDSForest and passing in all the necessary values to create the domain forest and force restarting the server to apply the changes.
Install-ADDSForest `
-CreateDNSDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "ad.pshomelab.com" `
-DomainNetbiosName "AD" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-SysvolPath "C:\Windows\SYSVOL" `
-SafeModeAdministratorPassword $securePassword `
-Force:$true
