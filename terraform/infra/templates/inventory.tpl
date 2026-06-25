[bastion]
 ${bastion_public_ip} ansible_user=ubuntu

[app]
 ${app_private_ip}  ansible_user=ubuntu

[infra:children]
bastion
app