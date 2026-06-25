Host  ${bastion_public_ip}
    User ec2-user
    IdentityFile /home/jenkins/.ssh/${key_name}.pem
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host ${app_private_ip}
    User ec2-user
  IdentityFile /home/jenkins/.ssh/${key_name}.pem
      ProxyJump  ${bastion_public_ip}
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null