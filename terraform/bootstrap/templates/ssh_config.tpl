Host ${controller_ip}
    User ubuntu
    IdentityFile ~/.ssh/${key_name}.pem
    StrictHostKeyChecking accept-new
Host ${agent_ip}
    User ubuntu
    IdentityFile ~/.ssh/${key_name}.pem
    StrictHostKeyChecking accept-new  