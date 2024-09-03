#Installing and Configurating DHCP completely via Powershell
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
