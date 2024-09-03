#Installing and Configurating RRAS role completely via Powershell
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