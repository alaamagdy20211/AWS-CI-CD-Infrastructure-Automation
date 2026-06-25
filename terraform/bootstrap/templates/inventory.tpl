[jenkins_controller]
${controller_ip} ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3

[jenkins_agent]
${agent_ip} ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3

[jenkins:children]
jenkins_controller
jenkins_agent