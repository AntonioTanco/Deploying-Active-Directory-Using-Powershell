#Creating a new AD-USER using Powershell
#Author: Antonio Tanco
#Last Date Modified: 9-2-24
#Website: github.com/antoniotanco
#Script Version: v1

Import-Module ActiveDirectory

#Using Read-Host in order to pass in the variables needed in order to create a new AD User
$firstName = Read-Host -Prompt "Enter the first name of the user would like to create"
$lastName = Read-Host -Prompt "Enter the last name of the user would like to create"
$username = Read-Host -Prompt "Enter the desired username for this new user"
$password = Read-Host -Prompt "Enter the password for this new user" -AsSecureString

#MODIFY THESE VARIABLES TO FIT YOUR NEEDS
$ouPath = "OU=Users,DC=ad.pshomelab,DC=com"
$emailAddress = "$($username)"+"@ad.pshomelab.com"

#Creating the new user in AD

New-ADUser -Name "$($firstName) $($lastName)" -GivenName $firstName -Surname $lastName -SamAccountName $username -UserPrincipalName $emailAddress -EmailAddress $emailAddress -AccountPassword $password -Enabled $true -PasswordNeverExpires $false -ChangePasswordAtLogon $true

Write-Host "$username was created successfully" -ForegroundColor DarkMagenta