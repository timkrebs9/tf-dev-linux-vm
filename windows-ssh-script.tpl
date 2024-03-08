add-content -path c:/users/timkr/.ssh/config -value @'

Host ${hostname}
HostName ${hostname}
User $Euserb
IdentityFile ${identityfile}
'@