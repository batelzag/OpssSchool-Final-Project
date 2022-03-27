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

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get install postgresql -y

# Configure jenkins agent service
sudo tee /etc/consul.d/jenkins_agent.json > /dev/null <<EOF
{
  "service": {
    "id": "jenkins-agent",
    "name": "jenkins-agent",
    "tags": ["jenkins", "jenkins-agent"],
    "checks": [
      {
        "name": "ssh on port 22",
        "tcp": "localhost:22",
        "interval": "15s",
        "timeout": "5s"
      }
    ]
  }
}

EOF

# Register the jenkins agent service to consul by reloading the consul service
consul reload

# Install Trivy for Vulnerability scans 
wget https://github.com/aquasecurity/trivy/releases/download/v0.17.0/trivy_0.17.0_Linux-64bit.deb
sudo dpkg -i trivy_0.17.0_Linux-64bit.deb

exit 0