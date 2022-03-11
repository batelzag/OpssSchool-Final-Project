#!/usr/bin/env bash
# This script installs and configure the instance as jenkins agent

# If there will be an error message when running the script, it will stop and will not continue to other jobs
set -e

# Install the requierd pkg for jenkins agent
sudo apt-get update -y
sudo apt install openjdk-11-jdk -y
sudo apt install docker.io -y
sudo service docker start
sudo usermod -aG docker ubuntu
sudo systemctl daemon-reload
sudo systemctl start docker
sudo systemctl enable docker
sudo chmod 666 /var/run/docker.sock

# Configure jenkins agent service
sudo tee /etc/consul.d/jenkins_agent.json > /dev/null <<EOF
{
  "service": {
    "id": "jenkins-agent",
    "name": "jenkins-agent",
    "tags": ["jenkins", "jenkins agent", "consul agent"]
  }
}

EOF

# Register the jenkins agent service to consul by reloading the consul service
consul reload

exit 0