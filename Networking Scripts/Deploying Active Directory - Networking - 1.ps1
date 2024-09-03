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

#Modifying the name of the NIC with the '10.x.x.x' to _INTERNAL
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