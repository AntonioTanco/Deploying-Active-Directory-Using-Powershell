# 📝 Deploying Active Directory Using Powershell

> [!CAUTION]
> This repo is an extension this repo here: https://github.com/AntonioTanco/ActiveDirectoryLab/tree/main
>
> This repo aims to do the same things found in that repo entirely in powershell. This isn't meant to serve as a guide but more of a showcasing of my skills in powershell.
>
> Never run any code without an understanding of what the code is modifying in any environment that isn't solely meant for testing purposes only.

<h2>Project Overview</h2>
<p>Used powershell to completely automate the install/configuration of Window Server roles and features such as: Active Directory Domain Services, RSAT (NAT), DNS and DHCP. 

Powershell was also used to modify the network adapters on the server in order to modify the IPv4 Configuration to assign a static IP Address and DNS Server on the public facing NIC.</p>

<h2>Languages and Software/ISO Used</h2>

- <b>PowerShell</b> 
- <b>Oracle VM VirtualBox</b>
- <b>Windows 10 Pro</b>
- <b>Windows Server 2019 (GUI)</b>

<h2>Networking - Powershell</h2>

<h3>Understanding the 'Deploying Active Directory - Networking - 1.ps1' script</h3>

<p>This script is responsible for changing the names and IPv4 Config on the two NIC's present on the server. REGEX was used in order to target the NIC which recieved a 10.X.X.X Address from my ISP (VM NAT). This allows me to temporarily store select information about that NIC in $NIC_TO_MODIFY.

  This allows me to make changes throughout the script while only using one variable to store all the necessary information needed in order to apply the desired config via the script.</p>

  <b>This will be the first script you will run in order to achieve the same configuration found in this repo @ https://github.com/AntonioTanco/ActiveDirectoryLab/tree/main</b>

```
#Configurating NIC settings completely via Powershell
#Author: Antonio Tanco
#Last Date Modified: 9-2-24
#Website: github.com/antoniotanco
#Script Version: v1

# -------- ADJUST THESE SETTINGS TO FIT YOUR NEEDS -------- #
$NIC_NAME = "_INTERNAL"
$address_family_config = "IPv4"
$assigned_ip_address = "172.16.0.1"
$subnet_mask_prefix_length = 24
$dns_server_ip_address = "127.0.0.1"

$internal_NIC_name = "_INTERNET"

# ------ THE VARIABLE ABOVED OUTLINE OUR NIC CONFIG ------- #

#Getting all the network adapters that are using the IPv4 address family
$ip_addresses = Get-NetIPAddress -AddressFamily IPv4

#regex pattern in order to find all IPv4 Address that begin with '10.X.X.X' - this will identify the NIC which is using NAT that we defined in setting up this VM
$pattern = '^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$'

#Filtering through all $ip_addresses in order to return the NIC which is addressed: '10.X.X.X'
$filteredAddresses = $ip_addresses | Where-Object {$_.IPAddress -match $pattern }

#Storing information about the NIC we need to modify via this script.
$NIC_TO_MODIFY = $filteredAddresses | Select-Object InterfaceAlias, IPAddress, InterfaceIndex

#Modifying the name of the NIC with the '10.x.x.x' to _INTERNET
Rename-NetAdapter -Name $NIC_TO_MODIFY.InterfaceAlias -NewName $internal_NIC_name

#Printing to console the changes made to the target NIC
Write-Host "The network adapter with the '10.x.x.x' addresses name has changed to: $($internal_NIC_name) " -ForegroundColor Green

#Overwritting NIC_TO_MODIFY to store the other network adapter who Name is not equal to $internal_NIC_name
$NIC_TO_MODIFY = Get-NetAdapter | Where-Object {$_.Name -ne $internal_NIC_name} | Select-Object InterfaceAlias, IPAddress, InterfaceIndex

#Setting the name, DNS Configuration and IPv4 Configuration of $NIC_TO_MODIFY

#If the $NIC_TO_MODIFY doesn't have an assigned IP Address we want to apply those changes ourselves via this script using the variable defines aboved
if ($NIC_TO_MODIFY.IPAddress -eq $null) {

    #Renaming Network adapter to "_INTERNAL"
    Rename-NetAdapter -Name $NIC_TO_MODIFY.InterfaceAlias -NewName $NIC_NAME

    Write-Host "Applying the IPv4 Configuration to: $($NIC_TO_MODIFY.InterfaceAlias) " -ForegroundColor Yellow

    #Modifying the IPv4 Configuration of $NIC_TO_MODIFY
    New-NetIPAddress -InterfaceIndex $NIC_TO_MODIFY.InterfaceIndex -IPAddress $assigned_ip_address -PrefixLength $subnet_mask_prefix_length -AddressFamily $address_family_config

    #Printing to console the changes made by getting the NIC with the IP address of what we assigned to it via this script
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -eq $assigned_ip_address}
     
    Write-Host "The IPv4 Configuration has been successfully applied to: $($NIC_TO_MODIFY.InterfaceAlias)" -ForegroundColor Green

    Write-Host "Setting the DNS Config of: $($NIC_TO_MODIFY.InterfaceAlias)... " -ForegroundColor Yellow

    #Modifying the DNS Configuration of $NIC_TO_MODIFY to the DNS address defined in this script
    Set-DnsClientServerAddress -InterfaceAlias $NIC_NAME -ServerAddresses $dns_server_ip_address

    #Storing the DNS Server of $NIC_TO_MODIFY to print to console later
    $NIC_TO_MODIFY_DNS = Get-DnsClientServerAddress -AddressFamily $address_family_config | Where-Object {$_.InterfaceAlias -eq $NIC_NAME} | Select-Object ServerAddresses

    Write-Host "The DNS Configuration has been successfully applied to: $($NIC_TO_MODIFY.InterfaceAlias)" -ForegroundColor Green

    Write-Host "$($NIC_TO_MODIFY.InterfaceAlias) DNS Server: $($NIC_TO_MODIFY_DNS.ServerAddresses) " -ForegroundColor Green


}
```

