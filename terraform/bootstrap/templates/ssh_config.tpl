[jenkins_controller]
${controller_ip} ansible_user=ubuntu

[jenkins_agent]
${agent_ip} ansible_user=ubuntu

[jenkins:children]
jenkins_controller
jenkins_agent