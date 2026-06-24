Host bastion
    HostName ${bastion_public_ip}
    User ubuntu
    IdentityFile ~/.ssh/${key_name}.pem
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host app-server
    HostName ${app_private_ip}
    User ubuntu
    IdentityFile ~/.ssh/${key_name}.pem
    ProxyJump bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null