<h3>Understanding the 'Deploying Active Directory - Install+Configure RRAS.ps1' script</h3>

<p>This script is responsible for installing and configurating the RSAT Feature and Routing roles on the server. The script finds the NIC using Get-NetAdapter whose name is equal to "_INTERNET" which was set eariler using the 'Deploying Active Directory - Networking - 1.ps1' script. 

The script will then enable forwarding and create a NAT configuration on the NIC to allow for routing of all network traffic out to the public internet acting as a gateway for our connected clients.</p>

<b>This will be the second script you will run in order to achieve the same configuration found in this repo @ https://github.com/AntonioTanco/ActiveDirectoryLab/tree/main</b>

```
﻿#Installing and Configurating RRAS role completely via Powershell
#Author: Antonio Tanco
#Last Date Modified: 9-2-24
#Website: github.com/antoniotanco
#Script Version: v1

#Import ServerManager
Import-Module ServerManager

#Installing RSAT Windows Feature
Install-WindowsFeature RSAT-RemoteAccess-Powershell

#Installing the RemoteAccess and Routing Roles
Install-WindowsFeature -Name RemoteAccess -IncludeManagementTools
Install-WindowsFeature -Name Routing -IncludeManagementTools

#Importing Remote Access
Import-Module RemoteAccess

#Getting Network Adapter via name in order to set NAT against our public facing NIC
$nic = Get-NetAdapter | Where-Object {$_.Name -eq "_INTERNET"}

#Enable Forwarding on NIC's interface
Set-NetIPInterface -InterfaceIndex $nic.InterfaceIndex -Forwarding Enabled

#Set NAT against the interface in order to represent a public facing IP Address
New-NetNat -Name "InternetNAT" -InternalIPInterfaceAddressPrefix "172.16.0.0/24"

#Get the NAT information of the server
Get-NetNat

#Get specifically the NIC where NAT is enabled on and print to console the interface index and status of forwarding
Get-NetIPInterface -InterfaceIndex $nic.InterfaceIndex | Select-Object InterfaceIndex, Forwarding
```
<h3>Understanding the 'Deploying Active Directory - Install+Configuring DHCP.ps1' script</h3>

<p>This script is responsible for installing and configuring the DHCP Server role. The script defines the scope, subnet mask and state of the DHCP server against the "_INTERNAL" NIC stored in the $ipAddress variable. 
  
  The default gateway and DNS Server were also defined programmatically in this script on the '172.16.0.1' address which is the address assigned to this NIC via the first script: <i>'Deploying Active Directory - Networking - 1.ps1'</i></p>

  <b>This will be the third script you will run in order to achieve the same configuration found in this repo @ https://github.com/AntonioTanco/ActiveDirectoryLab/tree/main</b>

```
﻿#Installing and Configurating DHCP completely via Powershell
#Author: Antonio Tanco
#Last Date Modified: 9-2-24
#Website: github.com/antoniotanco
#Script Version: v1

#Installing DHCP Server role on the server
Install-WindowsFeature -Name DHCP -IncludeManagementTools

#Defining the name of the NIC we want to pull the IP Address on for reference later
$nicName = "_INTERNAL"

#Storing the IP Address of the NIC which that is named what we defined eariler in $nicName
$ipAddress = Get-NetIPAddress -InterfaceAlias $nicName -AddressFamily IPv4 | Select-Object IPAddress

#Creating a DHCP Server against the "_INTERNAL" NIC for our internally connected host to be addressed from an IP Address Pool
Add-DhcpServerInDC -DnsName ad.pshomelab.com -IPAddress $ipAddress.IPAddress

#Creating the DHCP Server scope, subnet mask and state
Add-DhcpServerv4Scope -Name "Primary-Scope" -StartRange 172.16.0.100 -EndRange 172.16.0.200 -SubnetMask 255.255.255.0 -State Active

#Setting the Router (Default Gateway) of the DHCP Server where all traffic will follow from
Set-DhcpServerv4OptionValue -ScopeId 172.16.0.1 -Router 172.16.0.1

#Setting the DNS of the DHCP Server that will be used by all of the addressed clients/host
Set-DhcpServerv4OptionValue -ScopeId 172.16.0.1 -DnsServer 172.16.0.1

#Print the all DHCP Server Scope info to console
Get-DhcpServerv4Scope

#Print all of the options set against our DHCP Server
Get-DhcpServerv4OptionValue -ScopeId 172.16.0.1
```

<h2>Active Directory - Powershell</h2>

<h3>Understanding the 'Deploying Active Directory - Install+Configure ADDS.ps1' script</h3>

<p>This script is responsible for installing and configurating ADDS on the Windows server. This script creates a new Active Directory forest (ad.pshomelab.com) programmatically and restarts the server to apply all the changes made.</p>

 <b>This will be the fourth script you will run in order to achieve the same configuration found in this repo @ https://github.com/AntonioTanco/ActiveDirectoryLab/tree/main</b>

```
﻿#Installing and Configurating Active Directory Domain Services completely via Powershell
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
```
