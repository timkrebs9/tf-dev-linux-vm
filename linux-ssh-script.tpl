cat << EOF >> ~/.ssh/config

Host ${hostname}
    HostName ${hostname}
    User $Euserb
    IdentityFile ${identityfile}
EOF
I