Host  ${bastion_public_ip}
    User ubuntu
    IdentityFile /home/jenkins/.ssh/${key_name}.pem
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host ${app_private_ip}
    User ubuntu
  IdentityFile /home/jenkins/.ssh/${key_name}.pem
      ProxyJump  ${bastion_public_ip}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null