Host jenkins-controller
    HostName ${controller_ip}
    User ubuntu
    IdentityFile ~/.ssh/${key_name}.pem
    StrictHostKeyChecking no

Host jenkins-agent
    HostName ${agent_ip}
    User ubuntu
    IdentityFile ~/.ssh/${key_name}.pem
    StrictHostKeyChecking no