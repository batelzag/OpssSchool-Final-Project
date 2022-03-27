#!/usr/bin/env bash
# This script installs and configures ansible server and execute a playbook to install jenkins server plugins

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Installation of Ansibel and the required packages
sudo apt update -y 
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
sudo apt-get install python-boto3 -y

# Change Ansibel's configuration to enable dynamic inventory file (aws plugin)
sudo sed -i 's/#enable_plugins = host_list, virtualbox, yaml, constructed/enable_plugins = aws_ec2/g' /etc/ansible/ansible.cfg
sudo sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg

# Copying the provisined files to the right directories
sudo cp /home/ubuntu/jenkins_install_plugins/aws_ec2.yml /etc/ansible
sudo cp -r /home/ubuntu/jenkins_install_plugins /etc/ansible/roles
sudo rm -r /home/ubuntu/jenkins_install_plugins

# Configure ansible server service
tee /etc/consul.d/ansible_server.json > /dev/null <<EOF
{
  "service": {
    "id": "ansible-server",
    "name": "ansible-server",
    "tags": ["ansible", "ansible-server"]
  }
}
EOF

# Register the ansible server service to consul by reloading the consul service
consul reload

# Register external service with a health check - RDS db server
sudo mkdir /etc/consul.d/external_services

tee /etc/consul.d/external_services/db_server.json > /dev/null <<EOF
{
  "Node": "db-server",
  "Address": "db-server.opsschool.internal",
  "NodeMeta": {
    "external-node": "true",
    "external-probe": "true"
  },
  "Service": {
    "ID": "db-server",
    "Service": "db-server",
    "Port": 5432,
    "Tags": ["db-server", "postgres", "rds"]
  },
  "Checks": [
    {
      "Name": "Check tcp connection on port 5432",
      "Status": "passing",
      "Definition": {
        "tcp": "localhost:5432",
        "interval": "15s"
      }
    }
  ]    
}
EOF

curl --request PUT --data @/etc/consul.d/external_services/db_server.json localhost:8500/v1/catalog/register

# Changing the Permissions of the provisioned key - in order to ssh to the remote nodes
sudo chmod 400 /home/ubuntu/opsschool_project_key.pem

# In order to make sure Jenkins server is fully up, suspending the run of the playbook for 30 seconds
sleep 30

# Running Jenkins Install Plugins role
ansible-playbook -i /etc/ansible/aws_ec2.yml /etc/ansible/roles/jenkins_install_plugins/run_setup.yml \
-u ubuntu --private-key /home/ubuntu/opsschool_project_key.pem -e 'ansible_python_interpreter=/usr/bin/python3'

exit 0